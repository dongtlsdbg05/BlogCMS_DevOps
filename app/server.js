require('dotenv').config();
const path = require('path');
const express = require('express');
const session = require('express-session');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const client = require('prom-client');
const pool = require('./src/config/db');
const requestLogger = require('./src/middleware/logger');
const { exposeUser } = require('./src/middleware/auth');

const app = express();
app.set('trust proxy', 1);
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'src', 'views'));
app.disable('x-powered-by');

app.use(helmet({ contentSecurityPolicy: false }));
app.use(express.urlencoded({ extended: false, limit: '1mb' }));
app.use(express.json({ limit: '1mb' }));
app.use(express.static(path.join(__dirname, 'public'), { maxAge: '1h' }));
app.use(session({
  name: 'devblog.sid',
  secret: process.env.SESSION_SECRET || 'development-only-change-me',
  resave: false,
  saveUninitialized: false,
  cookie: { httpOnly: true, sameSite: 'lax', secure: process.env.COOKIE_SECURE === 'true', maxAge: 8 * 60 * 60 * 1000 }
}));
app.use(exposeUser);
app.use(requestLogger);
app.use(rateLimit({ windowMs: 60 * 1000, limit: 300, standardHeaders: 'draft-7', legacyHeaders: false }));

client.collectDefaultMetrics();
const httpRequests = new client.Counter({ name: 'devblog_http_requests_total', help: 'HTTP requests', labelNames: ['method','route','status'] });
const httpDuration = new client.Histogram({ name: 'devblog_http_request_duration_seconds', help: 'HTTP request duration', labelNames: ['method','route','status'], buckets: [0.01,0.05,0.1,0.25,0.5,1,2] });
app.use((req,res,next) => {
  const end = httpDuration.startTimer();
  res.on('finish', () => {
    const route = req.route?.path || req.path;
    const labels = { method: req.method, route: String(route).slice(0,120), status: String(res.statusCode) };
    httpRequests.inc(labels);
    end(labels);
  });
  next();
});

app.get('/api/health', async (req,res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'healthy', database: 'connected', time: new Date().toISOString() });
  } catch (e) {
    res.status(503).json({ status: 'unhealthy', database: 'disconnected' });
  }
});
app.get('/metrics', async (req,res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.use('/', require('./src/routes/auth'));
app.use('/admin', require('./src/routes/admin'));
app.use('/', require('./src/routes/public'));

app.use((req,res) => res.status(404).render('public/error', { title: '404', message: 'Trang bạn tìm không tồn tại.' }));
app.use((err,req,res,next) => {
  console.error(JSON.stringify({ level: 'ERROR', event: 'UNHANDLED_ERROR', message: err.message, stack: process.env.NODE_ENV === 'development' ? err.stack : undefined }));
  res.status(500).render('public/error', { title: 'Lỗi hệ thống', message: process.env.NODE_ENV === 'development' ? err.message : 'Đã xảy ra lỗi. Vui lòng thử lại.' });
});

const port = Number(process.env.PORT || 3000);
app.listen(port, '0.0.0.0', () => console.log(JSON.stringify({ level: 'INFO', event: 'APP_STARTED', port })));
