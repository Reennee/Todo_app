// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it_done/features/navigation/screens/home_screen.dart';
import 'package:get_it_done/providers/provider.dart';
import 'package:get_it_done/utils/app_settings.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool hasError = false;
  String error = '';

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthStateProvider>(context);
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Future<void> handleGoogleSignIn() async {
      try {
        setState(() {
          isLoading = true;
          hasError = false;
        });

        final GoogleSignInAccount? googleSignInAccount =
            await _googleSignIn.signIn();

        if (googleSignInAccount != null) {
          final GoogleSignInAuthentication googleSignInAuthentication =
              await googleSignInAccount.authentication;

          final OAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          await FirebaseAuth.instance.signInWithCredential(credential);

          authProvider.setAuthState(FirebaseAuth.instance.currentUser);

          handleAfterLogin(context);
        } else {
          setState(() {
            isLoading = false;
            hasError = true;
            error = 'Google sign-in cancelled.';
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
          hasError = true;
          error = e.toString();
        });
      }
    }

    Future<void> handleEmailAndPasswordSignIn() async {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        setState(() {
          error = 'Email and Password Required!';
          hasError = true;
        });
      }

      try {
        setState(() {
          isLoading = true;
          hasError = false; // Reset error state
        });

        // Proceed with sign-in
        await authProvider.signInWithEmailAndPassword(email, password);
        if (authProvider.currentUser != null) {
          handleAfterLogin(context);
        } else {
          setState(() {
            isLoading = false;
            hasError = true;
            error = 'wrong password or email';
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
          hasError = true;
          switch (e.code) {
            case 'user-not-found':
              error = 'User not found. Please check your email.';
              break;
            case 'wrong-password':
              error = 'Incorrect password. Please try again.';
              break;
            case 'invalid-email':
              error = 'Invalid email. Please try again.';
              break;
            default:
              error = 'An unexpected error occurred. Please try again.';
              break;
          }
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          hasError = true;
          error = 'Error occurred during Google sign-in. Please try again.';
        });
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 50.0, vertical: AppSettings.screenHeight(context) * .3),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Text(
                "GET IT DONE!",
                style: TextStyle(fontSize: 26, color: AppSettings.secondaryColor),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('emailField'),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: AppSettings.secondaryColor.withOpacity(.1),
                    hintText: "Email",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.person_2_outlined)),
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 1.0),
              TextFormField(
                key: const Key('passwordField'),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: AppSettings.secondaryColor.withOpacity(.1),
                    hintText: "Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock_open_rounded)),
                controller: passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
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
                    height: 45,
                    width: AppSettings.screenWidth(context) * 0.8,
                    child: MaterialButton(
                      onPressed: handleEmailAndPasswordSignIn,
                      color: AppSettings.secondaryColor,
                      child: const Text("Sign in"),
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.gpp_good,
                          color: Colors.black,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Continue with Google",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
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

  void handleAfterLogin(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 200)).then(
      (_) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              const HomeScreen(title: "Get it Done"),
        ),
      ),
    );
  }
}
