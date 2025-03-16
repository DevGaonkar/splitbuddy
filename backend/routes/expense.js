const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const User = require("../models/User");
const Expense = require("../models/Expense");
const Balance = require("../models/Balance");

const router = express.Router();

// Helper function to update balance between two users
const updateBalance = async (creatorId, friendId, amountChange) => {
  // Look for an existing balance record (order the user IDs consistently)
  let balanceRecord = await Balance.findOne({
    $or: [
      { user1: creatorId, user2: friendId },
      { user1: friendId, user2: creatorId }
    ]
  });

  if (!balanceRecord) {
    // Create a new record: by convention, set user1 as the creator
    balanceRecord = new Balance({
      user1: creatorId,
      user2: friendId,
      balance: amountChange
    });
  } else {
    // Determine the order to update the balance correctly
    if (balanceRecord.user1.toString() === creatorId.toString()) {
      // For creator: positive balance means friend owes creator
      balanceRecord.balance += amountChange;
    } else {
      // If creator is user2, reverse the sign
      balanceRecord.balance -= amountChange;
    }
  }
  await balanceRecord.save();
};

// Create a new expense
router.post("/create", authMiddleware, async (req, res) => {
  const { friendEmail, totalAmount, option, description } = req.body;
  const creatorId = req.user.userId;
  if (!friendEmail || !totalAmount || !option) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    // Find friend by email
    const friend = await User.findOne({ email: friendEmail });
    if (!friend) {
      return res.status(400).json({ error: "User does not exist." });
    }

    // Compute split amounts based on option:
    // Options:
    // "you_paid_split": You paid and split equally: friend owes you = totalAmount/2.
    // "you_owed_full": You are owed full: friend owes you = totalAmount.
    // "user_paid_split": Friend paid and split equally: you owe friend = totalAmount/2.
    // "user_owed_full": Friend is owed full: you owe friend = totalAmount.
    let amountOwedByCreator = 0;
    let amountOwedByFriend = 0;
    switch (option) {
      case "you_paid_split":
        amountOwedByFriend = totalAmount / 2;
        break;
      case "you_owed_full":
        amountOwedByFriend = totalAmount;
        break;
      case "user_paid_split":
        amountOwedByCreator = totalAmount / 2;
        break;
      case "user_owed_full":
        amountOwedByCreator = totalAmount;
        break;
      default:
        return res.status(400).json({ error: "Invalid split option" });
    }

    // Create expense document
    const expense = new Expense({
      createdBy: creatorId,
      friend: friend._id,
      totalAmount,
      option,
      amountOwedByCreator,
      amountOwedByFriend,
      description
    });
    await expense.save();

    // Update balance: 
    // For "you_paid_split" and "you_owed_full", friend owes you (balance increases by that amount).
    // For "user_paid_split" and "user_owed_full", you owe friend (balance decreases by that amount).
    let amountChange = 0;
    if (amountOwedByFriend > 0) {
      amountChange = amountOwedByFriend; // positive means friend owes creator
    } else if (amountOwedByCreator > 0) {
      amountChange = -amountOwedByCreator; // negative means creator owes friend
    }
    await updateBalance(creatorId, friend._id, amountChange);

    res.json({ success: true, message: "Expense created successfully", expense });
  } catch (err) {
    console.error("Error creating expense:", err);
    res.status(500).json({ error: "Error creating expense" });
  }
});

// Record a payment against an existing balance
router.post("/pay", authMiddleware, async (req, res) => {
  const { friendEmail, amountPaid } = req.body;
  const creatorId = req.user.userId;
  if (!friendEmail || !amountPaid) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    // Find friend by email
    const friend = await User.findOne({ email: friendEmail });
    if (!friend) {
      return res.status(400).json({ error: "User does not exist." });
    }

    // Find the balance record between creator and friend
    let balanceRecord = await Balance.findOne({
      $or: [
        { user1: creatorId, user2: friend._id },
        { user1: friend._id, user2: creatorId }
      ]
    });
    if (!balanceRecord) {
      return res.status(400).json({ error: "No balance record found." });
    }

    balanceRecord.balance -= amountPaid;

    await balanceRecord.save();
    res.json({ success: true, message: "Payment recorded", balance: balanceRecord.balance });
  } catch (err) {
    console.error("Error recording payment:", err);
    res.status(500).json({ error: "Error recording payment" });
  }
});

// Get list of expenses and balances for the logged-in user
router.get("/list", authMiddleware, async (req, res) => {
  const userId = req.user.userId;
  console.log("User ID:", userId); // Debugging User ID

  try {
    // Fetch expenses where the user is either the creator or the friend
    console.log("Fetching expenses...");
    const expenses = await Expense.find({
      $or: [{ createdBy: userId }, { friend: userId }],
    }).populate("createdBy friend", "email name");

    console.log("Expenses fetched:", expenses.length); // Debugging Expenses Count

    // Fetch balance records for the user
    console.log("Fetching balances...");
    let balances = await Balance.find({
      $or: [{ user1: userId }, { user2: userId }],
    }).populate("user1 user2", "email name");

    console.log("Balances fetched:", balances.length); // Debugging Balances Count

    // For each balance record, compute a displayBalance that is relative to the logged-in user.
    balances = balances.map((record) => {
      let displayBalance = 0;
      console.log("Processing balance record:", record); // Debugging Individual Balance Record

      if (record.user1._id.toString() === userId) {
        displayBalance = record.balance;
        console.log("User is user1, balance:", displayBalance);
      } else if (record.user2._id.toString() === userId) {
        displayBalance = -record.balance;
        console.log("User is user2, balance:", displayBalance);
      }

      return { ...record.toObject(), displayBalance };
    });

    console.log("Final balances:", balances); // Debugging Final Processed Balances

    res.json({ expenses, balances });
  } catch (err) {
    console.error("Error fetching list:", err);
    res.status(500).json({ error: "Error fetching data" });
  }
});

module.exports = router;
