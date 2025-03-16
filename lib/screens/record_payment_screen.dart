import 'package:flutter/material.dart';
import '../services/expense_service.dart';

class RecordPaymentScreen extends StatefulWidget {
  @override
  _RecordPaymentScreenState createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _paymentController = TextEditingController();
  bool _isLoading = false;
  String _message = "";
  dynamic balanceRecord;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    balanceRecord = ModalRoute.of(context)?.settings.arguments;
  }

  void _recordPayment() async {
    setState(() {
      _isLoading = true;
      _message = "";
    });

    double amountPaid = double.tryParse(_paymentController.text) ?? 0;
    if (amountPaid <= 0) {
      setState(() {
        _isLoading = false;
        _message = "Enter a valid amount";
      });
      return;
    }

    var result = await ExpenseService.recordPayment(
      friendEmail: balanceRecord['user1']['email'] ?? balanceRecord['user2']['email'],
      amountPaid: amountPaid,
    );

    setState(() {
      _isLoading = false;
    });

    if (result["success"]) {
      Navigator.pop(context);
    } else {
      setState(() {
        _message = result["error"] ?? "Error recording payment";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayText = "";
    if (balanceRecord != null) {
      if (balanceRecord['balance'] > 0) {
        displayText =
            "${balanceRecord['user2']['name'] ?? balanceRecord['user2']['email']} owes you ₹${balanceRecord['balance']}";
      } else {
        displayText =
            "You owe ${balanceRecord['user1']['name'] ?? balanceRecord['user1']['email']} ₹${(balanceRecord['balance']).abs()}";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Record Payment",
          style: TextStyle(
            color: Color(0xFFF4E1C1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0A192F),
        iconTheme: IconThemeData(color: Color(0xFFF4E1C1)),
      ),
      body: Container(
        color: Color(0xFFF4E1C1),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Record Payment",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A192F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0A192F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _paymentController,
                      decoration: InputDecoration(
                        labelText: "Enter Amount Paid",
                        labelStyle: TextStyle(color: Color(0xFF0A192F)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0A192F)),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _recordPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0A192F),
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Done",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF4E1C1),
                              ),
                            ),
                          ),
                    if (_message.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text(
                        _message,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
