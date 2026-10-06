# Rubric checklist — Đề 7: Hệ thống Blog / CMS

## Thang điểm gốc cần đối chiếu

| Nhóm | Điểm | Minh chứng project |
|---|---:|---|
| GitHub | 1.5 | source + config + README + commit có ý nghĩa |
| App + Database | 1.5 | Blog/CMS + MySQL + phpMyAdmin |
| Nginx Reverse Proxy | 1.5 | reverse proxy + security headers |
| Prometheus + Grafana | 1.5 | web/container/database metrics + dashboard |
| Loki | 1.5 | Loki + Promtail + >= 3 LogQL demo |
| Hardening | 1.5 | >= 3-4 biện pháp; project áp dụng nhiều hơn |
| Tổng thể & trình bày | 1.0 | Docker Compose + demo + screenshot + hiểu hệ thống |
| **Tổng** | **10.0** | |

Ngoài ra: báo cáo tối thiểu 10 trang và tất cả dịch vụ triển khai bằng Docker Compose.

## Checklist trước khi nộp

- [ ] GitHub repository chứa source + config; không có `.env`.
- [ ] Lịch sử commit rõ và có các mốc Nginx / Monitoring / Logging.
- [ ] Blog/CMS chạy: bài viết, danh mục, người dùng.
- [ ] MySQL + phpMyAdmin chạy và thấy 7 bảng.
- [ ] Website truy cập qua Nginx.
- [ ] Security headers xuất hiện khi `curl.exe -I`.
- [ ] Prometheus targets web/container/database đều UP.
- [ ] Grafana dashboard có dữ liệu thật.
- [ ] Loki + Promtail có log thật.
- [ ] Chạy được >= 3 LogQL query và chụp minh chứng.
- [ ] Hardening có minh chứng terminal.
- [ ] `docker compose ps` cho thấy stack chạy hoàn chỉnh.
- [ ] Screenshot đủ.
- [ ] Báo cáo >= 10 trang, có hình và mô tả kết quả.

## 10 checkpoint bắt buộc

1. Architecture and scope.
2. Database.
3. Blog/CMS application.
4. Docker Compose.
5. Nginx reverse proxy.
6. Prometheus + Grafana.
7. Loki + Promtail.
8. Hardening.
9. Terminal packaging + README + Git workflow.
10. Final rubric audit.
