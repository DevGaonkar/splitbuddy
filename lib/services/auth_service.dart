import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "http://10.0.2.2:5000";

  Future<String?> sendOtp(String email) async {
    final url = Uri.parse("$baseUrl/auth/send-otp");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    if (response.statusCode == 200) {
      return "OTP sent successfully";
    } else {
      final data = jsonDecode(response.body);
      return data["error"] ?? "Error sending OTP";
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final url = Uri.parse("$baseUrl/auth/verify-otp");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "success": true,
        "token": data["token"],
        "user_id": data["user_id"]
      };
    } else {
      final data = jsonDecode(response.body);
      return {
        "success": false,
        "error": data["error"] ?? "Error verifying OTP"
      };
    }
  }

  Future<String?> getCurrentUserEmail(String token) async {
    final url = Uri.parse("$baseUrl/auth/me");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["email"];
    } else {
      return null;
    }
  }
}
