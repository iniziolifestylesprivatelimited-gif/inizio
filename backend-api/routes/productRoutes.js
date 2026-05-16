import express from "express";
import multer from "multer";
import Product from "../models/Product.js";
import XLSX from "xlsx";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";
const excelUpload = multer({ dest: "uploads/excel/" });

const router = express.Router();
// ⚙️ Multer storage config
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/products/"),
  filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage });

// 🧩 Dynamic fields for variant images
const multipleUpload = upload.fields([
  { name: "images", maxCount: 10 }, // product-level images
  { name: "variantImages", maxCount: 50 }, // variant-level images (any number)
]);

// 🆕 Create Product with variant images
router.post("/", protect, authorizeRoles("admin"), multipleUpload, async (req, res) => {
  try {
    const { name, description, basePrice, offerPrice, category, brand, totalQuantity } = req.body;
    let { variants, images } = req.body;

    if (!name || !basePrice || !category || !brand) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    // ✅ If uploads exist → use multer paths
    const productImages = req.files?.images ? req.files["images"].map((f) => f.path) : [];

    // ✅ If images passed as URLs JSON
    if (!productImages.length && images) {
      try {
        images = Array.isArray(images) ? images : JSON.parse(images);
      } catch {
        return res.status(400).json({ message: "Invalid images format" });
      }
    }

    // ✅ Parse variants (string or array)
    if (variants) {
      variants = Array.isArray(variants) ? variants : JSON.parse(variants);
    } else {
      variants = [];
    }

    // ✅ Attach variant file images if multer used
    if (req.files?.variantImages) {
      const variantImgs = req.files["variantImages"];
      variants = variants.map((v, i) => ({
        ...v,
        images: variantImgs
          .filter((file) => file.originalname.startsWith(`variant-${i}-`))
          .map((file) => file.path),
      }));
    }

    const product = await Product.create({
      name,
      description,
      basePrice,
      offerPrice,
      category,
      brand,
      totalQuantity: totalQuantity || null,
      variants,
      images: productImages.length ? productImages : images || [],
    });

    res.status(201).json(product);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/products?brand=brandId&category=categoryId
router.get("/", async (req, res) => {
  try {
    const { brand, category } = req.query;

    const filter = {};
    if (brand) filter.brand = brand;
    if (category) filter.category = category;

    const products = await Product.find(filter)
      .populate("brand", "name logo")
      .populate("category", "name icon");

    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// 🏷️ Get Products by Brand ID
router.get("/brand/:brandId", async (req, res) => {
  try {
    const { brandId } = req.params;

    const products = await Product.find({ brand: brandId })
      .populate("brand", "name logo")
      .populate("category", "name icon");

    if (!products || products.length === 0) {
      return res.status(404).json({ message: "No products found for this brand." });
    }

    res.json(products);
  } catch (error) {
    console.error("Error fetching products by brand:", error);
    res.status(500).json({ message: error.message });
  }
});

// 📦 Get Products by Category ID
router.get("/category/:categoryId", async (req, res) => {
  try {
    const { categoryId } = req.params;

    const products = await Product.find({ category: categoryId })
      .populate("brand", "name logo")
      .populate("category", "name icon");

    if (!products || products.length === 0) {
      return res.status(404).json({ message: "No products found for this category." });
    }

    res.json(products);
  } catch (error) {
    console.error("Error fetching products by category:", error);
    res.status(500).json({ message: error.message });
  }
});

// 📥 BULK UPLOAD PRODUCTS (Excel)
router.post("/bulk-upload", protect, authorizeRoles("admin"), excelUpload.single("file"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "Excel file is required" });

    const workbook = XLSX.readFile(req.file.path);
    const sheet = workbook.Sheets[workbook.SheetNames[0]];
    const rows = XLSX.utils.sheet_to_json(sheet);

    const insertData = rows.map((row) => ({
      name: row.name,
      description: row.description || "",
      basePrice: Number(row.basePrice || 0),
      offerPrice: Number(row.offerPrice || 0),
      category: row.category_id,
      brand: row.brand_id,
      totalQuantity: Number(row.totalQuantity || 0),
      images: row.images ? row.images.split(",").map((i) => i.trim()) : [],
      variants: row.variants ? JSON.parse(row.variants) : [],
    }));

    await Product.insertMany(insertData);
    res.json({ message: "✅ Bulk Upload Successful" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});



// 📤 EXPORT PRODUCTS TO EXCEL
router.get("/export/excel", async (req, res) => {
  try {
    const products = await Product.find().populate("brand category", "name");

    const data = products.map((p) => ({
      name: p.name,
      description: p.description || "",
      basePrice: p.basePrice || "",
      offerPrice: p.offerPrice || "",
      category: p.category?.name || "",
      category_id: p.category?._id?.toString() || "",
      brand: p.brand?.name || "",
      brand_id: p.brand?._id?.toString() || "",
      totalQuantity: p.totalQuantity || "",
      images: p.images?.join(", ") || "",
      variants: JSON.stringify(p.variants || []),
    }));

    const worksheet = XLSX.utils.json_to_sheet(data);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, "Products");

    res.setHeader(
      "Content-Disposition",
      "attachment; filename=products-export.xlsx"
    );
    res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");

    XLSX.write(workbook, { type: "buffer", bookType: "xlsx" });
    res.send(XLSX.write(workbook, { type: "buffer", bookType: "xlsx" }));
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});



// 🔍 Get Single Product
router.get("/:id", async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)
      .populate("category", "name")
      .populate("brand", "name");

    if (!product) return res.status(404).json({ message: "Product not found" });
    res.json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ✏️ Update Product
router.put("/:id", protect, authorizeRoles("admin"), upload.array("images", 10), async (req, res) => {
  try {
    const { name, description, basePrice,offerPrice, category, brand, totalQuantity, isActive, variants } = req.body;

    const updateData = {
      name,
      description,
      basePrice,
      offerPrice,
      category,
      brand,
      totalQuantity,
      isActive,
    };

    if (req.files?.length) {
      updateData.images = req.files.map((file) => file.path);
    }

    if (variants) {
      try {
        updateData.variants = JSON.parse(variants);
      } catch {
        return res.status(400).json({ message: "Invalid variants JSON" });
      }
    }

    const product = await Product.findByIdAndUpdate(req.params.id, updateData, { new: true });
    res.json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ❌ Delete Product
router.delete("/:id", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ message: "Product deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
export default router;