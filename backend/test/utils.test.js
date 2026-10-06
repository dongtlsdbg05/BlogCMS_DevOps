const test = require('node:test');
const assert = require('node:assert/strict');
const { hashPassword, verifyPassword } = require('../src/utils/password');
const slugify = require('../src/utils/slug');

test('password hash verifies correct password and rejects wrong password', () => {
  const hash = hashPassword('StrongPass@123');
  assert.equal(verifyPassword('StrongPass@123', hash), true);
  assert.equal(verifyPassword('wrong-password', hash), false);
});

test('Vietnamese title is converted to URL-safe slug', () => {
  assert.equal(slugify('Triển khai & Quản trị Hệ thống'), 'trien-khai-quan-tri-he-thong');
});
