const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({

  firebaseUid: {
    type: String,
    required: true,
    unique: true,
  },

  name: String,
  email: String,
  role: String,
  phone: String,
  location: String,

  // Seller-specific fields
  businessName: String,
  businessType: String,
  fssaiNumber: String,

  // Volunteer-specific fields
  transportMode: String,
  dateOfBirth: String,

}, { timestamps: true });

module.exports = mongoose.model("User", userSchema);
