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
  const [rows] = await pool.query("SELECT * FROM products ORDER BY id DESC");

  res.json({
    success: true,
    data: rows,
  });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
