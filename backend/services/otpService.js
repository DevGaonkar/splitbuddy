const nodemailer = require("nodemailer");
const User = require("../models/User");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL,
    pass: process.env.PASSWORD
  }
});

const sendOTP = async (email) => {
  // Generate a 6-digit OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // valid for 10 minutes

  // Create or update user with OTP
  await User.findOneAndUpdate(
    { email },
    { otp, otpExpiry },
    { upsert: true, new: true }
  );

  // Send OTP via email
  await transporter.sendMail({
    from: process.env.EMAIL,
    to: email,
    subject: "Your OTP for SplitBuddy",
    text: `Your OTP is ${otp}. It is valid for 10 minutes.`
  });

  return otp;
};

module.exports = { sendOTP };
