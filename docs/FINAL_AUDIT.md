# Final Audit

## Static package status

- Blog/CMS source present.
- MySQL schema + seed present.
- Separate MySQL exporter account init present.
- Nginx reverse proxy + security headers present.
- Prometheus targets include app/container/host/database.
- Grafana provisioning/dashboard present.
- Loki + Promtail config present.
- >= 3 LogQL queries documented.
- Hardening controls present.
- README uses terminal workflow; `.bat` files removed.
- `.env` is not included.
- 10 rubric checkpoints present.

## Runtime boundary

Môi trường đóng gói không có Docker daemon nên không được tuyên bố giả rằng container đã chạy tại đây. Trước khi nộp, phải chạy `docs/TEST_PLAN.md` trên máy có Docker Desktop và lấy screenshot thật.
