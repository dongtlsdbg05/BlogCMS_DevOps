# Database Design

Database mặc định: `blogcms` (MySQL 8.4 image).

## Core tables

- `users`
- `categories`
- `posts`
- `comments`
- `tags`
- `post_tags`
- `audit_logs`

## Relationships

- users 1-N posts
- users 1-N comments
- categories 1-N posts
- posts 1-N comments
- posts N-N tags through post_tags
- users 1-N audit_logs

## Accounts

- Application user: do official MySQL image tạo qua `MYSQL_USER` / `MYSQL_PASSWORD`; app không dùng root.
- Exporter user: `mysql/02-create-exporter.sh` tạo riêng `exporter` và chỉ cấp `PROCESS`, `REPLICATION CLIENT`, `SELECT` phục vụ monitoring.
- Root: chỉ dùng quản trị/khởi tạo, không dùng bởi ứng dụng.
