// routes/adminInvoiceRoutes.js
import express from "express";
import multer from "multer";
import fs from "fs";
import path from "path";
import Order from "../models/Order.js";
import { sendEmail } from "../utils/sendEmail.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";

const router = express.Router();

// 📁 Configure Multer Storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadPath = "uploads/invoices";
    fs.mkdirSync(uploadPath, { recursive: true });
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, `${uniqueSuffix}${path.extname(file.originalname)}`);
  },
});
const upload = multer({ storage });

/**
 * 🧾 POST /api/admin/orders/:orderId/invoice
 * Upload invoice for a specific order (Admin only)
 */
router.post(
  "/orders/:orderId/invoice",
  protect,
  authorizeRoles("admin"),
  upload.single("invoice"),
  async (req, res) => {
    try {
      const { orderId } = req.params;

      const order = await Order.findById(orderId).populate("user");
      if (!order) return res.status(404).json({ message: "Order not found" });

      if (!req.file)
        return res.status(400).json({ message: "Please upload a file" });

      const invoicePath = `uploads/invoices/${req.file.filename}`;
      const invoiceUrl = `/uploads/invoices/${req.file.filename}`;

      order.invoiceUrl = invoiceUrl;
      await order.save();

      // ✅ Send email to user with invoice attached
      await sendEmail(
        order.user.email,
        "Your Invoice is Ready 🧾",
        `
          <p>Hi ${order.user.name},</p>
          <p>Your invoice for <b>Order ID: ${order._id}</b> has been generated.</p>
          
          <p>You can download it from here:</p>
          <p><a href="${process.env.BASE_URL}${invoiceUrl}" target="_blank">Download Invoice</a></p>

          <br/>
          <p>Thank you for shopping with us!</p>
          <p><b>Your Store Team</b></p>
        `,
        [
          {
            filename: req.file.originalname || "invoice.pdf",
            path: invoicePath, // ✅ actual file path to attach
          },
        ]
      );

      res.json({
        message: "✅ Invoice uploaded & email sent successfully",
        invoiceUrl,
      });
    } catch (error) {
      console.error("Invoice Upload Error:", error);
      res.status(500).json({ message: error.message });
    }
  }
);

export default router;
