DROP DATABASE IF EXISTS flutter_demo_db;
CREATE DATABASE flutter_demo_db;
USE flutter_demo_db;


CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  description TEXT,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

CREATE TABLE reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  reviewer_name VARCHAR(100) NOT NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

INSERT INTO categories (id, name) VALUES 
(1, 'Party / Casual'),
(2, 'RPG / Adventure');

INSERT INTO products (id, category_id, name, price, description, image_url) VALUES
(1, 1, 'Mario Party Superstars', 850000, 'Game Nintendo Switch vui nhộn cùng bạn bè', 'https://haloshop.vn/wp-content/uploads/2025/02/super_mario_party_jamboree_switch-700x700h.jpg'),
(2, 2, 'Pokemon Legends Z-A', 1450000, 'Siêu phẩm RPG Pokemon thế hệ mới', 'https://haloshop.vn/wp-content/uploads/2025/07/POKEMON-LEGENDS-Z-A_asia_sw2.webp');

INSERT INTO reviews (product_id, reviewer_name, rating, comment) VALUES
(1, 'Nguyen Van A', 5, 'Game siêu vui khi chơi nhóm đông người!'),
(1, 'Tran Thi B', 4, 'Đồ họa đẹp nhưng ít map hơn bản cũ.'),
(2, 'Gamer Pro', 5, 'Rất mong chờ ngày game ra mắt chính thức.');