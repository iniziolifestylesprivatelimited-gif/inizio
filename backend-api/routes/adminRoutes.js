import express from "express";
import bcrypt from "bcryptjs";
import User from "../models/User.js";
import jwt from "jsonwebtoken";
import { protect } from "../middleware/authMiddleware.js";
import Notification from "../models/Notification.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";
import { sendEmail } from "../utils/sendEmail.js";
import { sendPush } from "../utils/fcm.js";


const router = express.Router();

// 🔹 Register Admin (same)
router.post("/register", async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const exists = await User.findOne({ email });
    if (exists) return res.status(400).json({ message: "Admin exists" });

    const hashed = await bcrypt.hash(password, 10);
    const admin = await User.create({
      name,
      email,
      password: hashed,
      role: "admin",
      isApproved: true,
    });

    res.status(201).json({ message: "Admin created", admin });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get all notifications (Admin View)
router.get("/notifications", protect, authorizeRoles("admin"), async (req, res) => {
  const list = await Notification.find()
    .sort({ createdAt: -1 })
    .populate("user", "name email"); // show customer info
  res.json(list);
});


// 🔑 Admin Login
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "Admin not found" });

    // Check role
    if (user.role !== "admin")
      return res.status(403).json({ message: "Not authorized as admin" });

    // Check if password exists
    if (!user.password)
      return res.status(403).json({ message: "No password set. Contact superadmin." });

    // Verify password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: "Invalid credentials" });

    // Create token
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: "7d" });

    res.json({ token,_id: user._id,  role: user.role, name: user.name, email: user.email });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
router.get("/admin-id", async (req, res) => {
  const admin = await User.findOne({ role: "admin" });
  res.json({ adminId: admin._id });
});


// 🔹 Fetch All Customers
router.get("/customers", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    const customers = await User.find({ role: "customer" })
      .select("-password"); // hide password for security

    res.json(customers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


// 🔹 Approve GST & Send Password
router.put("/approve/:id", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: "User not found" });

    if (user.isApproved)
      return res.status(400).json({ message: "User already approved" });

    // Mark approved
    user.isApproved = true;

    // Generate random password
    const plainPassword = Math.random().toString(36).slice(-8); // 8-char random password
    const hashedPassword = await bcrypt.hash(plainPassword, 10);
    user.password = hashedPassword;

    await user.save();

    // Send email
    await sendEmail(
      user.email,
      "GST Approved — Login Credentials",
      `<p>Hi ${user.name},</p>
       <p>Your GST has been approved! You can now log in with the following credentials:</p>
       <p><b>Email:</b> ${user.email}</p>
       <p><b>Password:</b> ${plainPassword}</p>
       <p>For security reasons, please change your password after logging in.</p>`
    );

    res.json({ message: "User approved and credentials sent to email" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ❌ Reject Customer
router.delete("/reject/:id", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: "User not found" });

    await user.deleteOne();
    res.json({ message: "User rejected & removed from system" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/notify", protect, authorizeRoles("admin"), async (req, res) => {
  const { customerId, title, message } = req.body;

  // Save in DB
  const notification = await Notification.create({
    user: customerId,
    title,
    message,
  });

  // Get customer FCM token
  const user = await User.findById(customerId);
  if (user?.fcmToken) {
    // ✅ Send push notification
    await sendPush(user.fcmToken, title, message);
  }

  // ✅ Send realtime socket notification
  req.io.to(customerId.toString()).emit("notification", {
    _id: notification._id,
    title,
    message,
    isRead: false,
    createdAt: notification.createdAt
  });

  res.json({ success: true });
});


// 🔹 List Pending Users
router.get("/pending", protect, authorizeRoles("admin"), async (req, res) => {
  const users = await User.find({ isApproved: false, role: "customer" });
  res.json(users);
});

export default router;
