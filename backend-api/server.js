import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import path from "path";
import http from "http"; 
import { Server } from "socket.io";
import connectDB from "./config/db.js";
import { sendPush } from "./utils/fcm.js";
import User from "./models/User.js";
import Notification from "./models/Notification.js"; // ✅ ADD THIS
import Message from "./models/Message.js"; // 👈 NEW

// Routes
import authRoutes from "./routes/authRoutes.js";
import adminRoutes from "./routes/adminRoutes.js";
import bannerRoutes from "./routes/bannerRoutes.js";
import brandRoutes from "./routes/brandRoutes.js";
import categoryRoutes from "./routes/categoryRoutes.js";
import productRoutes from "./routes/productRoutes.js";
import cartRoutes from "./routes/cartRoutes.js";
import orderRoutes from "./routes/orderRoutes.js";
import addressRoutes from "./routes/addressRoutes.js";
import adminInvoiceRoutes from "./routes/adminInvoiceRoutes.js";
import chatRoutes from "./routes/chatRoutes.js"; // 👈 NEW
import notificationRoutes from "./routes/notificationRoutes.js";
import termsRoutes from "./routes/termsRoutes.js"; 
import privacyRoutes from "./routes/privacyRoutes.js";
import faqRoutes from "./routes/faqRoutes.js";



dotenv.config();
connectDB();

const app = express();
const server = http.createServer(app); // 👈 IMPORTANT
const io = new Server(server, {
  cors: { origin: "*" }
});

// ✅ Middleware
app.use(cors({}));
app.use(express.json());
app.use("/uploads", express.static(path.join(process.cwd(), "uploads")));

app.use((req, res, next) => {
  req.io = io;
  next();
});


// ✅ API Routes
app.use("/api/auth", authRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/admin", adminInvoiceRoutes);
app.use("/api/banners", bannerRoutes);
app.use("/api/brands", brandRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/products", productRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/address", addressRoutes);
app.use("/api/chat", chatRoutes); // 👈 NEW
app.use("/api/notifications", notificationRoutes);
app.use("/api/terms", termsRoutes); 
app.use("/api/privacy", privacyRoutes);
app.use("/api/faqs", faqRoutes);


// ✅ SOCKET.IO REAL-TIME CHAT
io.on("connection", (socket) => {
  console.log("✅ User connected:", socket.id);

  let currentUserId = null;

  socket.on("join", (userId) => {
  currentUserId = userId;
  socket.join(userId);
});
  // typing indicators
  socket.on("typing", ({ senderId, receiverId }) => {
    io.to(receiverId).emit("typing", { senderId });
  });
  socket.on("stopTyping", ({ senderId, receiverId }) => {
    io.to(receiverId).emit("stopTyping", { senderId });
  });

  // send message
  socket.on("sendMessage", async ({ senderId, receiverId, message }) => {
    if (!senderId || !receiverId || !message?.trim()) return;

    // 1) Save
    const msg = await Message.create({
      sender: senderId,
      receiver: receiverId,
      message: message.trim(),
      status: "sent",
    });

    // 2) Deliver live to both
    io.to(receiverId).emit("receiveMessage", msg);
    io.to(senderId).emit("receiveMessage", msg);

    // 2a) If receiver is online (in room), mark delivered
    const receiverRoom = io.sockets.adapter.rooms.get(receiverId);
    if (receiverRoom && receiverRoom.size > 0) {
      await Message.findByIdAndUpdate(msg._id, { status: "delivered" });
      io.to(senderId).emit("messageStatus", {
        messageId: msg._id.toString(),
        status: "delivered",
      });
    }

    // 3) Create in-app notification
    const notify = await Notification.create({
      user: receiverId,
      title: "New Message",
      message: message.trim(),
    });
    io.to(receiverId).emit("notification", notify);

    // 4) FCM push for background/cold app
    const receiver = await User.findById(receiverId);
    if (receiver?.fcmToken) {
      try {
        await sendPush(receiver.fcmToken, "New Message", message.trim());
      } catch (e) {
        console.error("FCM send error:", e?.message || e);
      }
    }
  });

  /**
   * Optional socket path to mark messages seen without REST:
   * client can emit 'markSeen' when opening chat
   */
  socket.on("markSeen", async ({ meId, otherId }) => {
    const now = new Date();
    const toUpdate = await Message.updateMany(
      { sender: otherId, receiver: meId, isRead: false },
      { $set: { isRead: true, status: "seen", readAt: now } }
    );
    // let the other side know which got seen
    const seenIds = await Message.find({
      sender: otherId,
      receiver: meId,
      status: "seen",
      readAt: { $gte: now },
    }).select("_id");

    io.to(otherId).emit("messagesSeen", {
      by: meId,
      ids: seenIds.map((m) => m._id.toString()),
    });
  });

 socket.on("disconnect", () => {
  if (currentUserId) {
    // We don't know the peer, but clearing on client timeout + this helps
    io.to(currentUserId).emit("stopTyping", { senderId: currentUserId });
  }
  console.log("❌ User disconnected:", socket.id);
});
});

// ✅ Server start
const PORT = process.env.PORT || 5000;
server.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running at http://0.0.0.0:${PORT}`);
});