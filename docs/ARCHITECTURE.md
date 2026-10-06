# Architecture

Client -> Nginx -> Node.js/Express Blog CMS -> MySQL

Administration tools: phpMyAdmin (localhost only)

Monitoring: Prometheus <- app / cAdvisor / node-exporter / MySQL exporter -> Grafana

Logging: Docker container logs -> Promtail -> Loki -> Grafana Explore

Networks are separated into frontend, backend, monitoring, and logging tiers.
