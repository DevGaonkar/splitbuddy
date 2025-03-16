const mongoose = require("mongoose");

const BalanceSchema = new mongoose.Schema({
  user1: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  user2: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  // If positive, user2 owes user1; if negative, user1 owes user2.
  balance: { type: Number, required: true, default: 0 }
});

module.exports = mongoose.model("Balance", BalanceSchema);
