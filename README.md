# DevBlog CMS

Hệ thống Blog/CMS được xây dựng bằng **Node.js, Express, EJS và MySQL**, triển khai toàn bộ bằng **Docker Compose**. Project được tổ chức theo các nhóm chức năng rõ ràng gồm **Backend, Frontend, Database, Infrastructure, Documentation và CI/CD**, giúp dễ phát triển, vận hành, kiểm thử và bảo trì.

---
## 1. Tổng quan

DevBlog CMS gồm hai khu vực chính:

- **Blog công khai**: hiển thị bài viết, chuyên mục, tìm kiếm và bình luận.
- **CMS quản trị**: quản lý bài viết, chuyên mục, người dùng, bình luận và nhật ký hoạt động.

Hệ thống sử dụng Nginx làm reverse proxy, MySQL làm cơ sở dữ liệu, Prometheus và Grafana cho monitoring, Loki và Promtail cho logging tập trung.

Luồng truy cập chính:

```text
Trình duyệt
    |
    v
Nginx :8088
    |
    v
Node.js / Express :3000
    |
    v
MySQL :3306
```

Luồng monitoring:

```text
Application --------\
cAdvisor ------------\
Node Exporter --------> Prometheus ---> Grafana
MySQL Exporter -------/
```

Luồng logging:

```text
Docker Logs ---> Promtail ---> Loki ---> Grafana Explore
```

---

## 2. Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Backend | Node.js 22, Express 5 |
| Template engine | EJS |
| Database | MySQL 8.4 |
| Database driver | mysql2 |
| Authentication | express-session |
| Password hashing | PBKDF2 + SHA-256 |
| Security middleware | Helmet, express-rate-limit |
| Reverse proxy | Nginx 1.27 |
| Container platform | Docker, Docker Compose |
| Metrics | Prometheus |
| Dashboard | Grafana |
| Container monitoring | cAdvisor |
| Host metrics | Node Exporter |
| Database metrics | MySQL Exporter |
| Log storage | Loki |
| Log collector | Promtail |
| CI/CD validation | GitHub Actions |
| Testing | Node.js Test Runner |

---

## 3. Kiến trúc hệ thống

Project được chia thành các vùng độc lập:

```text
Frontend
   |
   | EJS templates + CSS + static assets
   v
Backend
   |
   | Express routes / middleware / services
   v
Database
   |
   | MySQL
   v
Infrastructure
   |
   | Nginx / Prometheus / Grafana / Loki / Promtail
```

### Docker network

| Network | Vai trò |
|---|---|
| `devblog_frontend` | Kết nối Nginx và application |
| `devblog_backend` | Kết nối application với MySQL và database monitoring |
| `devblog_monitoring` | Kết nối Prometheus với các exporter |
| `devblog_logging` | Kết nối Promtail và Loki |
| `devblog_management` | Phục vụ các giao diện quản trị truy cập từ host |

`backend`, `monitoring` và `logging` được cấu hình `internal: true` để giảm truy cập không cần thiết từ bên ngoài.

---

## 4. Chức năng chính

### 4.1. Blog công khai

- Hiển thị danh sách bài viết đã xuất bản.
- Tìm kiếm theo nội dung.
- Lọc bài viết theo chuyên mục.
- Phân trang.
- Xem chi tiết bài viết.
- Hiển thị tác giả, ngày đăng và lượt xem.
- Hiển thị bài viết liên quan.
- Gửi bình luận.
- Bình luận mới được đưa vào trạng thái chờ duyệt.

### 4.2. CMS quản trị

- Đăng nhập và đăng xuất.
- Dashboard thống kê.
- Quản lý bài viết.
- Tạo, chỉnh sửa, xuất bản, ẩn và xóa bài viết.
- Quản lý chuyên mục.
- Quản lý người dùng.
- Phân quyền theo vai trò.
- Khóa và mở khóa tài khoản.
- Duyệt hoặc từ chối bình luận.
- Xem nhật ký hoạt động quản trị.

### 4.3. Vai trò người dùng

| Vai trò | Quyền chính |
|---|---|
| `ADMIN` | Toàn quyền quản trị |
| `EDITOR` | Quản lý bài viết và bình luận |
| `USER` | Sử dụng các chức năng người dùng thông thường |

---

# 5. Cấu trúc project và chức năng từng file

```text
BlogCMS_DevOps/
│
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   │
│   ├── src/
│   │   ├── config/
│   │   │   └── db.js
│   │   │
│   │   ├── middleware/
│   │   │   ├── auth.js
│   │   │   └── logger.js
│   │   │
│   │   ├── routes/
│   │   │   ├── public.js
│   │   │   ├── auth.js
│   │   │   └── admin.js
│   │   │
│   │   ├── services/
│   │   │   └── audit.js
│   │   │
│   │   └── utils/
│   │       ├── password.js
│   │       └── slug.js
│   │
│   └── test/
│       └── utils.test.js
│
├── frontend/
│   ├── public/
│   │   ├── css/
│   │   │   └── style.css
│   │   │
│   │   └── images/
│   │       ├── database.svg
│   │       ├── docker.svg
│   │       ├── logging.svg
│   │       ├── monitoring.svg
│   │       ├── nginx.svg
│   │       └── security.svg
│   │
│   └── views/
│       ├── auth/
│       │   └── login.ejs
│       │
│       ├── public/
│       │   ├── home.ejs
│       │   ├── post.ejs
│       │   ├── category.ejs
│       │   └── error.ejs
│       │
│       ├── admin/
│       │   ├── dashboard.ejs
│       │   ├── posts.ejs
│       │   ├── post-form.ejs
│       │   ├── categories.ejs
│       │   ├── users.ejs
│       │   ├── comments.ejs
│       │   └── audit.ejs
│       │
│       └── partials/
│           ├── public-header.ejs
│           ├── public-footer.ejs
│           ├── admin-header.ejs
│           └── admin-footer.ejs
│
├── database/
│   ├── init.sql
│   └── create-exporter.sh
│
├── infrastructure/
│   ├── nginx/
│   │   └── nginx.conf
│   ├── prometheus/
│   │   └── prometheus.yml
│   ├── grafana/
│   │   ├── dashboards/
│   │   │   └── devblog-overview.json
│   │   └── provisioning/
│   │       ├── dashboards/
│   │       │   └── dashboards.yml
│   │       └── datasources/
│   │           └── datasources.yml
│   ├── loki/
│   │   └── loki-config.yml
│   └── promtail/
│       └── promtail-config.yml
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DATABASE.md
│   ├── HARDENING.md
│   ├── LOGQL_QUERIES.md
│   └── TEST_PLAN.md
│
├── .github/
│   └── workflows/
│       └── validate.yml
│
├── .dockerignore
├── .editorconfig
├── .env.example
├── .gitignore
├── docker-compose.yml
└── README.md
```

## 5.1. Backend

### `backend/Dockerfile`

Định nghĩa image cho application Node.js.

File này:

- sử dụng `node:22-alpine`;
- cài dependencies;
- copy backend và frontend vào image;
- chạy application bằng user `node`;
- expose cổng `3000`;
- healthcheck tới `/api/health`;
- khởi động bằng `node server.js`.

### `backend/package.json`

Khai báo dependencies và các script:

```powershell
npm start
npm test
npm run check
npm run validate
```

### `backend/server.js`

Entry point của application.

Chức năng:

- đọc biến môi trường;
- khởi tạo Express;
- cấu hình EJS;
- phục vụ static files;
- cấu hình session;
- kích hoạt Helmet;
- cấu hình rate limiting;
- gắn request logger;
- tạo Prometheus metrics;
- cung cấp `/api/health`;
- cung cấp `/metrics`;
- đăng ký auth/admin/public routes;
- xử lý lỗi 404 và 500;
- khởi động server tại cổng `3000`.

### `backend/src/config/db.js`

Tạo MySQL connection pool bằng `mysql2/promise`, sử dụng `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` và charset `utf8mb4`.

### `backend/src/middleware/auth.js`

Middleware xác thực và phân quyền:

- `exposeUser`;
- `requireAuth`;
- `requireRole`.

### `backend/src/middleware/logger.js`

Ghi access log JSON gồm thời gian, method, path, status, thời gian xử lý, user và IP. Log này được Docker thu thập để Promtail gửi sang Loki.

### `backend/src/routes/public.js`

Xử lý Blog công khai:

- trang chủ;
- chi tiết bài viết;
- bình luận;
- trang chuyên mục.

### `backend/src/routes/auth.js`

Xử lý đăng nhập, giới hạn login, tạo session và logout.

### `backend/src/routes/admin.js`

Xử lý toàn bộ CMS:

- dashboard;
- bài viết;
- chuyên mục;
- tài khoản;
- role;
- khóa/mở khóa user;
- bình luận;
- audit log.

### `backend/src/services/audit.js`

Ghi hoạt động quản trị vào bảng `audit_logs` và application log.

### `backend/src/utils/password.js`

Hash/verify password bằng PBKDF2 + SHA-256 + random salt và `timingSafeEqual`.

### `backend/src/utils/slug.js`

Chuyển tiêu đề tiếng Việt thành URL slug an toàn.

### `backend/test/utils.test.js`

Unit test cho password utility và slug utility.

---

## 5.2. Frontend

Frontend sử dụng **EJS server-side rendering**, không phải SPA riêng biệt. Express render EJS và phục vụ static assets từ `frontend/public`.

### `frontend/public/css/style.css`

Stylesheet chính của Blog và CMS.

### `frontend/public/images/*.svg`

| File | Vai trò |
|---|---|
| `database.svg` | Minh họa database |
| `docker.svg` | Minh họa Docker |
| `logging.svg` | Minh họa logging |
| `monitoring.svg` | Minh họa monitoring |
| `nginx.svg` | Minh họa reverse proxy |
| `security.svg` | Minh họa security |

### `frontend/views/auth/login.ejs`

Trang đăng nhập CMS.

### `frontend/views/public/home.ejs`

Trang chủ Blog, tìm kiếm, danh sách bài viết và chuyên mục.

### `frontend/views/public/post.ejs`

Chi tiết bài viết, metadata, bình luận và bài liên quan.

### `frontend/views/public/category.ejs`

Danh sách bài viết theo chuyên mục.

### `frontend/views/public/error.ejs`

Trang lỗi 403/404/500.

### `frontend/views/admin/dashboard.ejs`

Dashboard CMS với các thống kê chính.

### `frontend/views/admin/posts.ejs`

Danh sách và thao tác quản lý bài viết.

### `frontend/views/admin/post-form.ejs`

Form tạo/chỉnh sửa bài viết.

### `frontend/views/admin/categories.ejs`

Quản lý chuyên mục.

### `frontend/views/admin/users.ejs`

Quản lý tài khoản, role và trạng thái khóa.

### `frontend/views/admin/comments.ejs`

Duyệt và từ chối bình luận.

### `frontend/views/admin/audit.ejs`

Hiển thị nhật ký hoạt động quản trị.

### `frontend/views/partials/public-header.ejs`

Header dùng chung cho Blog.

### `frontend/views/partials/public-footer.ejs`

Footer dùng chung cho Blog.

### `frontend/views/partials/admin-header.ejs`

Header/sidebar CMS và menu theo role.

### `frontend/views/partials/admin-footer.ejs`

Footer CMS.

---

## 5.3. Database

### `database/init.sql`

Khởi tạo schema và dữ liệu ban đầu cho MySQL.

Database chính:

```text
blogcms
```

Các bảng:

```text
users
categories
posts
comments
tags
post_tags
audit_logs
```

### `database/create-exporter.sh`

Tạo tài khoản MySQL dành riêng cho MySQL Exporter.

---

## 5.4. Infrastructure

### `infrastructure/nginx/nginx.conf`

Cấu hình:

- reverse proxy tới `app:3000`;
- security headers;
- rate limit;
- `server_tokens off`;
- access log stdout;
- `/nginx-health`;
- chặn public `/metrics`.

### `infrastructure/prometheus/prometheus.yml`

Scrape:

```text
prometheus:9090
app:3000/metrics
cadvisor:8080
node-exporter:9100
mysql-exporter:9104
```

### `infrastructure/grafana/dashboards/devblog-overview.json`

Dashboard Grafana được provision sẵn.

### `infrastructure/grafana/provisioning/dashboards/dashboards.yml`

Tự động load dashboard khi Grafana khởi động.

### `infrastructure/grafana/provisioning/datasources/datasources.yml`

Tự động khai báo Prometheus và Loki datasource.

### `infrastructure/loki/loki-config.yml`

Cấu hình Loki với TSDB, filesystem storage, retention 7 ngày và compactor.

### `infrastructure/promtail/promtail-config.yml`

Phát hiện Docker container, gắn label `container`, `image`, `service`, parse Docker log và gửi tới Loki.

---

## 5.5. Documentation

### `docs/ARCHITECTURE.md`

Mô tả kiến trúc application, monitoring, logging và network.

### `docs/DATABASE.md`

Mô tả database, bảng, quan hệ và tài khoản DB.

### `docs/HARDENING.md`

Mô tả các biện pháp bảo mật hệ thống.

### `docs/LOGQL_QUERIES.md`

Danh sách truy vấn LogQL.

### `docs/TEST_PLAN.md`

Danh sách kiểm thử runtime cho toàn hệ thống.

---

## 5.6. CI/CD và file cấu hình gốc

### `.github/workflows/validate.yml`

Workflow GitHub Actions chạy khi push/pull request để validate backend và Docker Compose.

### `.env.example`

Template biến môi trường, không chứa secret thật.

### `.gitignore`

Loại `.env`, dependencies, log và dữ liệu runtime khỏi Git.

### `.dockerignore`

Loại file không cần thiết khỏi Docker build context.

### `.editorconfig`

Chuẩn hóa UTF-8, line ending và indentation.

### `docker-compose.yml`

File triển khai trung tâm của toàn hệ thống, quản lý 11 services, volumes, networks, healthcheck, environment và port mapping.

### `README.md`

Tài liệu chính của repository.

---

# 6. Các service Docker

| Service | Container | Chức năng | Host |
|---|---|---|---|
| Application | `devblog-app` | Express Blog/CMS | Internal `3000` |
| MySQL | `devblog-mysql` | Database | Không public |
| Nginx | `devblog-nginx` | Reverse proxy | `8088` |
| phpMyAdmin | `devblog-phpmyadmin` | Database UI | `127.0.0.1:8082` |
| Prometheus | `devblog-prometheus` | Metrics | `127.0.0.1:9090` |
| Grafana | `devblog-grafana` | Dashboard | `127.0.0.1:3001` |
| cAdvisor | `devblog-cadvisor` | Container metrics | Internal |
| Node Exporter | `devblog-node-exporter` | System metrics | Internal |
| MySQL Exporter | `devblog-mysql-exporter` | DB metrics | Internal |
| Loki | `devblog-loki` | Log storage | Internal |
| Promtail | `devblog-promtail` | Log collector | Internal |

---

# 7. Yêu cầu môi trường

- Windows 10/11;
- Docker Desktop;
- Docker Compose v2;
- Git;
- PowerShell hoặc VS Code Terminal;
- Chrome/Edge.

Kiểm tra:

```powershell
docker --version
docker compose version
git --version
```

Không cần cài trực tiếp MySQL, phpMyAdmin, Nginx, Prometheus, Grafana, Loki hoặc Promtail trên Windows.

---

# 8. Hướng dẫn cài đặt và khởi chạy

## 8.1. Clone

```powershell
git clone https://github.com/dongtlsdbg05/BlogCMS_DevOps.git
cd BlogCMS_DevOps
```

## 8.2. Tạo `.env`

```powershell
Copy-Item .env.example .env
```

Thay các giá trị `CHANGE_ME_*`.

```env
APP_NAME=DevBlog CMS
NODE_ENV=production

DB_NAME=blogcms
DB_USER=blog_user
DB_PASSWORD=CHANGE_ME_DB_PASSWORD
MYSQL_ROOT_PASSWORD=CHANGE_ME_ROOT_PASSWORD
MYSQL_EXPORTER_PASSWORD=CHANGE_ME_EXPORTER_PASSWORD

SESSION_SECRET=CHANGE_ME_SESSION_SECRET

GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=CHANGE_ME_GRAFANA_PASSWORD
```

Kiểm tra:

```powershell
Select-String -Path .env -Pattern 'CHANGE_ME'
```

## 8.3. Validate Compose

```powershell
docker compose config
```

## 8.4. Pull và build

```powershell
docker compose pull
docker compose build app
```

## 8.5. Start

```powershell
docker compose up -d
```

## 8.6. Kiểm tra

```powershell
docker compose ps
```

---

# 9. Các địa chỉ truy cập

| Thành phần | URL |
|---|---|
| Blog | http://localhost:8088 |
| CMS Login | http://localhost:8088/login |
| Health API | http://localhost:8088/api/health |
| phpMyAdmin | http://localhost:8082 |
| Prometheus | http://localhost:9090 |
| Prometheus Targets | http://localhost:9090/targets |
| Grafana | http://localhost:3001 |

Các tab thường dùng:

```text
DevBlog
CMS
phpMyAdmin
Prometheus
Grafana Dashboard
Grafana Explore / Loki
```

---

# 10. Tài khoản khởi tạo

## CMS

| Role | Username | Password |
|---|---|---|
| ADMIN | `admin` | `Admin@123!` |
| EDITOR | `editor01` | `Editor@123!` |
| USER | `user01` | `User@123!` |

## phpMyAdmin

```text
Server: mysql
Username: DB_USER trong .env
Password: DB_PASSWORD trong .env
```

## Grafana

```text
Username: GRAFANA_ADMIN_USER trong .env
Password: GRAFANA_ADMIN_PASSWORD trong .env
```

---

# 11. Kiểm tra hệ thống sau khi khởi động

## Health API

```powershell
curl.exe http://localhost:8088/api/health
```

## Nginx headers

```powershell
curl.exe -I http://localhost:8088
```

Kiểm tra:

```text
Content-Security-Policy
X-Frame-Options
X-Content-Type-Options
Referrer-Policy
Permissions-Policy
```

## MySQL

```powershell
docker compose exec mysql sh -lc 'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;"'
```

## Docker

```powershell
docker compose ps
```

---

# 12. Monitoring với Prometheus và Grafana

Prometheus:

```text
http://localhost:9090/targets
```

Các target chính cần `UP`:

```text
prometheus
devblog-app
cadvisor
node-exporter
mysql-exporter
```

Grafana:

```text
http://localhost:3001
```

Dashboard:

```text
DevBlog CMS - System Overview
```

---

# 13. Logging với Loki và Promtail

Mở:

```text
Grafana → Explore → Loki
```

```logql
{container="devblog-nginx"}
```

```logql
{container="devblog-app"}
```

```logql
{container="devblog-app"} |= "\"level\":\"ERROR\""
```

```logql
{container="devblog-app"} |~ "LOGIN|LOGIN_FAILED|LOGOUT"
```

```logql
{container="devblog-nginx"} |~ " (4|5)[0-9]{2} "
```

Tạo request 404:

```powershell
curl.exe -i http://localhost:8088/duong-dan-khong-ton-tai
```

---

# 14. Hardening và bảo mật

- application chạy non-root;
- app filesystem read-only;
- `cap_drop: ALL`;
- `no-new-privileges`;
- network isolation;
- MySQL không public cổng 3306;
- DB account riêng cho application;
- account riêng cho exporter;
- `.env` không commit;
- PBKDF2 password hashing;
- RBAC;
- rate limiting;
- Nginx security headers;
- `server_tokens off`;
- `local-infile=0`;
- phpMyAdmin, Prometheus, Grafana bind localhost;
- `/metrics` không public qua Nginx;
- audit log.

Kiểm tra:

```powershell
docker inspect devblog-app --format='User={{.Config.User}} ReadOnly={{.HostConfig.ReadonlyRootfs}}'
docker inspect devblog-app --format='{{json .HostConfig.CapDrop}}'
docker inspect devblog-app --format='{{json .HostConfig.SecurityOpt}}'
docker network inspect devblog_backend
docker port devblog-mysql
docker inspect devblog-phpmyadmin --format='{{json .HostConfig.PortBindings}}'
```

---

# 15. Các lệnh quản trị thường dùng

```powershell
docker compose up -d
docker compose down
docker compose restart app
docker compose up -d --build app
docker compose ps
docker compose ps -a
```

Log:

```powershell
docker compose logs -f app
docker compose logs -f nginx
docker compose logs -f mysql
docker compose logs -f prometheus
docker compose logs -f grafana
docker compose logs -f loki
docker compose logs -f promtail
```

---

# 16. Xử lý lỗi thường gặp

Kiểm tra port:

```powershell
netstat -ano | findstr :8088
netstat -ano | findstr :8082
netstat -ano | findstr :9090
netstat -ano | findstr :3001
```

phpMyAdmin:

```powershell
docker compose ps -a phpmyadmin
docker compose logs --tail 100 phpmyadmin
```

Nginx:

```powershell
docker compose ps -a nginx
docker compose logs --tail 100 nginx
```

Service lỗi:

```powershell
docker compose ps -a
docker compose logs --tail 200 <service>
```

Loki không có log:

```powershell
docker compose logs --tail 100 promtail
docker compose exec promtail cat /etc/promtail/config.yml
curl.exe http://localhost:8088/
curl.exe http://localhost:8088/api/health
```

Reset volume:

```powershell
docker compose down -v --remove-orphans
docker compose up -d --build
```

> Không chạy `down -v` nếu cần giữ dữ liệu MySQL.

---

# 17. Git và kiểm tra source

```powershell
git status
git log --oneline --decorate -10
git remote -v
```

Repository:

```text
https://github.com/dongtlsdbg05/BlogCMS_DevOps
```

Kiểm tra `.env`:

```powershell
git check-ignore -v .env
git ls-files .env
```

Backend validation:

```powershell
cd backend
npm install
npm run validate
cd ..
```

Compose validation:

```powershell
docker compose config
```

---
