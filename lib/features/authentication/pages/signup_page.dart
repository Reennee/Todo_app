import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it_done/features/navigation/screens/home_screen.dart';
import 'package:get_it_done/providers/provider.dart';
import 'package:get_it_done/utils/app_settings.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  bool isLoading = false;
  bool hasError = false;
  String error = '';

  Future<bool> checkUserExists(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  Future<void> handleSignUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      setState(() {
        hasError = true;
        error = 'Fill in all fields';
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final userExists = await checkUserExists(email);
      if (userExists) {
        setState(() {
          hasError = true;
          error = 'User already exists with this email.';
          isLoading = false;
        });
        return;
      }

      final authProvider =
          Provider.of<AuthStateProvider>(context, listen: false);
      await authProvider.signUp(email, password, username);
      final currentUser = authProvider.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance.collection("users").add({
          "name": username,
          "email": currentUser.email,
          "uid": currentUser.uid,
          "photoUrl": null,
        });
        authProvider.setAuthState(currentUser);
        setState(() {
          isLoading = false;
        });
        handleAfterSignUp(context);
      }
    } catch (e) {
      setState(() {
        hasError = true;
        error = 'An unexpected error occurred. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: AppSettings.screenHeight(context) * .3, horizontal: 50),
      child: SizedBox(
        height: AppSettings.screenHeight(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16.0),
              Text(
                "Sign Up",
                style:
                    TextStyle(fontSize: 20, color: AppSettings.secondaryColor),
              ),
              const SizedBox(height: 1.0),
              TextField(
                key: const ValueKey('usernameField'), // Add key here
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: AppSettings.secondaryColor.withOpacity(0.1),
                  hintText: 'Username',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                controller: usernameController,
              ),
              const SizedBox(height: 1.0),
              TextField(
                key: const ValueKey('emailField'), // Add key here
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: AppSettings.secondaryColor.withOpacity(0.1),
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                controller: emailController,
              ),
              const SizedBox(height: 1.0),
              TextField(
                key: const ValueKey('passwordField'), // Add key here
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: AppSettings.secondaryColor.withOpacity(0.1),
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              Visibility(
                visible: hasError,
                child: SizedBox(
                  height: 50,
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              Stack(
                children: [
                  Container(
                    color: Colors.orangeAccent,
                    width: AppSettings.screenWidth(context),
                    height: 45,
                    child: MaterialButton(
                      onPressed: handleSignUp,
                      color: AppSettings.secondaryColor,
                      child: const Text("Sign Up"),
                    ),
                  ),
                  if (isLoading)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppSettings.secondaryColor,
                      ),
                      height: 76,
                      width: AppSettings.screenWidth(context),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.orangeAccent,
                          strokeWidth: 5,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleAfterSignUp(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 200)).then(
      (_) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const HomeScreen(
            title: "Get It Done",
          ),
        ),
      ),
    );
  }
}
