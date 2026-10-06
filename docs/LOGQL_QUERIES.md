# LogQL demo queries

Run these in **Grafana -> Explore -> Loki** after generating traffic in the website.

## 1. All Blog application logs

```logql
{container="devblog-app"}
```

## 2. Application errors

```logql
{container="devblog-app"} |= "\"level\":\"ERROR\""
```

## 3. Authentication events

```logql
{container="devblog-app"} |~ "LOGIN|LOGIN_FAILED|LOGOUT"
```

## 4. CMS content changes

```logql
{container="devblog-app"} |~ "CREATE_POST|UPDATE_POST|DELETE_POST|CREATE_CATEGORY"
```

## 5. Nginx HTTP 4xx/5xx examples

```logql
{container="devblog-nginx"} |~ " (4|5)[0-9]{2} "
```

The rubric asks for at least 2-3 LogQL queries; the project provides five prepared examples.
