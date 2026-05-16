// routes/notificationRoutes.js
import express from "express";
import { protect } from "../middleware/authMiddleware.js";
import Notification from "../models/Notification.js";

const router = express.Router();

// List my notifications (newest first)
router.get("/", protect, async (req, res) => {
  const list = await Notification.find({ user: req.user._id })
    .sort({ createdAt: -1 })
    .populate("user", "name email"); // ✅ ADD THIS
  res.json(list);
});


// Mark one as read
router.put("/:id/read", protect, async (req, res) => {
  await Notification.findOneAndUpdate({ _id: req.params.id, user: req.user._id }, { isRead: true });
  res.json({ ok: true });
});

// Mark all as read (optional)
router.put("/read-all", protect, async (req, res) => {
  await Notification.updateMany({ user: req.user._id, isRead: false }, { isRead: true });
  res.json({ ok: true });
});

// Delete notification
router.delete("/:id", protect, async (req, res) => {
  await Notification.deleteOne({ _id: req.params.id, user: req.user._id });
  res.json({ success: true });
});

// Update notification text
router.put("/:id", protect, async (req, res) => {
  const { title, message } = req.body;
  await Notification.updateOne(
    { _id: req.params.id, user: req.user._id },
    { title, message }
  );
  res.json({ success: true });
});


export default router;
