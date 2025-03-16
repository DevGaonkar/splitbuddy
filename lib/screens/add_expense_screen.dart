import 'package:flutter/material.dart';
import '../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _friendEmailController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedOption = "you_paid_split"; // Default option
  bool _isLoading = false;
  String _message = "";

  List<DropdownMenuItem<String>> _options = [
    DropdownMenuItem(child: Text("You Paid, Split Equally"), value: "you_paid_split"),
    DropdownMenuItem(child: Text("You Are Owed Full Amount"), value: "you_owed_full"),
    DropdownMenuItem(child: Text("User Paid, Split Equally"), value: "user_paid_split"),
    DropdownMenuItem(child: Text("User Is Owed Full Amount"), value: "user_owed_full"),
  ];

  void _submitExpense() async {
    setState(() {
      _isLoading = true;
      _message = "";
    });

    var result = await ExpenseService.addExpense(
      friendEmail: _friendEmailController.text,
      totalAmount: double.tryParse(_amountController.text) ?? 0,
      option: _selectedOption,
      description: _descriptionController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result["success"]) {
      Navigator.pop(context);
    } else {
      setState(() {
        _message = result["error"] ?? "Error adding expense";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4E1C1), // Ensure full background color
      appBar: AppBar(
        title: Text("Add Expense", style: TextStyle(color: Color(0xFFF4E1C1))),
        backgroundColor: Color(0xFF0A192F),
        iconTheme: IconThemeData(color: Color(0xFFF4E1C1)),
      ),
      body: Container(
        width: double.infinity, // Ensures full width
        height: double.infinity, // Ensures full height
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centers everything
              children: [
                _buildStyledTextField(_friendEmailController, "Friend's Email"),
                SizedBox(height: 12),
                _buildStyledTextField(_amountController, "Total Amount", isNumeric: true),
                SizedBox(height: 12),
                _buildStyledTextField(_descriptionController, "Description (optional)"),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: "Select Expense Option",
                      labelStyle: TextStyle(color: Color(0xFF0A192F), fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    ),
                    dropdownColor: Colors.white,
                    value: _selectedOption,
                    items: _options,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value as String;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(color: Color(0xFF0A192F))
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitExpense,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0A192F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            "Add Expense",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF4E1C1)),
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                if (_message.isNotEmpty)
                  Text(
                    _message,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF0A192F), fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: isNumeric ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    );
  }
}
