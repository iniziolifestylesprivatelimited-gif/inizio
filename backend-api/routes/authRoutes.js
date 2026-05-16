import express from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import multer from "multer";
import User from "../models/User.js";
import { sendEmail } from "../utils/sendEmail.js";
import { protect } from "../middleware/authMiddleware.js"; // ✅ ADD THIS

const router = express.Router();

// 🔹 Multer for GST uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage });

// 🧾 Customer Registration
router.post("/register", upload.single("gstDocument"), async (req, res) => {
  try {
    const { name, email, gstNumber } = req.body;
    const gstDocument = req.file?.path;

    const userExists = await User.findOne({ email });
    if (userExists) return res.status(400).json({ message: "User already exists" });

    await User.create({
      name,
      email,
      gstNumber,
      gstDocument,
      role: "customer",
      isApproved: false,
    });

    await sendEmail(
      email,
      "Registration Received",
      `<p>Hi ${name},</p>
       <p>Your registration was successful! Your GST is awaiting admin approval.</p>`
    );

    res.status(201).json({ message: "Registered successfully, awaiting admin approval" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// 🧑‍💼 Login
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "User not found" });
    if (user.role === "customer" && !user.isApproved)
      return res.status(403).json({ message: "GST not approved by admin. Once approved you will receive password " });
    if (!user.password)
      return res.status(403).json({ message: "No password assigned. Wait for approval." });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: "Invalid credentials" });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: "7d" });

    // send user info + token
    res.json({ token, role: user.role, _id: user._id, name: user.name });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/save-fcm-token", async (req, res) => {
  try {
    const { userId, token } = req.body;

    await User.findByIdAndUpdate(userId, { fcmToken: token });

    res.json({ message: "FCM Token Saved ✅" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


// 🔁 Forgot Password — Generate & Email New Password
router.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "User not found" });

    const newPassword = Math.random().toString(36).slice(-8);
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    await user.save();

    await sendEmail(
      user.email,
      "New Password Assigned",
      `<p>Hi ${user.name},</p>
       <p>Your password has been reset. Use the credentials below to log in:</p>
       <p><b>Email:</b> ${user.email}</p>
       <p><b>Password:</b> ${newPassword}</p>
       <p>Please change it after logging in for security.</p>`
    );

    res.json({ message: "New password sent to registered email" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// 📝 Update User
router.put("/update/:id", protect, async (req, res) => {
  try {
    const { name, email, gstNumber, role, isApproved } = req.body;

    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: "User not found" });

    // Allow only admins to update role + approval
    if (role || isApproved !== undefined) {
      if (req.user.role !== "admin") {
        return res.status(403).json({ message: "Admin only fields" });
      }
    }

    // Basic fields user can update
    if (name) user.name = name;
    if (email) user.email = email.toLowerCase(); // fix case sensitivity
    if (gstNumber) user.gstNumber = gstNumber;

    // Admin-only
    if (role) user.role = role;
    if (isApproved !== undefined) user.isApproved = isApproved;

    await user.save();

    res.json({ message: "User updated successfully", user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// 🗑 Delete User (Admin Only)
router.delete("/delete/:id", protect, async (req, res) => {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({ message: "Only admin can delete users" });
    }

    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: "User not found" });

    await user.deleteOne();

    res.json({ message: "User deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


// backend/routes/authRoutes.js
// ✅ Get logged-in user details
router.get("/me", protect, async (req, res) => {
  const user = await User.findById(req.user._id)
    .select("_id name email role isApproved");
  res.json(user);
});


export default router;
