import 'package:flutter/material.dart';
import 'package:flutter_test2/services/auth/auth_service.dart';
import 'package:flutter_test2/components/my_button.dart';
import 'package:flutter_test2/components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  final void Function()? onTap;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  RegisterPage({super.key, this.onTap});

  void register(BuildContext context) {
    final auth = AuthService();

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      // Show error message
      print("Please fill in all fields");
      return;
    }
    if (passwordController.text == confirmPasswordController.text) {
      // Show error message
      try {
        auth.registerWithEmailAndPassword(emailController.text, passwordController.text);
      } catch (e) {
        showDialog(context: context, builder: (context) => (
          AlertDialog(
            title: Text(e.toString()),
            )
          ),
        );
      }
    } else {
      // Show error message
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text("Passwords do not match"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 50),

              Text(
                'Create a new account',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

              const SizedBox(height: 10),

              MyTextfield(
                hintText: 'Email',
                obscureText: false,
                controller: emailController,
              ),

              const SizedBox(height: 10),

              MyTextfield(
                hintText: 'Password',
                obscureText: true,
                controller: passwordController,
              ),

              const SizedBox(height: 10),

              MyTextfield(
                hintText: 'Confirm Password',
                obscureText: true,
                controller: confirmPasswordController,
              ),

              const SizedBox(height: 25),

              MyButton(
                text: "Register",
                onTap: () => register(context),
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Login here',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
