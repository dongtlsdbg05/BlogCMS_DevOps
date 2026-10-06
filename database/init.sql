SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;

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
(1, 'admin', 'admin@devblog.local', 'devblog_admin_salt_2026:3ab52f4a6b43f9a5258194335fe17788fbc7f58bc7e2df29d63af9c60d69ebf7', 'Nguyễn Minh Anh', 'ADMIN', 'ACTIVE'),
(2, 'editor01', 'editor@devblog.local', 'devblog_editor_salt_2026:b73842c5848d525ef0d8b3e1280e4458c7782a4ffcd8b75721d1c026bfe77d55', 'Trần Hoàng Nam', 'EDITOR', 'ACTIVE'),
(3, 'user01', 'user@devblog.local', 'devblog_user_salt_2026:e9461819150be3b01327dbe2a56204c2c25723426d64bcc17ac3a5360b21176b', 'Lê Thu Hà', 'USER', 'ACTIVE');

INSERT IGNORE INTO categories (id, name, slug, description) VALUES
(1, 'Kỹ thuật hệ thống', 'devops', 'Kiến trúc triển khai, tự động hóa và vận hành nền tảng.'),
(2, 'Container', 'docker', 'Thiết kế môi trường container và quản lý vòng đời dịch vụ.'),
(3, 'Quan sát hệ thống', 'monitoring', 'Metrics, dashboard và khả năng quan sát dịch vụ theo thời gian thực.'),
(4, 'Hệ điều hành', 'linux', 'Thực hành quản trị Linux và tối ưu môi trường máy chủ.'),
(5, 'Bảo mật', 'security', 'Kiểm soát truy cập, hardening và giảm bề mặt tấn công.'),
(6, 'Cơ sở dữ liệu', 'database', 'Thiết kế, vận hành và bảo vệ hệ quản trị dữ liệu.'),
(7, 'Kiến trúc web', 'networking', 'Reverse proxy, HTTP và các mẫu kiến trúc cho ứng dụng web.'),
(8, 'Phát triển phần mềm', 'programming', 'Kỹ thuật backend, chất lượng mã nguồn và thực hành phát triển.');

INSERT IGNORE INTO tags (id, name, slug) VALUES
(1,'Docker','docker'),(2,'Nginx','nginx'),(3,'Prometheus','prometheus'),(4,'Grafana','grafana'),
(5,'Loki','loki'),(6,'MySQL','mysql'),(7,'Security','security'),(8,'Node.js','nodejs');

INSERT IGNORE INTO posts (id,title,slug,summary,content,thumbnail_url,status,views,author_id,category_id,published_at) VALUES
(1,'Thiết kế môi trường container nhất quán với Docker Compose','thiet-ke-moi-truong-container-nhat-quan-voi-docker-compose','Cách tổ chức nhiều dịch vụ theo một cấu hình thống nhất để việc triển khai, mở rộng và bảo trì trở nên dễ kiểm soát hơn.','Docker Compose giúp mô tả một ứng dụng nhiều dịch vụ bằng cấu hình có thể kiểm soát phiên bản. Thay vì vận hành từng thành phần rời rạc, đội ngũ có thể định nghĩa rõ mạng, volume, biến môi trường và quan hệ phụ thuộc ngay trong cùng một mô hình triển khai. Cách tiếp cận này làm giảm sai khác giữa các môi trường và tạo nền tảng thuận lợi cho việc kiểm thử, giám sát và mở rộng hệ thống.','/images/docker.svg','PUBLISHED',124,1,2,NOW()),
(2,'Vai trò của reverse proxy trong kiến trúc web hiện đại','vai-tro-cua-reverse-proxy-trong-kien-truc-web-hien-dai','Reverse proxy tạo một lớp truy cập thống nhất, giúp kiểm soát lưu lượng, chuẩn hóa HTTP và hạn chế việc phơi bày trực tiếp các dịch vụ phía sau.','Reverse proxy đóng vai trò là điểm vào tập trung cho lưu lượng web. Lớp này có thể định tuyến yêu cầu, bổ sung security headers, kiểm soát giới hạn truy cập và che giấu cổng nội bộ của ứng dụng. Khi được cấu hình đúng, reverse proxy giúp kiến trúc rõ ràng hơn, tăng khả năng kiểm soát và giảm mức độ phụ thuộc giữa client với từng dịch vụ backend.','/images/nginx.svg','PUBLISHED',96,2,7,NOW()),
(3,'Xây dựng khả năng quan sát hệ thống với Prometheus và Grafana','xay-dung-kha-nang-quan-sat-he-thong-voi-prometheus-va-grafana','Kết hợp metrics và dashboard để theo dõi tài nguyên, ứng dụng và cơ sở dữ liệu theo một góc nhìn thống nhất.','Khả năng quan sát tốt giúp đội ngũ hiểu hệ thống đang hoạt động như thế nào thay vì chỉ biết dịch vụ còn chạy hay đã dừng. Prometheus thu thập metrics từ nhiều nguồn, còn Grafana biến các số liệu đó thành dashboard trực quan. Khi metrics hạ tầng, ứng dụng và cơ sở dữ liệu được theo dõi cùng nhau, việc phát hiện bất thường và phân tích nguyên nhân trở nên nhanh và có cơ sở hơn.','/images/monitoring.svg','PUBLISHED',88,2,3,NOW()),
(4,'Chiến lược quản lý nhật ký tập trung cho hệ thống phân tán','chien-luoc-quan-ly-nhat-ky-tap-trung-cho-he-thong-phan-tan','Tập trung hóa log giúp rút ngắn thời gian truy vết sự cố, tìm kiếm sự kiện và theo dõi luồng hoạt động giữa nhiều dịch vụ.','Trong hệ thống gồm nhiều container, việc xem log riêng lẻ từng dịch vụ nhanh chóng trở nên khó kiểm soát. Một nền tảng log tập trung cho phép gom dữ liệu về một nơi, gắn nhãn theo dịch vụ và truy vấn theo thời gian hoặc từ khóa. Cách tổ chức này hỗ trợ tốt cho điều tra sự cố, phân tích hành vi và đối chiếu các sự kiện xảy ra trên toàn hệ thống.','/images/logging.svg','PUBLISHED',73,1,3,NOW()),
(5,'Các nguyên tắc hardening cho dịch vụ container','cac-nguyen-tac-hardening-cho-dich-vu-container','Giảm bề mặt tấn công bằng cách giới hạn đặc quyền, cô lập mạng, bảo vệ secret và chỉ cấp đúng quyền cần thiết cho từng dịch vụ.','Hardening không dựa vào một biện pháp duy nhất mà là tập hợp nhiều lớp kiểm soát. Container nên chạy với đặc quyền tối thiểu, filesystem chỉ đọc khi phù hợp, network được phân tách theo vai trò và thông tin nhạy cảm không được ghi trực tiếp vào mã nguồn. Những nguyên tắc này giúp giới hạn tác động nếu một thành phần gặp sự cố hoặc bị khai thác.','/images/security.svg','PUBLISHED',67,1,5,NOW()),
(6,'Thiết kế quyền truy cập MySQL theo nguyên tắc tối thiểu','thiet-ke-quyen-truy-cap-mysql-theo-nguyen-tac-toi-thieu','Tách tài khoản ứng dụng khỏi tài khoản quản trị và chỉ cấp đúng phạm vi quyền cần thiết cho cơ sở dữ liệu mà dịch vụ sử dụng.','Ứng dụng không nên kết nối cơ sở dữ liệu bằng tài khoản root. Một tài khoản riêng với phạm vi quyền tối thiểu giúp giảm đáng kể hậu quả khi thông tin xác thực bị lộ hoặc ứng dụng gặp lỗ hổng. Việc phân tách tài khoản quản trị, tài khoản ứng dụng và tài khoản quan sát cũng giúp kiểm soát trách nhiệm rõ ràng hơn trong quá trình vận hành.','/images/database.svg','PUBLISHED',55,2,6,NOW());

INSERT IGNORE INTO post_tags (post_id, tag_id) VALUES
(1,1),(2,2),(3,3),(3,4),(4,5),(5,7),(6,6);

INSERT IGNORE INTO comments (id,post_id,user_id,content,status) VALUES
(1,1,3,'Bài viết trình bày rõ ràng, tập trung vào các quyết định kiến trúc có thể áp dụng trong môi trường thực tế.','APPROVED'),
(2,3,3,'Cách kết hợp metrics và dashboard giúp việc theo dõi trạng thái hệ thống trực quan hơn.','APPROVED');

