import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test2/services/auth/login_or_register.dart';
import 'package:flutter_test2/pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // User is signed in
            return HomePage(); // Replace with your home page widget
          } else {
            // User is not signed in
            return LoginOrRegister(); // Replace with your login or register widget
          }
        },
      ),
    );
  }
}