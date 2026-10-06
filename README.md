# DevBlog CMS — Terminal Edition

**Đề 7 – Hệ thống Blog / CMS**  
Môn: **Triển khai và Quản trị Hệ thống Phần mềm**

DevBlog CMS là website Blog/CMS tự viết bằng **Node.js + Express + EJS + MySQL**, triển khai toàn bộ hạ tầng bằng **Docker Compose** gồm Nginx, phpMyAdmin, Prometheus, Grafana, cAdvisor, Node Exporter, MySQL Exporter, Loki và Promtail.

> Bản này vận hành **100% qua Terminal/PowerShell**. Không có và không cần file `.bat`.

---

## 1. Bám sát tiêu chí đề tài

Project được thiết kế trực tiếp theo rubric:

1. Source + cấu hình + README để quản lý trên GitHub.
2. Blog/CMS + MySQL + phpMyAdmin.
3. Nginx reverse proxy + security headers.
4. Prometheus + Grafana giám sát web/container/database.
5. Loki + Promtail + tối thiểu 3 LogQL query.
6. Hardening: non-root, read-only, network isolation, least privilege, secrets, RBAC, rate limit, security headers...
7. Toàn bộ chạy bằng Docker Compose và có kế hoạch screenshot/demo/báo cáo.

Các lần đối chiếu rubric được lưu tại `docs/CHECKPOINT_01.txt` ... `docs/CHECKPOINT_10.txt`.

---

## 2. Tính năng Blog/CMS

### Public Blog
- Trang chủ bài viết đã xuất bản.
- Tìm kiếm theo tiêu đề/tóm tắt/nội dung.
- Lọc theo danh mục.
- Phân trang.
- Trang chi tiết bài viết.
- Hiển thị tác giả, ngày đăng, lượt xem.
- Bài liên quan.
- Bình luận thành viên/khách; bình luận mới chờ duyệt.

### CMS Admin
- Đăng nhập/đăng xuất.
- Dashboard thống kê.
- CRUD bài viết; trạng thái `DRAFT`, `PUBLISHED`, `HIDDEN`.
- Quản lý danh mục: tạo, sửa, xóa khi không được sử dụng.
- Quản lý người dùng: tạo, đổi vai trò, khóa/mở khóa.
- RBAC `ADMIN`, `EDITOR`, `USER`.
- Duyệt/từ chối bình luận.
- Audit log hành động quan trọng.

### Observability endpoint
- `GET /api/health`
- `GET /metrics`

---

## 3. Kiến trúc

```text
Browser
   |
   v
Nginx :8088
   |
   v
Node.js / Express Blog CMS :3000
   |
   v
MySQL :3306
   |
   +---- phpMyAdmin :8081 (localhost only)

Monitoring:
Prometheus <- App / cAdvisor / Node Exporter / MySQL Exporter
     |
     v
Grafana :3001

Logging:
Docker logs -> Promtail -> Loki -> Grafana Explore
```

Docker networks:
- `devblog_frontend`
- `devblog_backend` — internal
- `devblog_monitoring` — internal
- `devblog_logging` — internal

---

## 4. 11 Docker services

| Service | Vai trò | Host URL/port |
|---|---|---|
| `devblog-nginx` | Reverse proxy | `http://localhost:8088` |
| `devblog-app` | Blog/CMS | không public trực tiếp |
| `devblog-mysql` | Database | không public trực tiếp |
| `devblog-phpmyadmin` | DB management | `http://localhost:8081` |
| `devblog-prometheus` | Metrics | `http://localhost:9090` |
| `devblog-grafana` | Dashboard/Explore | `http://localhost:3001` |
| `devblog-cadvisor` | Container metrics | nội bộ |
| `devblog-node-exporter` | Docker VM/host metrics | nội bộ |
| `devblog-mysql-exporter` | MySQL metrics | nội bộ |
| `devblog-loki` | Log storage | nội bộ |
| `devblog-promtail` | Log collector | nội bộ |

---

## 5. Yêu cầu máy chạy

Windows 10/11 khuyến nghị:
- Docker Desktop, Linux containers mode.
- Git.
- PowerShell/Windows Terminal.
- Chrome/Edge.
- Docker có khoảng 4 GB RAM trở lên.

Không cần cài trực tiếp MySQL, phpMyAdmin, Nginx, Prometheus, Grafana hoặc Loki lên Windows.

Kiểm tra:

```powershell
docker --version
docker compose version
git --version
```

---

## 6. Chạy lần đầu — PowerShell/Terminal

Mở **PowerShell tại thư mục `BlogCMS_DevOps`**.

### Bước 1 — Tạo `.env`

```powershell
Copy-Item .env.example .env
```

Tạo secret ngẫu nhiên trực tiếp bằng PowerShell:

```powershell
function New-HexSecret {
    param([int]$Bytes = 24)
    $buffer = New-Object byte[] $Bytes
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($buffer)
    $rng.Dispose()
    return -join ($buffer | ForEach-Object { $_.ToString('x2') })
}

$content = Get-Content .env -Raw
$content = $content.Replace('CHANGE_ME_DB_PASSWORD',       ('db_' + (New-HexSecret 16)))
$content = $content.Replace('CHANGE_ME_ROOT_PASSWORD',     ('root_' + (New-HexSecret 20)))
$content = $content.Replace('CHANGE_ME_EXPORTER_PASSWORD', ('exp_' + (New-HexSecret 16)))
$content = $content.Replace('CHANGE_ME_SESSION_SECRET',    (New-HexSecret 32))
$content = $content.Replace('CHANGE_ME_GRAFANA_PASSWORD',  ('graf_' + (New-HexSecret 16)))
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText([string](Resolve-Path .env), $content, $utf8NoBom)
```

Kiểm tra đã hết placeholder:

```powershell
Select-String -Path .env -Pattern 'CHANGE_ME'
```

Lệnh trên **không được trả về dòng nào**.

### Bước 2 — Validate Compose

```powershell
docker compose config
```

Nếu không có lỗi, tiếp tục.

### Bước 3 — Pull image và build

```powershell
docker compose pull
docker compose build --no-cache app
```

### Bước 4 — Khởi động toàn bộ hệ thống

```powershell
docker compose up -d
```

### Bước 5 — Kiểm tra container

```powershell
docker compose ps
```

Mục tiêu: các service đều `Up`; service có healthcheck tiến tới `healthy`.

Nếu cần xem trạng thái liên tục:

```powershell
docker compose ps
Start-Sleep -Seconds 10
docker compose ps
```

---

## 7. URL demo

| Thành phần | URL |
|---|---|
| Blog | http://localhost:8088 |
| CMS login | http://localhost:8088/login |
| phpMyAdmin | http://localhost:8081 |
| Prometheus targets | http://localhost:9090/targets |
| Grafana | http://localhost:3001 |

### CMS seed accounts

```text
ADMIN
username: admin
password: Admin@123!

EDITOR
username: editor01
password: Editor@123!

USER
username: user01
password: User@123!
```

Chỉ dùng cho demo môn học; đổi/xóa nếu triển khai ngoài môi trường demo.

### phpMyAdmin
- Server: `mysql`
- Username: giá trị `DB_USER` trong `.env`
- Password: giá trị `DB_PASSWORD` trong `.env`

### Grafana
- Username: giá trị `GRAFANA_ADMIN_USER`.
- Password: giá trị `GRAFANA_ADMIN_PASSWORD` trong `.env`.

---

## 8. Kiểm tra hệ thống bằng Terminal

### Docker

```powershell
docker compose ps
docker compose images
```

### Health API

```powershell
curl.exe http://localhost:8088/api/health
```

Kỳ vọng có `"status":"healthy"` và `"database":"connected"`.

### Nginx security headers

```powershell
curl.exe -I http://localhost:8088
```

Kiểm tra có các header:
- `Content-Security-Policy`
- `X-Frame-Options`
- `X-Content-Type-Options`
- `Referrer-Policy`
- `Permissions-Policy`

### Kiểm tra app không public trực tiếp

```powershell
Test-NetConnection localhost -Port 3000
```

Port 3000 của app không được publish từ Compose.

### Kiểm tra MySQL qua container

```powershell
docker compose exec mysql sh -lc 'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;"'
```

Lệnh dùng chính biến môi trường bên trong container MySQL, không cần nạp `.env` vào PowerShell.

### Prometheus

Mở:

```text
http://localhost:9090/targets
```

Các target chính cần `UP`:
- `devblog-app`
- `cadvisor`
- `node-exporter`
- `mysql-exporter`
- `prometheus`

### Grafana

Dashboard được provision tự động:

```text
DevBlog CMS - System Overview
```

Cần có web metrics, HTTP status/latency, container CPU/RAM và MySQL metrics.

### Loki + Promtail

Tạo traffic trước:
1. Mở Blog.
2. Login đúng/sai vài lần.
3. Tạo/sửa bài viết.

Sau đó vào:

```text
Grafana -> Explore -> Loki
```

Query mẫu:

```logql
{container="devblog-app"}
```

```logql
{container="devblog-app"} |~ "LOGIN|LOGIN_FAILED|LOGOUT"
```

```logql
{container="devblog-app"} |~ "CREATE_POST|UPDATE_POST|DELETE_POST"
```

Có 5 query chuẩn trong `docs/LOGQL_QUERIES.md`.

---

## 9. Database

Database mặc định: `blogcms`

7 bảng:
- `users`
- `categories`
- `posts`
- `comments`
- `tags`
- `post_tags`
- `audit_logs`

Seed có tài khoản demo, 8 danh mục, tag, bài viết và bình luận.

MySQL Exporter dùng tài khoản riêng `exporter` chỉ có các quyền cần cho monitoring (`PROCESS`, `REPLICATION CLIENT`, `SELECT`). Ứng dụng dùng `DB_USER`, không dùng root.

---

## 10. Nginx

Nginx nhận request ở `localhost:8088` và proxy nội bộ tới `app:3000`.

Đã cấu hình:
- Reverse proxy.
- Security headers.
- `server_tokens off`.
- Request rate limiting.
- `/metrics` không public qua Nginx.

---

## 11. Monitoring

Prometheus scrape:
- `app:3000/metrics`
- `cadvisor:8080`
- `node-exporter:9100`
- `mysql-exporter:9104`
- `prometheus:9090`

Grafana provision sẵn Prometheus + Loki datasource và dashboard tổng quan.

> Trên Docker Desktop Windows, Node Exporter quan sát Linux VM của Docker Desktop, không phải toàn bộ Windows host. cAdvisor là phần chính cho container metrics.

---

## 12. Logging

Luồng:

```text
Docker logs -> Promtail -> Loki -> Grafana Explore
```

Project giữ **Promtail** vì rubric môn học yêu cầu trực tiếp Loki + Promtail. Với hệ thống production mới, nên cân nhắc agent được Grafana hỗ trợ hiện hành.

---

## 13. Hardening

Các biện pháp đã có:
1. Node app chạy non-root.
2. App filesystem `read_only`.
3. App `cap_drop: ALL`.
4. `no-new-privileges`.
5. Network isolation.
6. DB app user riêng.
7. MySQL exporter user riêng.
8. `.env` không commit Git.
9. PBKDF2 password hashing + random salt.
10. RBAC.
11. Login/global rate limit.
12. Nginx security headers.
13. `server_tokens off`.
14. MySQL `local-infile=0`.
15. Admin UIs chỉ bind `127.0.0.1`.
16. `/metrics` không public qua Nginx.
17. Audit logs.

Chi tiết: `docs/HARDENING.md`.

---

## 14. Không dùng `.bat` — lệnh quản trị project

### Start

```powershell
docker compose up -d
```

### Stop

```powershell
docker compose down
```

### Restart một service

```powershell
docker compose restart app
```

### Rebuild app sau khi sửa code

```powershell
docker compose up -d --build app
```

### Xem log realtime

```powershell
docker compose logs -f app
```

Các service khác:

```powershell
docker compose logs -f nginx
docker compose logs -f mysql
docker compose logs -f prometheus
docker compose logs -f grafana
docker compose logs -f loki
docker compose logs -f promtail
docker compose logs -f mysql-exporter
```

### Reset hoàn toàn database/volume

> CẢNH BÁO: xóa dữ liệu persistent.

```powershell
docker compose down -v --remove-orphans
docker compose up -d --build
```

### Xóa container/image rác của project

```powershell
docker compose down --remove-orphans
docker image prune -f
```

---

## 15. Kiểm tra source trước khi nộp

Nếu máy có Node.js/Python:

```powershell
cd app
npm install
npm run validate
cd ..
python scripts/check-rubric.py
```

Sau đó validate Compose:

```powershell
docker compose config
```

---

## 16. Git/GitHub

Khởi tạo repo:

```powershell
git init
git branch -M main
git status
```

Không commit `.env`.

Kế hoạch commit nằm trong `docs/GIT_COMMIT_PLAN.md`. Các mốc đề bài cần thể hiện rõ:

```text
feat: configure nginx reverse proxy and security headers
feat: integrate prometheus grafana and exporters
feat: integrate loki promtail centralized logging
```

---

## 17. Screenshot/minh chứng

Checklist: `screenshots/README.md`.

Chỉ chụp từ hệ thống chạy thật:
- Blog/CMS.
- phpMyAdmin.
- `docker compose ps`.
- Nginx headers.
- Prometheus Targets.
- Grafana dashboard.
- 3+ LogQL queries.
- Hardening evidence.
- GitHub commit history.

---

## 18. Báo cáo

Khung: `docs/REPORT_OUTLINE.md`.

Nên trình bày:
- Tổng quan + kiến trúc.
- Blog/CMS + MySQL.
- Docker Compose.
- Nginx.
- Prometheus/Grafana.
- Loki/Promtail/LogQL.
- Hardening.
- GitHub.
- Kiểm thử.
- Screenshot minh chứng.
- Đối chiếu rubric.

---

## 19. Troubleshooting

### Docker chưa chạy

```powershell
docker info
```

Nếu lỗi, mở Docker Desktop và chờ engine sẵn sàng.

### Port bị chiếm

```powershell
netstat -ano | findstr :8088
netstat -ano | findstr :8081
netstat -ano | findstr :9090
netstat -ano | findstr :3001
```

Đổi port phía trái trong `docker-compose.yml` nếu cần.

### Xem service lỗi

```powershell
docker compose ps -a
docker compose logs --tail 200 <service>
```

Ví dụ:

```powershell
docker compose logs --tail 200 mysql-exporter
```

### Seed DB không chạy lại

`docker-entrypoint-initdb.d` chỉ chạy khi volume MySQL mới. Reset:

```powershell
docker compose down -v
docker compose up -d --build
```

### MySQL exporter DOWN

```powershell
docker compose logs --tail 200 mysql-exporter
docker compose logs --tail 200 mysql
```

Đảm bảo `.env` có `MYSQL_EXPORTER_PASSWORD` và database đã được tạo từ volume mới sau khi thay đổi init scripts.

---

## 20. Cấu trúc repository

```text
BlogCMS_DevOps/
├── app/
│   ├── public/
│   ├── src/
│   ├── test/
│   ├── Dockerfile
│   └── package.json
├── mysql/
│   ├── init.sql
│   └── 02-create-exporter.sh
├── nginx/
├── prometheus/
├── grafana/
├── loki/
├── promtail/
├── scripts/
│   └── check-rubric.py
├── docs/
├── screenshots/
├── .github/workflows/
├── docker-compose.yml
├── .env.example
├── .gitignore
└── README.md
```

---

## 21. Trạng thái xác minh

Package được static-validate bằng:
- `node --check`.
- `node --test` cho utility tests.
- parse JSON/YAML.
- kiểm tra EJS delimiter.
- static rubric audit 10 nhóm.
- kiểm tra không còn `.bat`.
- kiểm tra không đóng gói `.env`/secret thật.

Môi trường tạo package không có Docker daemon, vì vậy **runtime Docker cuối cùng phải được xác nhận trên máy có Docker Desktop** bằng các lệnh terminal trong README và `docs/TEST_PLAN.md`. Không coi screenshot giả lập là minh chứng.
