const express = require("express");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const { sendOTP } = require("../services/otpService");

const router = express.Router();

// Send OTP
router.post("/send-otp", async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: "Email is required" });
  
  try {
    await sendOTP(email);
    res.json({ message: "OTP sent successfully" });
  } catch (err) {
    res.status(500).json({ error: "Failed to send OTP" });
  }
});

// Verify OTP and return JWT token along with user_id
router.post("/verify-otp", async (req, res) => {
  const { email, otp } = req.body;
  if (!email || !otp) return res.status(400).json({ error: "Email and OTP are required" });

  try {
    const user = await User.findOne({ email });
    if (!user || user.otp !== otp || user.otpExpiry < Date.now()) {
      return res.status(400).json({ error: "Invalid or expired OTP" });
    }

    // Clear OTP fields after verification
    user.otp = null;
    user.otpExpiry = null;
    await user.save();

    // Create JWT token (include user id and email)
    const token = jwt.sign({ userId: user._id, email: user.email }, process.env.JWT_SECRET, { expiresIn: "7d" });
    
    // Return token and user_id (as a string)
    res.json({ message: "OTP verified", token, user_id: user._id.toString() });
  } catch (err) {
    res.status(500).json({ error: "Error verifying OTP" });
  }
});

module.exports = router;
