const express = require('express');
const rateLimit = require('express-rate-limit');
const pool = require('../config/db');
const { verifyPassword } = require('../utils/password');
const audit = require('../services/audit');
const router = express.Router();

const loginLimiter = rateLimit({ windowMs: 60 * 1000, limit: 5, standardHeaders: 'draft-7', legacyHeaders: false });

router.get('/login', (req, res) => {
  if (req.session?.user) return res.redirect('/admin');
  res.render('auth/login', { title: 'Đăng nhập', error: null });
});

router.post('/login', loginLimiter, async (req, res, next) => {
  try {
    const username = String(req.body.username || '').trim();
    const password = String(req.body.password || '');
    const [[user]] = await pool.execute('SELECT * FROM users WHERE username=? LIMIT 1', [username]);
    if (!user || user.status !== 'ACTIVE' || !verifyPassword(password, user.password_hash)) {
      console.warn(JSON.stringify({ level: 'WARN', event: 'LOGIN_FAILED', username, ip: req.ip }));
      return res.status(401).render('auth/login', { title: 'Đăng nhập', error: 'Sai tài khoản, mật khẩu hoặc tài khoản đã bị khóa.' });
    }
    req.session.user = { id: user.id, username: user.username, full_name: user.full_name, role: user.role };
    await audit(req, 'LOGIN', 'auth', String(user.id));
    res.redirect(req.query.next || '/admin');
  } catch (e) { next(e); }
});

router.post('/logout', async (req, res) => {
  await audit(req, 'LOGOUT', 'auth', String(req.session?.user?.id || ''));
  req.session.destroy(() => res.redirect('/'));
});
module.exports = router;
