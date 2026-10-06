module.exports = function requestLogger(req, res, next) {
  const started = Date.now();
  res.on('finish', () => {
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      level: res.statusCode >= 500 ? 'ERROR' : res.statusCode >= 400 ? 'WARN' : 'INFO',
      method: req.method,
      path: req.originalUrl,
      status: res.statusCode,
      duration_ms: Date.now() - started,
      user: req.session?.user?.username || 'anonymous',
      ip: req.ip
    }));
  });
  next();
};
