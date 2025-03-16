import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _otpSent = false;
  String _message = "";
  bool _isLoading = false;

  void _sendOtp() async {
    setState(() {
      _isLoading = true;
    });
    String? response = await _authService.sendOtp(_emailController.text);
    setState(() {
      _message = response ?? "";
      _otpSent = true;
      _isLoading = false;
    });
  }

  void _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _authService.verifyOtp(_emailController.text, _otpController.text);
    print("OTP Verification Result: $result");

    setState(() {
      _isLoading = false;
    });

    if (result["success"] == true && result["token"] != null && result["user_id"] != null) {
      String token = result["token"];
      String userId = result["user_id"];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_id', userId);

      Navigator.pushReplacementNamed(context, "/home");
    } else {
      setState(() {
        _message = result["error"] ?? "OTP verification failed.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF4E1C1),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Sign In with OTP",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.email, color: Color(0xFF0A192F)),
                      ),
                      style: TextStyle(color: Color(0xFF0A192F)),
                    ),
                    SizedBox(height: 15),
                    if (_otpSent)
                      TextField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: "Enter OTP",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.lock, color: Color(0xFF0A192F)),
                        ),
                        style: TextStyle(color: Color(0xFF0A192F)),
                      ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _otpSent ? _verifyOtp : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0A192F),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _otpSent ? "Verify OTP" : "Send OTP",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF4E1C1)),
                            ),
                          ),
                    SizedBox(height: 20),
                    Text(_message, style: TextStyle(color: Colors.red, fontSize: 16)),
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
