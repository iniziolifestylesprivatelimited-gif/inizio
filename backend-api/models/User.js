import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  password: { type: String }, // now optional (created after approval)
  role: {
    type: String,
    enum: ["admin", "customer", "billing"],
    default: "customer",
  },
  fcmToken: { type: String },
  gstNumber: { type: String },
  gstDocument: { type: String },
  isApproved: { type: Boolean, default: false },
  resetPasswordToken: { type: String },
  resetPasswordExpire: { type: Date },
}, { timestamps: true });

export default mongoose.model("User", userSchema);
