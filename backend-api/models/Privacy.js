import mongoose from "mongoose";

const privacySchema = new mongoose.Schema(
  {
    content: {
      type: String,
      required: true,
    },
    updatedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Admin",
    },
  },
  { timestamps: true }
);

export default mongoose.model("Privacy", privacySchema);
