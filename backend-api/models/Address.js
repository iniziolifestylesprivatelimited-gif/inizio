import mongoose from "mongoose";

const addressSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    name: { type: String, required: true }, // e.g., "Home", "Office"
    phone: {
      type: String,
      required: true,
      validate: {
        validator: function (v) {
          return /^\d{10}$/.test(v); // 10-digit phone number
        },
        message: props => `${props.value} is not a valid 10-digit phone number!`,
      },
    },
    addressLine1: { type: String, required: true },
    addressLine2: { type: String },
    city: { type: String, required: true },
    state: { type: String, required: true },
    country: { type: String, required: true },
    pincode: {
      type: String,
      required: true,
      validate: {
        validator: function (v) {
          return /^\d{6}$/.test(v); // 6-digit Indian pincode
        },
        message: props => `${props.value} is not a valid 6-digit pincode!`,
      },
    },
  },
  { timestamps: true }
);

export default mongoose.model("Address", addressSchema);
