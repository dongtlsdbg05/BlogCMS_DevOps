const express = require('express');
const pool = require('../config/db');
const audit = require('../services/audit');
const router = express.Router();

router.get('/', async (req, res, next) => {
  try {
    const q = String(req.query.q || '').trim();
    const page = Math.max(1, Number(req.query.page || 1));
    const limit = 6;
    const offset = (page - 1) * limit;
    let where = "p.status='PUBLISHED'";
    const params = [];
    if (q) {
      where += ' AND (p.title LIKE ? OR p.summary LIKE ? OR p.content LIKE ?)';
      const term = `%${q}%`;
      params.push(term, term, term);
    }
    const [countRows] = await pool.execute(`SELECT COUNT(*) total FROM posts p WHERE ${where}`, params);
    const [posts] = await pool.execute(
      `SELECT p.*, u.full_name author_name, c.name category_name, c.slug category_slug
       FROM posts p JOIN users u ON p.author_id=u.id JOIN categories c ON p.category_id=c.id
       WHERE ${where} ORDER BY p.published_at DESC, p.id DESC LIMIT ${limit} OFFSET ${offset}`,
      params
    );
    const [categories] = await pool.query('SELECT c.*, COUNT(p.id) post_count FROM categories c LEFT JOIN posts p ON p.category_id=c.id AND p.status="PUBLISHED" GROUP BY c.id ORDER BY c.name');
    res.render('public/home', { title: 'DevBlog', posts, categories, q, page, totalPages: Math.max(1, Math.ceil(countRows[0].total / limit)) });
  } catch (e) { next(e); }
});

router.get('/post/:slug', async (req, res, next) => {
  try {
    const [rows] = await pool.execute(
      `SELECT p.*, u.full_name author_name, c.name category_name, c.slug category_slug
       FROM posts p JOIN users u ON p.author_id=u.id JOIN categories c ON p.category_id=c.id
       WHERE p.slug=? AND p.status='PUBLISHED' LIMIT 1`, [req.params.slug]
    );
    if (!rows.length) return res.status(404).render('public/error', { title: 'Không tìm thấy', message: 'Bài viết không tồn tại hoặc chưa được xuất bản.' });
    const post = rows[0];
    await pool.execute('UPDATE posts SET views=views+1 WHERE id=?', [post.id]);
    const [comments] = await pool.execute(`SELECT cm.*, COALESCE(u.full_name, cm.guest_name) display_name FROM comments cm LEFT JOIN users u ON cm.user_id=u.id WHERE cm.post_id=? AND cm.status='APPROVED' ORDER BY cm.created_at DESC`, [post.id]);
    const [related] = await pool.execute(`SELECT title, slug FROM posts WHERE category_id=? AND status='PUBLISHED' AND id<>? ORDER BY published_at DESC LIMIT 4`, [post.category_id, post.id]);
    res.render('public/post', { title: post.title, post, comments, related, message: req.query.comment === 'sent' ? 'Bình luận đã gửi và đang chờ duyệt.' : null });
  } catch (e) { next(e); }
});

router.post('/post/:id/comments', async (req, res, next) => {
  try {
    const content = String(req.body.content || '').trim();
    if (content.length < 3 || content.length > 1500) return res.status(400).render('public/error', { title: 'Bình luận không hợp lệ', message: 'Bình luận phải từ 3 đến 1500 ký tự.' });
    const user = req.session?.user;
    const guestName = user ? null : String(req.body.guest_name || '').trim().slice(0, 100);
    const guestEmail = user ? null : String(req.body.guest_email || '').trim().slice(0, 120);
    if (!user && (!guestName || !guestEmail)) return res.status(400).render('public/error', { title: 'Thiếu thông tin', message: 'Khách cần nhập tên và email.' });
    await pool.execute('INSERT INTO comments (post_id,user_id,guest_name,guest_email,content,status) VALUES (?,?,?,?,?,"PENDING")', [req.params.id, user?.id || null, guestName, guestEmail, content]);
    await audit(req, 'CREATE_COMMENT', 'comments', null, `post_id=${req.params.id}`);
    const [[post]] = await pool.execute('SELECT slug FROM posts WHERE id=?', [req.params.id]);
    res.redirect(post ? `/post/${post.slug}?comment=sent` : '/');
  } catch (e) { next(e); }
});

router.get('/category/:slug', async (req, res, next) => {
  try {
    const [[category]] = await pool.execute('SELECT * FROM categories WHERE slug=?', [req.params.slug]);
    if (!category) return res.status(404).render('public/error', { title: 'Không tìm thấy', message: 'Danh mục không tồn tại.' });
    const [posts] = await pool.execute(`SELECT p.*, u.full_name author_name FROM posts p JOIN users u ON p.author_id=u.id WHERE p.category_id=? AND p.status='PUBLISHED' ORDER BY p.published_at DESC`, [category.id]);
    res.render('public/category', { title: category.name, category, posts });
  } catch (e) { next(e); }
});

module.exports = router;
