const pool = require('../config/db');

async function audit(req, action, resource, resourceId = null, details = null) {
  try {
    await pool.execute(
      'INSERT INTO audit_logs (user_id, action, resource, resource_id, ip_address, details) VALUES (?, ?, ?, ?, ?, ?)',
      [req.session?.user?.id || null, action, resource, resourceId, req.ip, details]
    );
    console.log(JSON.stringify({ level: 'INFO', event: 'AUDIT', action, resource, resourceId, user: req.session?.user?.username || 'anonymous' }));
  } catch (err) {
    console.error(JSON.stringify({ level: 'ERROR', event: 'AUDIT_WRITE_FAILED', message: err.message }));
  }
}
module.exports = audit;
