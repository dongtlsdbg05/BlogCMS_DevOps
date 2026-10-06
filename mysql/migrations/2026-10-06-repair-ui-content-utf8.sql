SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;

UPDATE users SET full_name='Nguyễn Minh Anh' WHERE username='admin';
UPDATE users SET full_name='Trần Hoàng Nam' WHERE username='editor01';
UPDATE users SET full_name='Lê Thu Hà' WHERE username='user01';

UPDATE categories SET name='Kỹ thuật hệ thống', description='Kiến trúc triển khai, tự động hóa và vận hành nền tảng.' WHERE id=1;
UPDATE categories SET name='Container', description='Thiết kế môi trường container và quản lý vòng đời dịch vụ.' WHERE id=2;
UPDATE categories SET name='Quan sát hệ thống', description='Metrics, dashboard và khả năng quan sát dịch vụ theo thời gian thực.' WHERE id=3;
UPDATE categories SET name='Hệ điều hành', description='Thực hành quản trị Linux và tối ưu môi trường máy chủ.' WHERE id=4;
UPDATE categories SET name='Bảo mật', description='Kiểm soát truy cập, hardening và giảm bề mặt tấn công.' WHERE id=5;
UPDATE categories SET name='Cơ sở dữ liệu', description='Thiết kế, vận hành và bảo vệ hệ quản trị dữ liệu.' WHERE id=6;
UPDATE categories SET name='Kiến trúc web', description='Reverse proxy, HTTP và các mẫu kiến trúc cho ứng dụng web.' WHERE id=7;
UPDATE categories SET name='Phát triển phần mềm', description='Kỹ thuật backend, chất lượng mã nguồn và thực hành phát triển.' WHERE id=8;

UPDATE posts SET
  title='Thiết kế môi trường container nhất quán với Docker Compose',
  slug='thiet-ke-moi-truong-container-nhat-quan-voi-docker-compose',
  summary='Cách tổ chức nhiều dịch vụ theo một cấu hình thống nhất để việc triển khai, mở rộng và bảo trì trở nên dễ kiểm soát hơn.',
  content='Docker Compose giúp mô tả một ứng dụng nhiều dịch vụ bằng cấu hình có thể kiểm soát phiên bản. Thay vì vận hành từng thành phần rời rạc, đội ngũ có thể định nghĩa rõ mạng, volume, biến môi trường và quan hệ phụ thuộc ngay trong cùng một mô hình triển khai. Cách tiếp cận này làm giảm sai khác giữa các môi trường và tạo nền tảng thuận lợi cho việc kiểm thử, giám sát và mở rộng hệ thống.'
WHERE id=1;

UPDATE posts SET
  title='Vai trò của reverse proxy trong kiến trúc web hiện đại',
  slug='vai-tro-cua-reverse-proxy-trong-kien-truc-web-hien-dai',
  summary='Reverse proxy tạo một lớp truy cập thống nhất, giúp kiểm soát lưu lượng, chuẩn hóa HTTP và hạn chế việc phơi bày trực tiếp các dịch vụ phía sau.',
  content='Reverse proxy đóng vai trò là điểm vào tập trung cho lưu lượng web. Lớp này có thể định tuyến yêu cầu, bổ sung security headers, kiểm soát giới hạn truy cập và che giấu cổng nội bộ của ứng dụng. Khi được cấu hình đúng, reverse proxy giúp kiến trúc rõ ràng hơn, tăng khả năng kiểm soát và giảm mức độ phụ thuộc giữa client với từng dịch vụ backend.'
WHERE id=2;

UPDATE posts SET
  title='Xây dựng khả năng quan sát hệ thống với Prometheus và Grafana',
  slug='xay-dung-kha-nang-quan-sat-he-thong-voi-prometheus-va-grafana',
  summary='Kết hợp metrics và dashboard để theo dõi tài nguyên, ứng dụng và cơ sở dữ liệu theo một góc nhìn thống nhất.',
  content='Khả năng quan sát tốt giúp đội ngũ hiểu hệ thống đang hoạt động như thế nào thay vì chỉ biết dịch vụ còn chạy hay đã dừng. Prometheus thu thập metrics từ nhiều nguồn, còn Grafana biến các số liệu đó thành dashboard trực quan. Khi metrics hạ tầng, ứng dụng và cơ sở dữ liệu được theo dõi cùng nhau, việc phát hiện bất thường và phân tích nguyên nhân trở nên nhanh và có cơ sở hơn.'
WHERE id=3;

UPDATE posts SET
  title='Chiến lược quản lý nhật ký tập trung cho hệ thống phân tán',
  slug='chien-luoc-quan-ly-nhat-ky-tap-trung-cho-he-thong-phan-tan',
  summary='Tập trung hóa log giúp rút ngắn thời gian truy vết sự cố, tìm kiếm sự kiện và theo dõi luồng hoạt động giữa nhiều dịch vụ.',
  content='Trong hệ thống gồm nhiều container, việc xem log riêng lẻ từng dịch vụ nhanh chóng trở nên khó kiểm soát. Một nền tảng log tập trung cho phép gom dữ liệu về một nơi, gắn nhãn theo dịch vụ và truy vấn theo thời gian hoặc từ khóa. Cách tổ chức này hỗ trợ tốt cho điều tra sự cố, phân tích hành vi và đối chiếu các sự kiện xảy ra trên toàn hệ thống.'
WHERE id=4;

UPDATE posts SET
  title='Các nguyên tắc hardening cho dịch vụ container',
  slug='cac-nguyen-tac-hardening-cho-dich-vu-container',
  summary='Giảm bề mặt tấn công bằng cách giới hạn đặc quyền, cô lập mạng, bảo vệ secret và chỉ cấp đúng quyền cần thiết cho từng dịch vụ.',
  content='Hardening không dựa vào một biện pháp duy nhất mà là tập hợp nhiều lớp kiểm soát. Container nên chạy với đặc quyền tối thiểu, filesystem chỉ đọc khi phù hợp, network được phân tách theo vai trò và thông tin nhạy cảm không được ghi trực tiếp vào mã nguồn. Những nguyên tắc này giúp giới hạn tác động nếu một thành phần gặp sự cố hoặc bị khai thác.'
WHERE id=5;

UPDATE posts SET
  title='Thiết kế quyền truy cập MySQL theo nguyên tắc tối thiểu',
  slug='thiet-ke-quyen-truy-cap-mysql-theo-nguyen-tac-toi-thieu',
  summary='Tách tài khoản ứng dụng khỏi tài khoản quản trị và chỉ cấp đúng phạm vi quyền cần thiết cho cơ sở dữ liệu mà dịch vụ sử dụng.',
  content='Ứng dụng không nên kết nối cơ sở dữ liệu bằng tài khoản root. Một tài khoản riêng với phạm vi quyền tối thiểu giúp giảm đáng kể hậu quả khi thông tin xác thực bị lộ hoặc ứng dụng gặp lỗ hổng. Việc phân tách tài khoản quản trị, tài khoản ứng dụng và tài khoản quan sát cũng giúp kiểm soát trách nhiệm rõ ràng hơn trong quá trình vận hành.'
WHERE id=6;

UPDATE comments SET content='Bài viết trình bày rõ ràng, tập trung vào các quyết định kiến trúc có thể áp dụng trong môi trường thực tế.' WHERE id=1;
UPDATE comments SET content='Cách kết hợp metrics và dashboard giúp việc theo dõi trạng thái hệ thống trực quan hơn.' WHERE id=2;

SELECT id, title, summary FROM posts ORDER BY id;
SELECT id, username, full_name FROM users ORDER BY id;
