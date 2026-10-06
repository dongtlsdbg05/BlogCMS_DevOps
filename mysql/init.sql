CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  role ENUM('ADMIN','EDITOR','USER') NOT NULL DEFAULT 'USER',
  status ENUM('ACTIVE','LOCKED') NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_users_role_status (role, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS categories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  slug VARCHAR(120) NOT NULL UNIQUE,
  description VARCHAR(500),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS posts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  slug VARCHAR(240) NOT NULL UNIQUE,
  summary VARCHAR(600),
  content MEDIUMTEXT NOT NULL,
  thumbnail_url VARCHAR(500),
  status ENUM('DRAFT','PUBLISHED','HIDDEN') NOT NULL DEFAULT 'DRAFT',
  views BIGINT UNSIGNED NOT NULL DEFAULT 0,
  author_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NOT NULL,
  published_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_posts_author FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE RESTRICT,
  CONSTRAINT fk_posts_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
  INDEX idx_posts_status_published (status, published_at),
  INDEX idx_posts_category (category_id),
  FULLTEXT INDEX ft_posts_search (title, summary, content)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS comments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  post_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  guest_name VARCHAR(100) NULL,
  guest_email VARCHAR(120) NULL,
  content VARCHAR(1500) NOT NULL,
  status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_comments_post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  CONSTRAINT fk_comments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_comments_post_status (post_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tags (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL UNIQUE,
  slug VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS post_tags (
  post_id BIGINT UNSIGNED NOT NULL,
  tag_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (post_id, tag_id),
  CONSTRAINT fk_post_tags_post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  CONSTRAINT fk_post_tags_tag FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL,
  action VARCHAR(80) NOT NULL,
  resource VARCHAR(120) NOT NULL,
  resource_id VARCHAR(80) NULL,
  ip_address VARCHAR(64) NULL,
  details VARCHAR(1000) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_audit_created (created_at),
  INDEX idx_audit_action (action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO users (id, username, email, password_hash, full_name, role, status) VALUES
(1, 'admin', 'admin@devblog.local', 'devblog_admin_salt_2026:3ab52f4a6b43f9a5258194335fe17788fbc7f58bc7e2df29d63af9c60d69ebf7', 'System Administrator', 'ADMIN', 'ACTIVE'),
(2, 'editor01', 'editor@devblog.local', 'devblog_editor_salt_2026:b73842c5848d525ef0d8b3e1280e4458c7782a4ffcd8b75721d1c026bfe77d55', 'Content Editor', 'EDITOR', 'ACTIVE'),
(3, 'user01', 'user@devblog.local', 'devblog_user_salt_2026:e9461819150be3b01327dbe2a56204c2c25723426d64bcc17ac3a5360b21176b', 'Demo Reader', 'USER', 'ACTIVE');

INSERT IGNORE INTO categories (id, name, slug, description) VALUES
(1, 'DevOps', 'devops', 'Triển khai, CI/CD và vận hành hệ thống'),
(2, 'Docker', 'docker', 'Container và Docker Compose'),
(3, 'Monitoring', 'monitoring', 'Prometheus, Grafana và quan sát hệ thống'),
(4, 'Linux', 'linux', 'Quản trị Linux'),
(5, 'Security', 'security', 'Bảo mật và hardening'),
(6, 'Database', 'database', 'MySQL và quản trị dữ liệu'),
(7, 'Networking', 'networking', 'Mạng máy tính và reverse proxy'),
(8, 'Programming', 'programming', 'Lập trình web và backend');

INSERT IGNORE INTO tags (id, name, slug) VALUES
(1,'Docker','docker'),(2,'Nginx','nginx'),(3,'Prometheus','prometheus'),(4,'Grafana','grafana'),
(5,'Loki','loki'),(6,'MySQL','mysql'),(7,'Security','security'),(8,'Node.js','nodejs');

INSERT IGNORE INTO posts (id,title,slug,summary,content,thumbnail_url,status,views,author_id,category_id,published_at) VALUES
(1,'Docker Compose trong triển khai hệ thống','docker-compose-trong-trien-khai-he-thong','Tổng quan cách Docker Compose giúp quản lý nhiều dịch vụ trong cùng một hệ thống.','Docker Compose cho phép mô tả và vận hành nhiều container từ một tệp cấu hình duy nhất. Trong dự án DevBlog CMS, Compose liên kết ứng dụng, cơ sở dữ liệu, reverse proxy, monitoring và logging thành một hệ thống thống nhất.','/images/docker.svg','PUBLISHED',124,1,2,NOW()),
(2,'Nginx Reverse Proxy: vì sao cần thiết?','nginx-reverse-proxy-vi-sao-can-thiet','Nginx đứng trước ứng dụng để định tuyến, thêm security headers và che giấu cổng nội bộ.','Reverse proxy giúp tách lớp truy cập bên ngoài khỏi ứng dụng. Nginx nhận request từ client, chuyển tiếp đến dịch vụ backend và áp dụng các chính sách HTTP ở một điểm tập trung.','/images/nginx.svg','PUBLISHED',96,2,7,NOW()),
(3,'Giám sát container với Prometheus và Grafana','giam-sat-container-prometheus-grafana','Kết hợp Prometheus, cAdvisor và Grafana để theo dõi CPU, RAM và trạng thái dịch vụ.','Prometheus thu thập metrics theo mô hình pull. cAdvisor cung cấp metrics container, MySQL exporter cung cấp metrics database và ứng dụng cung cấp HTTP metrics. Grafana trực quan hóa các dữ liệu này.','/images/monitoring.svg','PUBLISHED',88,2,3,NOW()),
(4,'Centralized Logging với Loki và Promtail','centralized-logging-loki-promtail','Thu thập log container tập trung và truy vấn bằng LogQL.','Promtail đọc log Docker và gửi đến Loki. Grafana Explore có thể truy vấn theo container, mức log hoặc từ khóa nghiệp vụ như LOGIN và CREATE_POST.','/images/logging.svg','PUBLISHED',73,1,3,NOW()),
(5,'Hardening container cơ bản','hardening-container-co-ban','Các biện pháp giảm bề mặt tấn công khi triển khai ứng dụng bằng container.','Một số biện pháp gồm chạy non-root, drop Linux capabilities, read-only filesystem, network isolation, secrets qua biến môi trường và hạn chế quyền database.','/images/security.svg','PUBLISHED',67,1,5,NOW()),
(6,'MySQL Least Privilege trong ứng dụng web','mysql-least-privilege-trong-ung-dung-web','Ứng dụng không nên kết nối database bằng tài khoản root.','Nguyên tắc least privilege yêu cầu tài khoản ứng dụng chỉ có những quyền cần thiết trên đúng database mà nó sử dụng. Docker MySQL image có thể tạo application user riêng từ biến môi trường.','/images/database.svg','PUBLISHED',55,2,6,NOW());

INSERT IGNORE INTO post_tags (post_id, tag_id) VALUES
(1,1),(2,2),(3,3),(3,4),(4,5),(5,7),(6,6);

INSERT IGNORE INTO comments (id,post_id,user_id,content,status) VALUES
(1,1,3,'Bài viết dễ hiểu và có ví dụ triển khai thực tế.','APPROVED'),
(2,3,3,'Dashboard monitoring là phần mình thấy hữu ích nhất.','APPROVED');
