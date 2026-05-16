import express from "express";
import multer from "multer";
import Banner from "../models/Banner.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";

const router = express.Router();

// File upload setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/banners/"),
  filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage });

// ➕ Create Banner
router.post("/", protect, authorizeRoles("admin"), upload.single("image"), async (req, res) => {
  try {
    const { title, link, position } = req.body;
    const image = req.file?.path;

    const banner = await Banner.create({ title, link, position, image });
    res.status(201).json(banner);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// � Get All Banners
router.get("/", async (req, res) => {
  const banners = await Banner.find();
  res.json(banners);
});

// � Update Banner
router.put("/:id", protect, authorizeRoles("admin"), upload.single("image"), async (req, res) => {
  try {
    const { title, link, position, isActive } = req.body;
    const updateData = { title, link, position, isActive };
    if (req.file) updateData.image = req.file.path;

    const banner = await Banner.findByIdAndUpdate(req.params.id, updateData, { new: true });
    res.json(banner);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ❌ Delete Banner
router.delete("/:id", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    await Banner.findByIdAndDelete(req.params.id);
    res.json({ message: "Banner deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
