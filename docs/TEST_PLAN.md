# Runtime Test Plan

| ID | Area | Check | Expected result |
|---|---|---|---|
| T01 | Compose | `docker compose config` | Configuration is valid |
| T02 | Compose | `docker compose up -d --build` | All services start |
| T03 | Compose | `docker compose ps` | Main services are Up/healthy |
| T04 | Application | `curl.exe http://localhost:8088/api/health` | Healthy response and DB connected |
| T05 | Blog | Open `http://localhost:8088` | Published posts are displayed |
| T06 | Authentication | Login with an initialized account | CMS opens according to role |
| T07 | Posts | Create, update and delete a post | Changes are persisted |
| T08 | Categories | Create, update and delete a category | Operations follow relation rules |
| T09 | Users | Create user, change role, lock/unlock | Changes are persisted |
| T10 | Comments | Submit and moderate a comment | State changes correctly |
| T11 | Database | Open `http://localhost:8082` | phpMyAdmin connects to MySQL |
| T12 | Nginx | Open `http://localhost:8088` | Application is served through Nginx |
| T13 | Headers | `curl.exe -I http://localhost:8088` | Security headers are present |
| T14 | Prometheus | Open `/targets` on port 9090 | Main targets are UP |
| T15 | Grafana | Open port 3001 | Dashboard contains metrics |
| T16 | Loki | Query `{container="devblog-nginx"}` | Recent Nginx logs are returned |
| T17 | Loki | Query `{container="devblog-app"}` | Recent application logs are returned |
| T18 | Hardening | Inspect application user/filesystem/capabilities | Non-root, read-only and dropped capabilities |
| T19 | Networking | Inspect `devblog_backend` | `Internal: true` |
| T20 | Persistence | Restart stack without `-v` | Database data remains available |
