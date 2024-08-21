import 'package:appscrip_task_management_app/provider/auth_provider.dart';
import 'package:appscrip_task_management_app/screens/login_screen.dart';
import 'package:appscrip_task_management_app/screens/task_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _checkloginstatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isLoggedIn = await authProvider.checkLoginStatus();
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TaskManagementPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginUser()),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    var d = const Duration(seconds: 4);
    Future.delayed(d, () {
      _checkloginstatus();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'AppScripp',
          style: GoogleFonts.aBeeZee(fontSize: 30, color: Colors.black),
        ),
      ),
    );
  }
}
