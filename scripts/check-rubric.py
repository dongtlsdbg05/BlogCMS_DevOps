from pathlib import Path
import json, sys, re
import yaml

ROOT = Path(__file__).resolve().parents[1]
checks = []

def check(name, condition, detail=''):
    ok = bool(condition)
    checks.append((name, ok, detail))
    print(f"[{'PASS' if ok else 'FAIL'}] {name}" + (f" - {detail}" if detail else ''))

def text(rel):
    return (ROOT / rel).read_text(encoding='utf-8')

def exists(rel):
    return (ROOT / rel).exists()

compose_text = text('docker-compose.yml')
compose = yaml.safe_load(compose_text)
services = compose.get('services', {})

# 1 - repository / terminal packaging
bat_files = list(ROOT.rglob('*.bat'))
check('1. Repository + README + terminal-only packaging',
      exists('README.md') and exists('.github/workflows/validate.yml') and not bat_files and 'docker compose up -d' in text('README.md'),
      f'{len(bat_files)} .bat file(s)')

# 2 - app / CMS scope
admin = text('app/src/routes/admin.js')
public = text('app/src/routes/public.js')
check('2. Blog/CMS features: posts/categories/users/comments/RBAC',
      all(x in admin for x in ["/posts", "/categories", "/users", "/comments", "requireRole"]) and
      all(x in public for x in ["/post/:slug", "/category/:slug", "req.query.q"]),
      'public blog + CMS routes')

# 3 - MySQL / phpMyAdmin / schema
sql = text('mysql/init.sql')
check('3. MySQL + phpMyAdmin + 7-table schema',
      all(x in services for x in ['mysql','phpmyadmin']) and
      all(f'CREATE TABLE IF NOT EXISTS {x}' in sql for x in ['users','categories','posts','comments','tags','post_tags','audit_logs']),
      '7 required tables')

# 4 - Nginx
nginx = text('nginx/nginx.conf')
check('4. Nginx reverse proxy + security headers',
      'proxy_pass http://app:3000' in nginx and
      all(x in nginx for x in ['Content-Security-Policy','X-Frame-Options','X-Content-Type-Options','Referrer-Policy','Permissions-Policy','server_tokens off']),
      'proxy + headers')

# 5 - Prometheus targets
prom = text('prometheus/prometheus.yml')
check('5. Prometheus monitors web/container/host/database',
      all(x in prom for x in ['devblog-app','cadvisor','node-exporter','mysql-exporter']) and '/metrics' in text('app/server.js'),
      'app + cAdvisor + node + MySQL exporter')

# 6 - Grafana dashboard
board = json.loads(text('grafana/dashboards/devblog-overview.json'))
exprs = ' '.join(t.get('expr','') for p in board.get('panels',[]) for t in p.get('targets',[]))
check('6. Grafana provisioned dashboard covers web/container/database',
      len(board.get('panels',[])) >= 8 and 'devblog_http_requests_total' in exprs and 'container_cpu_usage_seconds_total' in exprs and 'mysql_global_status' in exprs,
      f"{len(board.get('panels',[]))} panels")

# 7 - Loki/Promtail/LogQL
logql = text('docs/LOGQL_QUERIES.md')
check('7. Loki + Promtail + >=3 LogQL queries',
      all(x in services for x in ['loki','promtail']) and logql.count('```logql') >= 3 and exists('promtail/promtail-config.yml'),
      f"{logql.count('```logql')} prepared queries")

# 8 - hardening
appsvc = services.get('app', {})
networks = compose.get('networks', {})
security_signals = [
    'USER node' in text('app/Dockerfile'),
    appsvc.get('read_only') is True,
    'ALL' in appsvc.get('cap_drop', []),
    any('no-new-privileges:true' == x for x in appsvc.get('security_opt', [])),
    networks.get('backend', {}).get('internal') is True,
    networks.get('monitoring', {}).get('internal') is True,
    networks.get('logging', {}).get('internal') is True,
    '.env' in text('.gitignore'),
    'MYSQLD_EXPORTER_PASSWORD' in compose_text and '--mysqld.username=exporter' in compose_text,
]
check('8. Hardening >=4 independent controls', sum(security_signals) >= 8, f'{sum(security_signals)} static controls detected')

# 9 - whole system compose packaging
required_services = ['app','mysql','phpmyadmin','nginx','prometheus','grafana','cadvisor','node-exporter','mysql-exporter','loki','promtail']
check('9. Whole system packaged with Docker Compose', all(x in services for x in required_services), f'{len(services)} services')

# 10 - evidence/report/testing + secret hygiene
checkpoints = all(exists(f'docs/CHECKPOINT_{i:02d}.txt') for i in range(1,11))
real_env_absent = not exists('.env')
check('10. Evidence/test/report preparation + secret hygiene',
      exists('docs/DEMO_SCRIPT.md') and exists('docs/REPORT_OUTLINE.md') and exists('docs/TEST_PLAN.md') and
      exists('screenshots/README.md') and exists('docs/TERMINAL_COMMANDS.md') and checkpoints and real_env_absent,
      '10 checkpoints + test/demo/report docs; .env absent')

failed = [c for c in checks if not c[1]]
print(f"\nResult: {len(checks)-len(failed)}/{len(checks)} rubric groups passed static validation.")
if failed:
    sys.exit(1)
