import dotenv from "dotenv";
dotenv.config();
import express from "express";
import Order from "../models/Order.js";
import Cart from "../models/Cart.js";
import { protect } from "../middleware/authMiddleware.js";
import { authorizeRoles } from "../middleware/roleMiddleware.js";
import Razorpay from "razorpay";
import crypto from "crypto";
import { sendEmail } from "../utils/sendEmail.js";
const router = express.Router();

// Razorpay instance
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

/**
 * 🧾 POST /api/orders
 * Place a new order & create Razorpay order if paymentMethod = Razorpay
 */
router.post("/", protect, async (req, res) => {
  try {
    const { items, totalAmount, paymentMethod = "COD", addressId } = req.body;

    if (!items?.length) return res.status(400).json({ message: "No items to order" });
    if (!addressId)  return res.status(400).json({ message: "Address required" });

    const order = await Order.create({
      user: req.user._id,
      items,
      totalAmount: Number(totalAmount),
      paymentMethod,
      paymentStatus: paymentMethod === "COD" ? "Paid" : "Pending",
      address: addressId,
    });

    await Cart.findOneAndDelete({ user: req.user._id });

    if (paymentMethod === "COD") {
      await sendEmail(
        req.user.email,
        "Order Placed Successfully ✅",
        `<p>Hi ${req.user.name},</p>
         <p>Thank you! Your COD order has been placed successfully.</p>
         <p><b>Order ID:</b> ${order._id}</p>
         <p><b>Total Amount:</b> ₹${Number(totalAmount).toFixed(2)}</p>
         <p>You will receive your order soon.</p>`
      );
      return res.status(201).json({ message: "Order placed successfully", order });
    }

    // Razorpay flow
    const amountPaise = Math.round(Number(totalAmount) * 100);
    if (!Number.isInteger(amountPaise) || amountPaise < 100) {
      return res.status(400).json({ message: "Invalid amount" });
    }

    let razorpayOrder;
    try {
      razorpayOrder = await razorpay.orders.create({
        amount: amountPaise,
        currency: "INR",
        receipt: order._id.toString(),
        notes: { userId: req.user._id.toString() },
      });
    } catch (e) {
      // e?.error is Razorpay’s structured error
      console.error("Razorpay create order error:", e?.error || e);
      const msg = e?.error?.description || e?.message || "Failed to create Razorpay order";
      return res.status(502).json({ message: msg });
    }

    await sendEmail(
      req.user.email,
      "Order Confirmation — Awaiting Payment 💳",
      `<p>Hi ${req.user.name},</p>
       <p>Your order has been created but payment is pending.</p>
       <p><b>Order ID:</b> ${order._id}</p>
       <p>Please complete your payment to confirm your order.</p>`
    );

    return res.status(201).json({
      message: "Razorpay order created",
      orderId: order._id,
      razorpayOrder,
    });

  } catch (error) {
    console.error("Order Error:", error);
    return res.status(500).json({ message: error.message });
  }
});


router.get("/all", protect, authorizeRoles("admin"), async (req, res) => {
  const orders = await Order.find()
    .populate("items.product", "name basePrice images variants") 
    .populate("address")
    .populate("user", "name email")
    .sort({ createdAt: -1 });

  res.json(orders);
});


/**
 * ✅ POST /api/orders/verify
 * Verify Razorpay payment
 */
router.post("/verify", protect, async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature, orderId } = req.body;

    const generatedSignature = crypto
      .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
      .update(razorpay_order_id + "|" + razorpay_payment_id)
      .digest("hex");

    if (generatedSignature !== razorpay_signature) {
      return res.status(400).json({ message: "Payment verification failed" });
    }

    const order = await Order.findById(orderId);
    order.paymentStatus = "Paid";
    order.paymentMethod = "Razorpay";
    await order.save();

    // ✅ send email after successful payment
    await sendEmail(
      req.user.email,
      "Payment Successful 🎉",
      `<p>Hi ${req.user.name},</p>
      <p>Your payment has been successfully received.</p>
      <p><b>Order ID:</b> ${order._id}</p>
      <p>Thank you for shopping with us!</p>`
    );

    res.json({ message: "Payment verified & order confirmed", order });
  } catch (error) {
    console.error("Payment Verification Error:", error);
    res.status(500).json({ message: error.message });
  }
});

/**
 * ✏️ Update Order Status
 */
router.put("/:id/status", protect, authorizeRoles("admin"), async (req, res) => {
  try {
    const { orderStatus } = req.body;
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { orderStatus },
      { new: true }
    );

    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});



/**
 * 📦 GET /api/orders/my
 * Get logged-in user's orders
 */
router.get("/my", protect, async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user._id })
      .populate("items.product", "name basePrice images variants")
      .populate("address")
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
