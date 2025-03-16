const mongoose = require("mongoose");

const ExpenseSchema = new mongoose.Schema({
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  friend: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  totalAmount: { type: Number, required: true },
  // Option string can be: "you_paid_split", "you_owed_full", "user_paid_split", "user_owed_full"
  option: { type: String, required: true },
  // Computed amounts:
  amountOwedByCreator: { type: Number, required: true },
  amountOwedByFriend: { type: Number, required: true },
  description: { type: String },
  date: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Expense", ExpenseSchema);
