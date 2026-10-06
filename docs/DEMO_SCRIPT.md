# Demo Script — 8–12 phút

1. Mở GitHub: source, README, lịch sử commit.
2. Terminal: `docker compose ps` để chứng minh toàn bộ stack chạy.
3. Blog `http://localhost:8088`: trang chủ, search, category, bài chi tiết.
4. Login Admin: dashboard, tạo/sửa bài, danh mục, user, comment, audit log.
5. phpMyAdmin `:8081`: 7 bảng + dữ liệu.
6. Terminal: `curl.exe -I http://localhost:8088` để chỉ security headers.
7. Prometheus `:9090/targets`: chỉ các target `UP`.
8. Grafana `:3001`: dashboard web/container/database.
9. Grafana Explore/Loki: chạy 3 query trong `docs/LOGQL_QUERIES.md`.
10. Terminal hardening evidence: non-root, read-only, network internal, `.env` ignored.
11. Kết luận đối chiếu rubric.

Không dùng `.bat`; toàn bộ bằng terminal và giao diện dịch vụ.
