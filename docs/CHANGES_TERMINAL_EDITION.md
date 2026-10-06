# Terminal Edition — thay đổi so với bản trước

- Xóa toàn bộ `.bat`.
- README chuyển sang PowerShell/Windows Terminal.
- Bổ sung `docs/TERMINAL_COMMANDS.md`.
- Cập nhật MySQL Exporter sang `prom/mysqld-exporter:v0.20.0`.
- Bỏ cơ chế `DATA_SOURCE_NAME`; dùng `MYSQLD_EXPORTER_PASSWORD` + flags chính thức.
- Bổ sung user MySQL `exporter` riêng với least privilege.
- Bổ sung biến `MYSQL_EXPORTER_PASSWORD` trong `.env.example`.
- Bổ sung test utility bằng Node built-in test runner.
- Bổ sung sửa danh mục và đổi role người dùng trong CMS.
- GitHub Actions chạy syntax check + unit test + Compose config + rubric audit.
- Regenerate 10 checkpoint theo bản terminal.
