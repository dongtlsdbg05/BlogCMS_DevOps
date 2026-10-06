# Git commit plan

The rubric asks for at least 3 meaningful commits. Prefer a clean history similar to:

1. `chore: initialize DevBlog CMS project structure`
2. `feat: implement Blog CMS with MySQL and phpMyAdmin`
3. `feat: configure nginx reverse proxy and security headers` **(rubric commit 1)**
4. `feat: integrate prometheus grafana and exporters` **(rubric commit 2)**
5. `feat: integrate loki promtail centralized logging` **(rubric commit 3)**
6. `security: apply container network and application hardening`
7. `docs: add demo guide test plan and rubric evidence`

Do not commit `.env`, real passwords, database volumes or generated runtime data.
