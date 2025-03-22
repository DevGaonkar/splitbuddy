import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/expense_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _balances = [];
  bool _isLoading = false;
  String _message = "";
  double _netBalance = 0;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('user_id');
    });
    if (_currentUserId != null) {
      _fetchData();
    } else {
      setState(() {
        _message = "Error: User not logged in.";
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _message = "";
    });

    final data = await ExpenseService.getExpensesAndBalances();
    if (data != null && _currentUserId != null) {
      List<dynamic> balances = data['balances'] ?? [];
      double net = 0;
      for (var record in balances) {
        double balanceValue = (record["balance"] as num).toDouble();
        double displayedBalance = 0;
        if (record['user1']["_id"] == _currentUserId) {
          displayedBalance = balanceValue;
        } else if (record['user2']["_id"] == _currentUserId) {
          displayedBalance = -balanceValue;
        }
        net += displayedBalance;
      }
      setState(() {
        _balances = balances;
        _netBalance = net;
      });
    } else {
      setState(() {
        _message = "Failed to load data";
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    Navigator.pushReplacementNamed(context, '/sign_in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SplitBuddy",
          style: TextStyle(
            color: Color(0xFFF4E1C1),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0A192F),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFFF4E1C1)),
            onPressed: _logout,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF4E1C1),
        ),
        child: RefreshIndicator(
          onRefresh: _fetchData,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _message.isNotEmpty
                  ? Center(
                      child: Text(
                        _message,
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            _netBalance >= 0
                                ? "Overall, you are owed ₹$_netBalance"
                                : "Overall, you owe ₹${_netBalance.abs()}",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A192F),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 20),
                        ..._balances.map((record) {
                          String friendDisplay = "";
                          double displayedBalance = (record["balance"] as num).toDouble();
                          bool canProceed = false;

                          if (record['user1']["_id"] == _currentUserId) {
                            friendDisplay = record['user2']["name"] ?? record['user2']["email"];
                            canProceed = displayedBalance >= 0;
                          } else if (record['user2']["_id"] == _currentUserId) {
                            displayedBalance = -displayedBalance;
                            friendDisplay = record['user1']["name"] ?? record['user1']["email"];
                            canProceed = displayedBalance >= 0;
                          }

                          return InkWell(
                            onTap: canProceed
                                ? () {
                                    Navigator.pushNamed(context, '/record_payment', arguments: record);
                                  }
                                : null,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      friendDisplay,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A192F),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          displayedBalance >= 0 ? "Owes you" : "You owe",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF0A192F),
                                          ),
                                        ),
                                        Text(
                                          "₹${displayedBalance.abs()}",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: displayedBalance >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add_expense');
        },
        label: Text(
          "Add Expense",
          style: TextStyle(
            color: Color(0xFFF4E1C1),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(Icons.add, color: Color(0xFFF4E1C1)),
        backgroundColor: Color(0xFF0A192F),
      ),
    );
  }
}