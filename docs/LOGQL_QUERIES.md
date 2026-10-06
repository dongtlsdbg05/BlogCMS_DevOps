# LogQL Queries

Run these queries in **Grafana → Explore → Loki** after generating traffic in the application.

## Nginx logs

```logql
{container="devblog-nginx"}
```

## Application logs

```logql
{container="devblog-app"}
```

## Application errors

```logql
{container="devblog-app"} |= "\"level\":\"ERROR\""
```

## Authentication events

```logql
{container="devblog-app"} |~ "LOGIN|LOGIN_FAILED|LOGOUT"
```

## Content changes

```logql
{container="devblog-app"} |~ "CREATE_POST|UPDATE_POST|DELETE_POST|CREATE_CATEGORY"
```

## HTTP 4xx/5xx responses

```logql
{container="devblog-nginx"} |~ " (4|5)[0-9]{2} "
```
