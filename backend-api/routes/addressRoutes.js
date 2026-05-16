import express from "express";
import Address from "../models/Address.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

// Add a new address
router.post("/", protect, async (req, res) => {
  try {
    const { name, phone, addressLine1, addressLine2, city, state, country, pincode } = req.body;

    const address = await Address.create({
      user: req.user._id,
      name,
      phone,
      addressLine1,
      addressLine2,
      city,
      state,
      country,
      pincode,
    });

    res.status(201).json(address);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Get user's addresses
router.get("/", protect, async (req, res) => {
  try {
    const addresses = await Address.find({ user: req.user._id });
    res.json(addresses);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update an address
router.put("/:id", protect, async (req, res) => {
  try {
    const address = await Address.findOne({ _id: req.params.id, user: req.user._id });
    if (!address) {
      return res.status(404).json({ message: "Address not found" });
    }

    const { name, phone, addressLine1, addressLine2, city, state, country, pincode } = req.body;

    address.name = name || address.name;
    address.phone = phone || address.phone;
    address.addressLine1 = addressLine1 || address.addressLine1;
    address.addressLine2 = addressLine2 || address.addressLine2;
    address.city = city || address.city;
    address.state = state || address.state;
    address.country = country || address.country;
    address.pincode = pincode || address.pincode;

    const updatedAddress = await address.save();
    res.json(updatedAddress);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Delete an address
router.delete("/:id", protect, async (req, res) => {
  try {
    const address = await Address.findOneAndDelete({ _id: req.params.id, user: req.user._id });
    if (!address) {
      return res.status(404).json({ message: "Address not found" });
    }
    res.json({ message: "Address deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
