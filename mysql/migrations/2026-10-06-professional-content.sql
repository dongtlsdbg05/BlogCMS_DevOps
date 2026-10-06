-- Professional content refresh for existing DevBlog databases.
-- Safe to run more than once.
UPDATE users SET full_name='Nguyễn Minh Anh' WHERE username='admin';
UPDATE users SET full_name='Trần Hoàng Nam' WHERE username='editor01';
UPDATE users SET full_name='Lê Thu Hà' WHERE username='user01';

UPDATE posts SET
  title='Kiến trúc container hiện đại với Docker Compose',
  slug='kien-truc-container-hien-dai-voi-docker-compose',
  summary='Cách tổ chức nhiều dịch vụ theo hướng nhất quán, dễ vận hành và dễ mở rộng với Docker Compose.',
  content='Docker Compose giúp mô tả ứng dụng nhiều dịch vụ bằng cấu hình có thể kiểm soát phiên bản. Khi được tổ chức hợp lý, các lớp ứng dụng, dữ liệu, proxy, giám sát và nhật ký có thể được vận hành nhất quán trên cùng một nền tảng container.'
WHERE id=1;

UPDATE posts SET
  title='Nginx Reverse Proxy trong kiến trúc web hiện đại',
  slug='nginx-reverse-proxy-trong-kien-truc-web-hien-dai',
  summary='Reverse proxy giúp chuẩn hóa luồng truy cập, kiểm soát HTTP và giảm mức độ phơi bày của các dịch vụ phía sau.'
WHERE id=2;

UPDATE posts SET
  title='Quan sát hệ thống với Prometheus và Grafana',
  slug='quan-sat-he-thong-voi-prometheus-va-grafana',
  summary='Xây dựng lớp quan sát thống nhất cho tài nguyên, ứng dụng và cơ sở dữ liệu bằng metrics và dashboard.'
WHERE id=3;

UPDATE posts SET
  title='Chiến lược log tập trung với Loki và Promtail',
  slug='chien-luoc-log-tap-trung-voi-loki-va-promtail',
  summary='Tập trung hóa nhật ký giúp rút ngắn thời gian truy vết sự cố và cải thiện khả năng quan sát vận hành.'
WHERE id=4;

UPDATE posts SET
  title='Nguyên tắc hardening cho môi trường container',
  slug='nguyen-tac-hardening-cho-moi-truong-container',
  summary='Những kiểm soát quan trọng giúp giảm bề mặt tấn công và giới hạn tác động khi dịch vụ gặp sự cố.'
WHERE id=5;

UPDATE posts SET
  title='Thiết kế quyền truy cập MySQL theo nguyên tắc tối thiểu',
  slug='thiet-ke-quyen-truy-cap-mysql-theo-nguyen-tac-toi-thieu',
  summary='Phân tách tài khoản và giới hạn quyền giúp giảm rủi ro khi ứng dụng truy cập cơ sở dữ liệu.'
WHERE id=6;

UPDATE comments SET content='Nội dung rõ ràng, có tính ứng dụng và dễ đối chiếu với môi trường vận hành thực tế.' WHERE id=1;
UPDATE comments SET content='Phần quan sát hệ thống trình bày khá trực quan và có thể áp dụng cho nhiều mô hình dịch vụ.' WHERE id=2;
