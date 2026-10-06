# Database

The application uses MySQL 8.4. The default database name is `blogcms`.

## Tables

- `users`
- `categories`
- `posts`
- `comments`
- `tags`
- `post_tags`
- `audit_logs`

## Relationships

- users 1-N posts
- users 1-N comments
- categories 1-N posts
- posts 1-N comments
- posts N-N tags through `post_tags`
- users 1-N audit_logs

## Accounts

- The application uses the account configured by `DB_USER` and `DB_PASSWORD`.
- MySQL Exporter uses a dedicated `exporter` account with monitoring-only permissions.
- The root account is reserved for database initialization and administration.

Database initialization files are stored in `database/`.
