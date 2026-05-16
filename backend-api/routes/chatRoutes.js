import express from "express";
import Message from "../models/Message.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

/**
 * GET /api/chat/:userId
 * Returns the full conversation (oldest -> newest)
 */
router.get("/:userId", protect, async (req, res) => {
  const { userId } = req.params;

  const messages = await Message.find({
    $or: [
      { sender: req.user._id, receiver: userId },
      { sender: userId, receiver: req.user._id },
    ],
  })
    .sort({ createdAt: 1 })
    .lean();

  res.json(messages);
});

/**
 * PUT /api/chat/read/:userId
 * Mark all messages from :userId → me as seen
 */
router.put("/read/:userId", protect, async (req, res) => {
  const { userId } = req.params;
  const now = new Date();

  // Update unread → seen
  const result = await Message.updateMany(
    { sender: userId, receiver: req.user._id, isRead: false },
    { $set: { isRead: true, status: "seen", readAt: now } }
  );

  // Emit to the sender so their ticks turn blue
  try {
    // req.io is attached in server.js middleware
    const seenIds = await Message.find({
      sender: userId,
      receiver: req.user._id,
      status: "seen",
      readAt: { $gte: now },
    }).select("_id");

    req.io.to(userId.toString()).emit("messagesSeen", {
      by: req.user._id.toString(),
      ids: seenIds.map((m) => m._id.toString()),
    });
  } catch (e) {
    // no-op if socket not available
  }

  res.json({ success: true, modified: result.modifiedCount });
});

export default router;
