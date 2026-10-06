const express = require('express');
const pool = require('../config/db');
const { requireAuth, requireRole } = require('../middleware/auth');
const { hashPassword } = require('../utils/password');
const slugify = require('../utils/slug');
const audit = require('../services/audit');
const router = express.Router();

router.use(requireAuth);

router.get('/', async (req, res, next) => {
  try {
    const [[stats]] = await pool.query(`SELECT
      (SELECT COUNT(*) FROM posts) posts,
      (SELECT COUNT(*) FROM categories) categories,
      (SELECT COUNT(*) FROM users) users,
      (SELECT COUNT(*) FROM comments) comments,
      (SELECT COUNT(*) FROM comments WHERE status='PENDING') pending_comments`);
    const [recentPosts] = await pool.query(`SELECT p.id,p.title,p.status,p.updated_at,u.full_name author_name FROM posts p JOIN users u ON p.author_id=u.id ORDER BY p.updated_at DESC LIMIT 6`);
    res.render('admin/dashboard', { title: 'Tổng quan', stats, recentPosts });
  } catch (e) { next(e); }
});

router.get('/posts', requireRole('ADMIN','EDITOR'), async (req, res, next) => {
  try {
    const [posts] = await pool.query(`SELECT p.*, u.full_name author_name, c.name category_name FROM posts p JOIN users u ON p.author_id=u.id JOIN categories c ON p.category_id=c.id ORDER BY p.updated_at DESC`);
    res.render('admin/posts', { title: 'Quản lý bài viết', posts });
  } catch (e) { next(e); }
});

router.get('/posts/new', requireRole('ADMIN','EDITOR'), async (req, res, next) => {
  try {
    const [categories] = await pool.query('SELECT * FROM categories ORDER BY name');
    res.render('admin/post-form', { title: 'Tạo bài viết', post: null, categories, error: null });
  } catch (e) { next(e); }
});

router.post('/posts', requireRole('ADMIN','EDITOR'), async (req, res, next) => {
  try {
    const { title, summary, content, thumbnail_url, status, category_id } = req.body;
    if (!title || !content || !category_id) throw new Error('Tiêu đề, nội dung và danh mục là bắt buộc.');
    let slug = slugify(title);
    const [[exists]] = await pool.execute('SELECT id FROM posts WHERE slug=?', [slug]);
    if (exists) slug += `-${Date.now()}`;
    const publishedAt = status === 'PUBLISHED' ? new Date() : null;
    const [result] = await pool.execute(`INSERT INTO posts (title,slug,summary,content,thumbnail_url,status,author_id,category_id,published_at) VALUES (?,?,?,?,?,?,?,?,?)`, [title, slug, summary || null, content, thumbnail_url || null, status || 'DRAFT', req.session.user.id, category_id, publishedAt]);
    await audit(req, 'CREATE_POST', 'posts', String(result.insertId), title);
    res.redirect('/admin/posts');
  } catch (e) { next(e); }
});

router.get('/posts/:id/edit', requireRole('ADMIN','EDITOR'), async (req, res, next) => {
  try {
    const [[post]] = await pool.execute('SELECT * FROM posts WHERE id=?', [req.params.id]);
    if (!post) return res.status(404).render('public/error', { title: 'Không tìm thấy', message: 'Bài viết không tồn tại.' });
    const [categories] = await pool.query('SELECT * FROM categories ORDER BY name');
    res.render('admin/post-form', { title: 'Sửa bài viết', post, categories, error: null });
  } catch (e) { next(e); }
});

router.post('/posts/:id', requireRole('ADMIN','EDITOR'), async (req, res, next) => {
  try {
    const { title, summary, content, thumbnail_url, status, category_id } = req.body;
    const [[old]] = await pool.execute('SELECT * FROM posts WHERE id=?', [req.params.id]);
    if (!old) return res.status(404).render('public/error', { title: 'Không tìm thấy', message: 'Bài viết không tồn tại.' });
    const publishedAt = status === 'PUBLISHED' ? (old.published_at || new Date()) : old.published_at;
    await pool.execute(`UPDATE posts SET title=?,summary=?,content=?,thumbnail_url=?,status=?,category_id=?,published_at=? WHERE id=?`, [title, summary || null, content, thumbnail_url || null, status, category_id, publishedAt, req.params.id]);
    await audit(req, 'UPDATE_POST', 'posts', req.params.id, title);
    res.redirect('/admin/posts');
  } catch (e) { next(e); }
});

router.post('/posts/:id/delete', requireRole('ADMIN'), async (req, res, next) => {
  try {
    const [[post]] = await pool.execute('SELECT title FROM posts WHERE id=?', [req.params.id]);
    if (post) {
      await pool.execute('DELETE FROM posts WHERE id=?', [req.params.id]);
      await audit(req, 'DELETE_POST', 'posts', req.params.id, post.title);
    }
    res.redirect('/admin/posts');
  } catch (e) { next(e); }
});

router.get('/categories', requireRole('ADMIN'), async (req, res, next) => {
  try {
    const [categories] = await pool.query('SELECT c.*, COUNT(p.id) post_count FROM categories c LEFT JOIN posts p ON p.category_id=c.id GROUP BY c.id ORDER BY c.name');
    res.render('admin/categories', { title: 'Chuyên mục', categories });
  } catch (e) { next(e); }
});

router.post('/categories', requireRole('ADMIN'), async (req, res, next) => {
  try {
    const name = String(req.body.name || '').trim();
    if (!name) return res.redirect('/admin/categories');
    const [result] = await pool.execute('INSERT INTO categories (name,slug,description) VALUES (?,?,?)', [name, slugify(name), req.body.description || null]);
    await audit(req, 'CREATE_CATEGORY', 'categories', String(result.insertId), name);
    res.redirect('/admin/categories');
  } catch (e) { next(e); }
});

router.post('/categories/:id', requireRole('ADMIN'), async (req, res, next) => {
  try {
    const name = String(req.body.name || '').trim();
    const description = String(req.body.description || '').trim();
    if (!name) return res.status(400).render('public/error', { title: 'Dữ liệu không hợp lệ', message: 'Tên danh mục là bắt buộc.' });
    const [[old]] = await pool.execute('SELECT * FROM categories WHERE id=?', [req.params.id]);
    if (!old) return res.status(404).render('public/error', { title: 'Không tìm thấy', message: 'Danh mục không tồn tại.' });
    await pool.execute('UPDATE categories SET name=?,slug=?,description=? WHERE id=?', [name, slugify(name), description || null, req.params.id]);
    await audit(req, 'UPDATE_CATEGORY', 'categories', req.params.id, name);
    res.redirect('/admin/categories');
  } catch (e) { next(e); }
});

router.post('/categories/:id/delete', requireRole('ADMIN'), async (req, res, next) => {
  try {
    const [[count]] = await pool.execute('SELECT COUNT(*) total FROM posts WHERE category_id=?', [req.params.id]);
    if (count.total === 0) {
      await pool.execute('DELETE FROM categories WHERE id=?', [req.params.id]);
      await audit(req, 'DELETE_CATEGORY', 'categories', req.params.id);
    }
    res.redirect('/admin/categories');
  } catch (e) { next(e); }
});

router.get('/users', requireRole('ADMIN'), async (req, res, next) => {
  try {
    const [users] = await pool.query('SELECT id,username,email,full_name,role,status,created_at FROM users ORDER BY created_at DESC');
    res.render('admin/users', { title: 'Tài khoản', users });
  } catch (e) { next(e); }
});

router.post('/users', requireRole('ADMIN'), async (req, res, next) => {
  try {
    const { username,email,full_name,password,role } = req.body;
    if (!username || !email || !full_name || !password || password.length < 8) return res.status(400).render('public/error', { title: 'Dữ liệu không hợp lệ', message: 'Cần đầy đủ thông tin và mật khẩu tối thiểu 8 ký tự.' });
    const [result] = await pool.execute('INSERT INTO users (username,email,full_name,password_hash,role,status) VALUES (?,?,?,?,?,"ACTIVE")', [username,email,full_name,hashPassword(password),['ADMIN','EDITOR','USER'].includes(role)?role:'USER']);
    await audit(req, 'CREATE_USER', 'users', String(result.insertId), username);
    res.redirect('/admin/users');
  } catch (e) { next(e); }
});

router.post('/users/:id/role', requireRole('ADMIN'), async (req, res, next) => {
  try {
    if (String(req.params.id) === String(req.session.user.id)) return res.redirect('/admin/users');
    const role = ['ADMIN','EDITOR','USER'].includes(req.body.role) ? req.body.role : 'USER';
    await pool.execute('UPDATE users SET role=? WHERE id=?', [role, req.params.id]);
    await audit(req, 'UPDATE_USER_ROLE', 'users', req.params.id, role);
    res.redirect('/admin/users');
  } catch (e) { next(e); }
});

router.post('/users/:id/toggle', requireRole('ADMIN'), async (req, res, next) => {
  try {
    if (String(req.params.id) === String(req.session.user.id)) return res.redirect('/admin/users');
    await pool.execute(`UPDATE users SET status=IF(status='ACTIVE','LOCKED','ACTIVE') WHERE id=?`, [req.params.id]);
    await audit(req, 'TOGGLE_USER_STATUS', 'users', req.params.id);
    res.redirect('/admin/users');
  } catch (e) { next(e); }
});

router.get('/comments', requireRole('ADMIN','EDITOR'), async (req, res, next) => {
  try {
    const [comments] = await pool.query(`SELECT cm.*, p.title post_title, COALESCE(u.full_name,cm.guest_name) display_name FROM comments cm JOIN posts p ON cm.post_id=p.id LEFT JOIN users u ON cm.user_id=u.id ORDER BY cm.created_at DESC`);
    res.render('admin/comments', { title: 'Bình luận', comments });
  } catch (e) { next(e); }
});

router.post('/comments/:id/status', requireRole('ADMIN','EDITOR'), async (req, res, next) => {
  try {
    const status = ['APPROVED','REJECTED','PENDING'].includes(req.body.status) ? req.body.status : 'PENDING';
    await pool.execute('UPDATE comments SET status=? WHERE id=?', [status, req.params.id]);
    await audit(req, 'MODERATE_COMMENT', 'comments', req.params.id, status);
    res.redirect('/admin/comments');
  } catch (e) { next(e); }
});

router.get('/audit', requireRole('ADMIN'), async (req, res, next) => {
  try {
    const [logs] = await pool.query(`SELECT a.*, u.username FROM audit_logs a LEFT JOIN users u ON a.user_id=u.id ORDER BY a.created_at DESC LIMIT 200`);
    res.render('admin/audit', { title: 'Nhật ký hoạt động', logs });
  } catch (e) { next(e); }
});

module.exports = router;
