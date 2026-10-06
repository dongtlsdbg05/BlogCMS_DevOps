# Runtime Test Plan — Terminal Edition

Chỉ đánh dấu PASS sau khi chạy thật trên máy có Docker.

| ID | Nhóm | Kiểm thử | Lệnh/thao tác | Kỳ vọng |
|---|---|---|---|---|
| T01 | Compose | Validate config | `docker compose config` | không lỗi |
| T02 | Compose | Start stack | `docker compose up -d --build` | 11 service khởi động |
| T03 | Compose | Health/status | `docker compose ps` | service chính Up/healthy |
| T04 | App | Health API | `curl.exe http://localhost:8088/api/health` | healthy + DB connected |
| T05 | Blog | Trang chủ | mở `:8088` | bài seed hiển thị |
| T06 | Blog | Search/category | thao tác UI | kết quả đúng |
| T07 | Auth | Admin login | `admin / Admin@123!` | vào dashboard |
| T08 | RBAC | USER vào admin chức năng | đăng nhập `user01` | chức năng bị chặn theo role |
| T09 | Posts | Create/update/delete | CMS UI | CRUD hoạt động |
| T10 | Categories | Create/update/delete | CMS UI | CRUD hoạt động, không xóa category đang dùng |
| T11 | Users | Create/role/lock | CMS UI | cập nhật chính xác |
| T12 | Comments | Submit/moderate | Blog + CMS | pending -> approved/rejected |
| T13 | DB | phpMyAdmin | mở `:8081` | thấy 7 bảng |
| T14 | Nginx | Reverse proxy | truy cập `:8088` | app hoạt động qua Nginx |
| T15 | Security | Headers | `curl.exe -I http://localhost:8088` | security headers xuất hiện |
| T16 | Prometheus | Targets | mở `:9090/targets` | app/cAdvisor/node/mysql exporter UP |
| T17 | Grafana | Dashboard | mở `:3001` | dashboard có dữ liệu |
| T18 | Loki | App logs | Explore query `{container="devblog-app"}` | có log |
| T19 | LogQL | Auth query | query LOGIN/FAILED | có kết quả sau tạo traffic |
| T20 | LogQL | Content query | query CREATE/UPDATE/DELETE_POST | có kết quả |
| T21 | Hardening | Non-root | `docker compose exec app id` | uid không phải 0 |
| T22 | Hardening | Read-only | `docker inspect devblog-app ...` | `true` |
| T23 | Hardening | Network | inspect backend | `Internal: true` |
| T24 | Git | Secret hygiene | `git status`; `git check-ignore .env` | `.env` không tracked |
| T25 | Recovery | Restart stack | `docker compose down` rồi `up -d` | data vẫn còn |

## Reset test data

Chỉ dùng khi muốn chạy init/seed lại từ đầu:

```powershell
docker compose down -v --remove-orphans
docker compose up -d --build
```
