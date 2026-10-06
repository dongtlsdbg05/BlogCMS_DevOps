# Architecture

## Application flow

```text
Browser
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

The source is separated into two application areas:

- `backend/`: HTTP server, routing, authentication, database access, services and utilities.
- `frontend/`: EJS templates, stylesheets and static images.

Infrastructure configuration is stored under `infrastructure/`.

## Observability

```text
Prometheus <- application / cAdvisor / Node Exporter / MySQL Exporter
    |
    v
Grafana

Docker logs -> Promtail -> Loki -> Grafana Explore
```

## Docker networks

- `devblog_frontend`: Nginx and the application.
- `devblog_backend`: application, MySQL and database-related monitoring.
- `devblog_monitoring`: Prometheus and exporters.
- `devblog_logging`: Loki and Promtail.
- `devblog_management`: local management interfaces.
