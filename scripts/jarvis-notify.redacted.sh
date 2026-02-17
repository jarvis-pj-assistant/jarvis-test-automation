#!/usr/bin/env bash
REPO="jarvis-pj-assistant/jarvis-test-automation"
BRANCH="jarvis/test-automation"
RECIPIENT="<REDACTED_EMAIL>"
STATE_FILE="$HOME/.openclaw/jarvis-notify-state.json"
LOGFILE="$HOME/.openclaw/jarvis-notify.log"
GITHUB_API_TOKEN="<REDACTED_TOKEN>""}"
set -euo pipefail
mkdir -p "$(dirname "$STATE_FILE")"
last_sha=""
if [ -f "$STATE_FILE" ]; then
  last_sha=$(jq -r .last_sha "$STATE_FILE" 2>/dev/null || echo "")
fi
api_url="https://api.github.com/repos/$REPO/commits?sha=$BRANCH&per_page=1"
if [ -n "$GITHUB_API_TOKEN" ]; then
  resp=$(curl -s -H "Authorization: token $GITHUB_API_TOKEN" "$api_url")
else
  resp=$(curl -s "$api_url")
fi
new_sha=$(echo "$resp" | jq -r '.[0].sha')
new_msg=$(echo "$resp" | jq -r '.[0].commit.message')
new_author=$(echo "$resp" | jq -r '.[0].commit.author.name')
new_url=$(echo "$resp" | jq -r '.[0].html_url')
if [ -z "$new_sha" ] || [ "$new_sha" = "null" ]; then
  echo "[$(date -u)] Could not determine latest commit for $REPO:$BRANCH" >> "$LOGFILE"
  exit 0
fi
if [ "$new_sha" = "$last_sha" ]; then
  exit 0
fi
subject="[$(basename $REPO)] new commit on $BRANCH: ${new_sha:0:7}"
body=$(cat <<EOF
Repository: $REPO
Branch: $BRANCH
Commit: $new_sha
Author: $new_author
Message: $new_msg
URL: $new_url

This is an automated notification from Jarvis.
EOF
)
printf "%s" "$body" | gog gmail send --to "$RECIPIENT" --subject "$subject" --body-file -
jq -n --arg s "$new_sha" '{last_sha:$s}' > "$STATE_FILE"
echo "[$(date -u)] Sent notification for $new_sha to $RECIPIENT" >> "$LOGFILE"
