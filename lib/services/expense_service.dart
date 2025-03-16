import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "http://10.0.2.2:5000";

  static Future<Map<String, dynamic>?> getExpensesAndBalances() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null) return null;
    final url = Uri.parse("$baseUrl/expense/list");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>> addExpense({
    required String friendEmail,
    required double totalAmount,
    required String option,
    String? description,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    final url = Uri.parse("$baseUrl/expense/create");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "friendEmail": friendEmail,
        "totalAmount": totalAmount,
        "option": option,
        "description": description,
      }),
    );
    if (response.statusCode == 200) {
      return {"success": true};
    } else {
      return {"success": false, "error": jsonDecode(response.body)["error"]};
    }
  }

  static Future<Map<String, dynamic>> recordPayment({
    required String friendEmail,
    required double amountPaid,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    final url = Uri.parse("$baseUrl/expense/pay");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "friendEmail": friendEmail,
        "amountPaid": amountPaid,
      }),
    );
    if (response.statusCode == 200) {
      return {"success": true, "balance": jsonDecode(response.body)["balance"]};
    } else {
      return {"success": false, "error": jsonDecode(response.body)["error"]};
    }
  }
}
