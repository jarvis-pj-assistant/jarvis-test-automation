// Jarvis Copilot test — implemented by Jarvis
// Preferred model: gpt-5-mini

/**
 * Compute the factorial of a non-negative integer n.
 * Iterative implementation with input validation.
 * @param {number} n - A non-negative integer
 * @returns {number} - n! (factorial)
 * @throws {TypeError} If n is not a number or not an integer
 * @throws {RangeError} If n is negative
 */
function factorial(n) {
  if (typeof n !== 'number' || Number.isNaN(n)) {
    throw new TypeError('n must be a number');
  }
  if (!Number.isInteger(n)) {
    throw new TypeError('n must be an integer');
  }
  if (n < 0) {
    throw new RangeError('n must be non-negative');
  }
  // 0! = 1
  let result = 1;
  for (let i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

module.exports = { factorial };
