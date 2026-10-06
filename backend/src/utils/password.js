const crypto = require('crypto');

const ITERATIONS = 120000;
const KEYLEN = 32;
const DIGEST = 'sha256';

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.pbkdf2Sync(password, salt, ITERATIONS, KEYLEN, DIGEST).toString('hex');
  return `${salt}:${hash}`;
}

function verifyPassword(password, stored) {
  if (!stored || !stored.includes(':')) return false;
  const [salt, expected] = stored.split(':');
  const actual = crypto.pbkdf2Sync(password, salt, ITERATIONS, KEYLEN, DIGEST);
  const expectedBuffer = Buffer.from(expected, 'hex');
  return actual.length === expectedBuffer.length && crypto.timingSafeEqual(actual, expectedBuffer);
}

module.exports = { hashPassword, verifyPassword };
