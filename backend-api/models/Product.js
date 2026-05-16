import mongoose from "mongoose";

// 🧩 Variant Schema (with images and quantity)
const variantSchema = new mongoose.Schema(
  {
    name: { type: String, required: true }, // e.g., "Red - M"
    images: [{ type: String }],
    quantity: { type: Number, required: true, min: 0 },
    price: { type: Number, min: 0 }, // variant price
    offerPrice: { type: Number, min: 0 }, // ✅ variant offer price
  },
  { _id: false }
);

const productSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, unique: true },
    description: { type: String },

    basePrice: { type: Number, required: true, min: 0 },
    offerPrice: { type: Number, min: 0 }, // ✅ product offer price

    images: [{ type: String }],

    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      required: true,
    },

    brand: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Brand",
      required: true,
    },

    totalQuantity: { type: Number, min: 0 },

    variants: [variantSchema],

    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

// 🧠 Ensure quantity or variants exist
productSchema.pre("save", function (next) {
  if ((!this.variants || this.variants.length === 0) && this.totalQuantity == null) {
    return next(new Error("Either variants or totalQuantity must be provided."));
  }
  next();
});

export default mongoose.model("Product", productSchema);
