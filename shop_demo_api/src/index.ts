import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { pool } from "./db";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "Flutter Demo API is running",
  });
});

app.get("/api/products", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM products ORDER BY id DESC");

    res.json({
      success: true,
      data: rows,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch products",
    });
  }
});

app.get("/api/products/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const [rows]: any = await pool.query(
      "SELECT * FROM products WHERE id = ?",
      [id],
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    res.json({
      success: true,
      data: rows[0],
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch product",
    });
  }
});

app.post("/api/products", async (req, res) => {
  try {
    const { name, price, description, image_url } = req.body;

    if (!name || price == null) {
      return res.status(400).json({
        success: false,
        message: "Name and price are required",
      });
    }

    const [result]: any = await pool.query(
      "INSERT INTO products (name, price, description, image_url) VALUES (?, ?, ?, ?)",
      [name, price, description || null, image_url || null],
    );

    res.status(201).json({
      success: true,
      message: "Product created successfully",
      data: {
        id: result.insertId,
        name,
        price,
        description,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to create product",
    });
  }
});

app.put("/api/products/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, description, image_url } = req.body;

    const [rows]: any = await pool.query(
      "SELECT * FROM products WHERE id = ?",
      [id],
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    const currentProduct = rows[0];

    await pool.query(
      `
        UPDATE products
        SET
            name = ?,
            price = ?,
            description = ?,
            image_url = ?
        WHERE id = ?
    `,
      [
        name ?? currentProduct.name,
        price ?? currentProduct.price,
        description ?? currentProduct.description,
        image_url ?? currentProduct.image_url,
        id,
      ],
    );

    res.json({
      success: true,
      message: "Product updated successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to update product",
    });
  }
});

app.delete("/api/products/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const [result]: any = await pool.query(
      "DELETE FROM products WHERE id = ?",
      [id],
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    res.json({
      success: true,
      message: "Product deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to delete product",
    });
  }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
