# Terminal Command Reference

Tất cả thao tác project thực hiện từ PowerShell/Windows Terminal. Không dùng `.bat`.

## First run

```powershell
Copy-Item .env.example .env
notepad .env
docker compose config
docker compose pull
docker compose up -d --build
docker compose ps
```

Trước `docker compose up`, thay toàn bộ `CHANGE_ME_*` trong `.env` bằng secret mạnh.

## Daily start

```powershell
docker compose up -d
docker compose ps
```

## Stop

```powershell
docker compose down
```

## Rebuild after code changes

```powershell
docker compose up -d --build app
```

## Logs

```powershell
docker compose logs -f app
docker compose logs -f nginx
docker compose logs -f mysql
docker compose logs -f prometheus
docker compose logs -f grafana
docker compose logs -f loki
docker compose logs -f promtail
```

## Validate

```powershell
docker compose config
python scripts/check-rubric.py
curl.exe http://localhost:8088/api/health
curl.exe -I http://localhost:8088
```

## Reset all persistent data

```powershell
docker compose down -v --remove-orphans
docker compose up -d --build
```

## Clean only stopped project containers

```powershell
docker compose down --remove-orphans
```
