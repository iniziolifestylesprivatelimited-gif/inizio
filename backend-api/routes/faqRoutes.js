import express from "express";
import Faq from "../models/Faq.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";

const router = express.Router();

/**
 * @route POST /api/faqs
 * @desc Create a FAQ
 * @access Admin only
 */
router.post("/", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    const { question, answer } = req.body;

    if (!question?.trim() || !answer?.trim()) {
      return res.status(400).json({ message: "Question and Answer are required" });
    }

    const faq = await Faq.create({
      question,
      answer,
      updatedBy: req.user._id,
    });

    res.json({ message: "FAQ created successfully", faq });
  } catch (error) {
    console.error("Error creating FAQ:", error);
    res.status(500).json({ message: "Server Error" });
  }
});

/**
 * @route PUT /api/faqs/:id
 * @desc Update a FAQ
 * @access Admin only
 */
router.put("/:id", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    const { question, answer } = req.body;

    const faq = await Faq.findById(req.params.id);
    if (!faq) return res.status(404).json({ message: "FAQ not found" });

    faq.question = question || faq.question;
    faq.answer = answer || faq.answer;
    faq.updatedBy = req.user._id;

    await faq.save();

    res.json({ message: "FAQ updated successfully", faq });
  } catch (error) {
    console.error("Error updating FAQ:", error);
    res.status(500).json({ message: "Server Error" });
  }
});

/**
 * @route DELETE /api/faqs/:id
 * @desc Delete FAQ
 * @access Admin only
 */
router.delete("/:id", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    const faq = await Faq.findById(req.params.id);
    if (!faq) return res.status(404).json({ message: "FAQ not found" });

    await faq.deleteOne();

    res.json({ message: "FAQ deleted successfully" });
  } catch (error) {
    console.error("Error deleting FAQ:", error);
    res.status(500).json({ message: "Server Error" });
  }
});

/**
 * @route GET /api/faqs
 * @desc Get all FAQs (public)
 */
router.get("/", async (req, res) => {
  try {
    const faqs = await Faq.find().sort({ createdAt: -1 });
    res.json(faqs);
  } catch (error) {
    console.error("Error fetching FAQs:", error);
    res.status(500).json({ message: "Server Error" });
  }
});

export default router;
