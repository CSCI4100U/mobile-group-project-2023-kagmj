// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Login Function - Uses Firebase to check user credentials
  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Use Firebase Authentication to sign in
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // User sign-in successful, now check if profile setup is complete
        DocumentSnapshot userProfile = await FirebaseFirestore.instance
            .collection('profiles')
            .doc(userCredential.user!.uid)
            .get();

        // Save login state locally
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', userCredential.user!.uid);

        // Check if the userProfile exists and has data
        if (userProfile.exists && userProfile.data() != null) {
          Map<String, dynamic> userData = userProfile.data()
              as Map<String, dynamic>;
          bool profileSetupComplete = userData['profileSetupComplete']
                  as bool? ??
              false;

          // If the 'profileSetupComplete' field is true, navigate to HomeScreen, else to ProfileSetup
          if (profileSetupComplete) {
            Navigator.pushReplacementNamed(context, '/home');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Welcome Back!')),
            );
          } else {
            Navigator.pushReplacementNamed(context, '/profileSetup');
          }
        } else {
          // Handle the case where the userProfile does not exist or has no data
          Navigator.pushReplacementNamed(context, '/profileSetup');
        }
      } on FirebaseAuthException catch (e) {
        // Handle Firebase sign-in errors
        var errorMessage = 'Failed to sign in. Please try again.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        } else if (e.code == 'user-disabled') {
          errorMessage = 'User has been disabled.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again later.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0FA7E0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // Centering the content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 48),
              // App Logo Centered on the Screen
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Image.asset(
                'assets/logo.png',
                height: 120.0,
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input Fields for Email and Password
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // Toggle password viewing
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _login(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFFFA726),
                      ),
                      child: const Text('Login'),
                    ),
                    // Navigate to registration screen
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const RegistrationScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Don't have an account? Register here",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
