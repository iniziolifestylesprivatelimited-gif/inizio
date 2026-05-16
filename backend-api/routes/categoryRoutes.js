import express from "express";
import multer from "multer";
import Category from "../models/Category.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";

const router = express.Router();

// File upload setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/categories/"),
  filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage });

// ➕ Create Category
router.post("/", protect, authorizeRoles("admin"), upload.single("icon"), async (req, res) => {
  try {
    const { name, description } = req.body;
    const icon = req.file?.path;

    const exists = await Category.findOne({ name });
    if (exists) return res.status(400).json({ message: "Category already exists" });

    const category = await Category.create({ name, description, icon });
    res.status(201).json(category);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// � Get All Categories
router.get("/", async (req, res) => {
  const categories = await Category.find();
  res.json(categories);
});

// � Update Category
router.put("/:id", protect, authorizeRoles("admin"), upload.single("icon"), async (req, res) => {
  try {
    const { name, description, isActive } = req.body;
    const updateData = { name, description, isActive };
    if (req.file) updateData.icon = req.file.path;

    const category = await Category.findByIdAndUpdate(req.params.id, updateData, { new: true });
    res.json(category);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ❌ Delete Category
router.delete("/:id", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    await Category.findByIdAndDelete(req.params.id);
    res.json({ message: "Category deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// 🧩 Get Category Details with Brands and Products
router.get("/:categoryId/details", async (req, res) => {
  try {
    const { categoryId } = req.params;

    // 1️⃣ Find category info
    const category = await Category.findById(categoryId);
    if (!category) return res.status(404).json({ message: "Category not found" });

    // 2️⃣ Find all products under this category
    const products = await Product.find({ category: categoryId })
      .populate("brand", "name logo")
      .populate("category", "name icon");

    // 3️⃣ Extract unique brand IDs from these products
    const brandIds = [...new Set(products.map((p) => p.brand?._id?.toString()))];

    // 4️⃣ Fetch those brands
    const brands = await Brand.find({ _id: { $in: brandIds } });

    res.json({
      category,
      brands,
      products,
    });
  } catch (error) {
    console.error("Error fetching category details:", error);
    res.status(500).json({ message: error.message });
  }
});

export default router;
