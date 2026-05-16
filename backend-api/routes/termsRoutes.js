import express from "express";
import Terms from "../models/Terms.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";

const router = express.Router();

/**
 * @route POST /api/terms
 * @desc Create or update Terms & Conditions
 * @access Admin only
 */
router.post("/", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    const { content } = req.body;
    if (!content?.trim()) {
      return res.status(400).json({ message: "Content is required" });
    }

    // If exists, update instead of create
    let terms = await Terms.findOne();
    if (terms) {
      terms.content = content;
      terms.updatedBy = req.user._id;
      await terms.save();
    } else {
      terms = await Terms.create({
        content,
        updatedBy: req.user._id,
      });
    }

    res.json({ message: "Terms & Conditions updated successfully", terms });
  } catch (error) {
    console.error("Error saving terms:", error);
    res.status(500).json({ message: "Server Error" });
  }
});

/**
 * @route GET /api/terms
 * @desc Get current Terms & Conditions (for both Admin and Flutter users)
 * @access Public
 */
router.get("/", async (req, res) => {
  try {
    const terms = await Terms.findOne().sort({ updatedAt: -1 });
    if (!terms) return res.status(404).json({ message: "No terms found" });
    res.json(terms);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
