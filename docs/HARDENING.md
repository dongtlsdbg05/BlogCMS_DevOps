# System Hardening

Rubric yêu cầu tối thiểu 3–4 biện pháp. DevBlog CMS áp dụng nhiều lớp hơn mức tối thiểu.

1. **Non-root application container** — Dockerfile dùng `USER node`.
2. **Read-only application filesystem** — app dùng `read_only: true` và tmpfs nhỏ cho `/tmp`.
3. **Drop Linux capabilities** — app dùng `cap_drop: ALL`.
4. **No-new-privileges** — bật cho các container phù hợp.
5. **Network isolation** — backend, monitoring, logging là Docker internal networks.
6. **Database least privilege** — app dùng `DB_USER`, không dùng MySQL root.
7. **Exporter least privilege** — `exporter` chỉ được cấp `PROCESS`, `REPLICATION CLIENT`, `SELECT`.
8. **Secrets outside Git** — `.env` bị ignore; `.env.example` chỉ có placeholder.
9. **Password hashing** — PBKDF2-HMAC-SHA256 + random salt, 120,000 iterations.
10. **RBAC** — `ADMIN`, `EDITOR`, `USER`.
11. **Login rate limiting** — 5 lần/phút/client; có global request rate limit.
12. **Nginx security headers** — CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy.
13. **Nginx version suppression** — `server_tokens off`.
14. **Disable MySQL local file loading** — `--local-infile=0`.
15. **Admin UI local-only** — phpMyAdmin, Prometheus, Grafana bind `127.0.0.1`.
16. **Metrics hidden from public proxy** — `/metrics` trả 404 qua Nginx; Prometheus scrape nội bộ.
17. **Audit logging** — hành động CMS quan trọng ghi DB và stdout để Loki thu thập.

## Terminal evidence

```powershell
docker compose ps
curl.exe -I http://localhost:8088
docker compose exec app id
docker inspect devblog-app --format '{{json .HostConfig.ReadonlyRootfs}}'
docker inspect devblog-app --format '{{json .HostConfig.CapDrop}}'
docker network inspect devblog_backend
git check-ignore .env
```

## Scope

Đây là hardening phục vụ lab/course demo, không phải chứng nhận production. Nếu public Internet thực tế, cần bổ sung TLS CA-trusted, external session store, CSRF protection, backup/restore, secrets manager, firewall/host hardening và quy trình patching.
