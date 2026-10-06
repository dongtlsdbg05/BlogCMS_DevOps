# System Hardening

The stack applies multiple defensive controls:

1. The Node.js application runs as the non-root `node` user.
2. The application container uses a read-only root filesystem.
3. Linux capabilities are dropped with `cap_drop: ALL`.
4. `no-new-privileges` is enabled where applicable.
5. Backend, monitoring and logging traffic is separated into dedicated Docker networks.
6. The application uses a dedicated MySQL account instead of root.
7. MySQL Exporter uses a separate monitoring account.
8. `.env` is excluded from Git.
9. Passwords are stored as PBKDF2 hashes with random salts.
10. CMS authorization uses `ADMIN`, `EDITOR` and `USER` roles.
11. Login and global request rate limits are enabled.
12. Nginx adds security headers and hides its version.
13. MySQL local file loading is disabled.
14. phpMyAdmin, Prometheus and Grafana bind to `127.0.0.1` only.
15. `/metrics` is not exposed through the public Nginx endpoint.
16. Important CMS actions are recorded in audit logs.

Useful verification commands:

```powershell
docker inspect devblog-app --format='User={{.Config.User}} ReadOnly={{.HostConfig.ReadonlyRootfs}}'
docker inspect devblog-app --format='{{json .HostConfig.CapDrop}}'
docker inspect devblog-app --format='{{json .HostConfig.SecurityOpt}}'
docker network inspect devblog_backend
docker port devblog-mysql
curl.exe -I http://localhost:8088
```
