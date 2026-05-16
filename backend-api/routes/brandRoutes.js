import express from "express";
import multer from "multer";
import Brand from "../models/Brand.js";
import Product from "../models/Product.js";
import Category from "../models/Category.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";

const router = express.Router();

// File upload setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/brands/"),
  filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage });

// ➕ Create Brand
router.post("/", protect, authorizeRoles("admin"), upload.single("logo"), async (req, res) => {
  try {
    const { name, description } = req.body;
    const logo = req.file?.path;

    const exists = await Brand.findOne({ name });
    if (exists) return res.status(400).json({ message: "Brand already exists" });

    const brand = await Brand.create({ name, description, logo });
    res.status(201).json(brand);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// � Get All Brands
router.get("/", async (req, res) => {
  const brands = await Brand.find();
  res.json(brands);
});

// ✅ Get brands by category
// ✅ Get brands by category
router.get("/category/:categoryId", async (req, res) => {
  try {
    const { categoryId } = req.params;

    // 1️⃣ Find products under this category and populate brand
    const products = await Product.find({ category: categoryId })
      .populate("brand", "name logo");

    // 2️⃣ Extract unique brands
    const brandMap = new Map();
    products.forEach(p => {
      if (p.brand?._id) {
        brandMap.set(p.brand._id.toString(), p.brand);
      }
    });

    const brands = Array.from(brandMap.values());

    if (brands.length === 0) {
      return res.status(404).json({
        message: "No brands found for this category",
        brands: []
      });
    }

    res.json(brands);

  } catch (err) {
    console.error("Brand fetch error:", err);
    res.status(500).json({ message: err.message });
  }
});



// � Update Brand
router.put("/:id", protect, authorizeRoles("admin"), upload.single("logo"), async (req, res) => {
  try {
    const { name, description, isActive } = req.body;
    const updateData = { name, description, isActive };
    if (req.file) updateData.logo = req.file.path;

    const brand = await Brand.findByIdAndUpdate(req.params.id, updateData, { new: true });
    res.json(brand);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ❌ Delete Brand
router.delete("/:id", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    await Brand.findByIdAndDelete(req.params.id);
    res.json({ message: "Brand deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// 🧩 Get Brand Details with Categories and Products
router.get("/:brandId/details", async (req, res) => {
  try {
    const { brandId } = req.params;

    // 1️⃣ Find the brand info
    const brand = await Brand.findById(brandId);
    if (!brand) return res.status(404).json({ message: "Brand not found" });

    // 2️⃣ Find all products for this brand
    const products = await Product.find({ brand: brandId })
      .populate("brand", "name logo")
      .populate("category", "name icon");

    // 3️⃣ Extract unique category IDs from these products
    const categoryIds = [...new Set(products.map((p) => p.category?._id?.toString()))];

    // 4️⃣ Fetch those categories
    const categories = await Category.find({ _id: { $in: categoryIds } });

    res.json({
      brand,
      categories,
      products,
    });
  } catch (error) {
    console.error("Error fetching brand details:", error);
    res.status(500).json({ message: error.message });
  }
});


export default router;
