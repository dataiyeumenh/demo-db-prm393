import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { pool } from "./db";

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({ success: true, message: "Flutter Demo API is running" });
});

// 1. API LẤY DANH SÁCH THỂ LOẠI (Để hiển thị Dropdown lựa chọn ở Flutter)
app.get("/api/categories", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM categories ORDER BY id ASC");
    res.json({ success: true, data: rows });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Failed to fetch categories" });
  }
});

// 2. API GET ALL PRODUCTS (Gộp kèm tên Category và điểm số Rating Trung Bình)
app.get("/api/products", async (req, res) => {
  try {
    const sql = `
      SELECT 
        p.*, 
        c.name AS category_name,
        IFNULL(AVG(r.rating), 0) AS avg_rating,
        COUNT(r.id) AS review_count
      FROM products p
      INNER JOIN categories c ON p.category_id = c.id
      LEFT JOIN reviews r ON p.id = r.product_id
      GROUP BY p.id
      ORDER BY p.id DESC
    `;
    const [rows] = await pool.query(sql);
    res.json({ success: true, data: rows });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Failed to fetch products" });
  }
});

// 3. API GET PRODUCT DETAIL (Lấy thông tin game kèm danh sách các bài Reviews chi tiết)
app.get("/api/products/:id", async (req, res) => {
  try {
    const { id } = req.params;

    // Lấy thông tin chi tiết sản phẩm
    const prodSql = `
      SELECT p.*, c.name AS category_name 
      FROM products p 
      INNER JOIN categories c ON p.category_id = c.id 
      WHERE p.id = ?
    `;
    const [prods]: any = await pool.query(prodSql, [id]);
    if (prods.length === 0) {
      return res
        .status(404)
        .json({ success: false, message: "Product not found" });
    }

    // Lấy danh sách đánh giá của sản phẩm này
    const [reviews] = await pool.query(
      "SELECT * FROM reviews WHERE product_id = ? ORDER BY id DESC",
      [id],
    );

    res.json({
      success: true,
      data: {
        ...prods[0],
        reviews: reviews,
      },
    });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Failed to fetch product detail" });
  }
});

// 4. API POST NEW PRODUCT (Yêu cầu truyền category_id)
app.post("/api/products", async (req, res) => {
  try {
    const { category_id, name, price, description, image_url } = req.body;
    if (!category_id || !name || price == null) {
      return res.status(400).json({
        success: false,
        message: "Category, name and price are required",
      });
    }

    const [result]: any = await pool.query(
      "INSERT INTO products (category_id, name, price, description, image_url) VALUES (?, ?, ?, ?, ?)",
      [category_id, name, price, description || null, image_url || null],
    );

    res.status(201).json({
      success: true,
      message: "Product created successfully",
      data: { id: result.insertId },
    });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Failed to create product" });
  }
});

// 5. API PUT UPDATE PRODUCT
app.put("/api/products/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { category_id, name, price, description, image_url } = req.body;

    const [rows]: any = await pool.query(
      "SELECT * FROM products WHERE id = ?",
      [id],
    );
    if (rows.length === 0) {
      return res
        .status(404)
        .json({ success: false, message: "Product not found" });
    }

    const current = rows[0];
    await pool.query(
      `UPDATE products SET category_id = ?, name = ?, price = ?, description = ?, image_url = ? WHERE id = ?`,
      [
        category_id ?? current.category_id,
        name ?? current.name,
        price ?? current.price,
        description ?? current.description,
        image_url ?? current.image_url,
        id,
      ],
    );
    res.json({ success: true, message: "Product updated successfully" });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Failed to update product" });
  }
});

// 6. API DELETE PRODUCT
app.delete("/api/products/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const [result]: any = await pool.query(
      "DELETE FROM products WHERE id = ?",
      [id],
    );
    if (result.affectedRows === 0) {
      return res
        .status(404)
        .json({ success: false, message: "Product not found" });
    }
    res.json({ success: true, message: "Product deleted successfully" });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Failed to delete product" });
  }
});

// 7. API THÊM REVIEW MỚI CHO GAME (Tăng tính tương tác)
app.post("/api/products/:id/reviews", async (req, res) => {
  try {
    const productId = req.params.id;
    const { reviewer_name, rating, comment } = req.body;

    if (!reviewer_name || !rating) {
      return res.status(400).json({
        success: false,
        message: "Reviewer name and rating are required",
      });
    }

    await pool.query(
      "INSERT INTO reviews (product_id, reviewer_name, rating, comment) VALUES (?, ?, ?, ?)",
      [productId, reviewer_name, rating, comment || null],
    );

    res
      .status(201)
      .json({ success: true, message: "Review added successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Failed to add review" });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
