CREATE DATABASE IF NOT EXISTS flutter_demo_db;

USE flutter_demo_db;

CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  description TEXT,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (name, price, description, image_url)
VALUES
(
  'Mario Party Superstars',
  850000,
  'Game Nintendo Switch',
  'https://haloshop.vn/wp-content/uploads/2025/02/mario-party-superstars-switch-700x700.webp'
),
(
  'Pokemon Legends Z-A',
  1450000,
  'Game Nintendo Switch 2',
  'https://haloshop.vn/wp-content/uploads/2025/07/POKEMON-LEGENDS-Z-A_asia_sw2.webp'
);