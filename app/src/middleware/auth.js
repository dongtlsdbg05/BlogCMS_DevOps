function exposeUser(req, res, next) {
  res.locals.currentUser = req.session?.user || null;
  next();
}

function requireAuth(req, res, next) {
  if (!req.session?.user) return res.redirect('/login?next=' + encodeURIComponent(req.originalUrl));
  next();
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.session?.user) return res.redirect('/login');
    if (!roles.includes(req.session.user.role)) return res.status(403).render('public/error', { title: 'Không có quyền', message: 'Bạn không có quyền thực hiện thao tác này.' });
    next();
  };
}

module.exports = { exposeUser, requireAuth, requireRole };
