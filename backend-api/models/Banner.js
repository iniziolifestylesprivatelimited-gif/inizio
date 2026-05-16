import mongoose from "mongoose";

const bannerSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    image: { type: String, required: true },
    link: { type: String }, // optional redirect link
    isActive: { type: Boolean, default: true },
    position: {
      type: String,
      enum: ["homepage", "category", "offers"],
      default: "homepage",
    },
  },
  { timestamps: true }
);

export default mongoose.model("Banner", bannerSchema);
