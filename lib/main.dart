import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/record_payment_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(
    fileName: ".env",
  ); // Make sure you have a .env file at the project root
  runApp(SplitBuddyApp());
}

class SplitBuddyApp extends StatelessWidget { 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SplitBuddy',
      initialRoute: '/sign_in',
      routes: {
        '/sign_in': (context) => SignInScreen(),
        '/home': (context) => HomeScreen(),
        '/add_expense': (context) => AddExpenseScreen(),
        '/record_payment': (context) => RecordPaymentScreen(),
      },
    );
  }
}
