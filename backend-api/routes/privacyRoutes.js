import express from "express";
import Privacy from "../models/Privacy.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";

const router = express.Router();

/**
 * @route POST /api/privacy
 * @desc Create or update Privacy Policy
 * @access Admin only
 */
router.post("/", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    const { content } = req.body;
    if (!content?.trim()) {
      return res.status(400).json({ message: "Content is required" });
    }

    // If exists → update
    let privacy = await Privacy.findOne();
    if (privacy) {
      privacy.content = content;
      privacy.updatedBy = req.user._id;
      await privacy.save();
    } else {
      privacy = await Privacy.create({
        content,
        updatedBy: req.user._id,
      });
    }

    res.json({ message: "Privacy Policy updated successfully", privacy });
  } catch (error) {
    console.error("Error saving privacy policy:", error);
    res.status(500).json({ message: "Server Error" });
  }
});

/**
 * @route GET /api/privacy
 * @desc Get Privacy Policy (public)
 */
router.get("/", async (req, res) => {
  try {
    const privacy = await Privacy.findOne().sort({ updatedAt: -1 });
    if (!privacy) return res.status(404).json({ message: "No privacy policy found" });
    res.json(privacy);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
