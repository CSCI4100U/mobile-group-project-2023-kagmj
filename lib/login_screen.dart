import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Use Firebase Authentication to sign in
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // User sign-in successful, now check if profile setup is complete
        DocumentSnapshot userProfile = await FirebaseFirestore.instance.collection('profiles').doc(userCredential.user!.uid).get();

        // Check if the userProfile exists and has data
        if (userProfile.exists && userProfile.data() != null) {
          // Safely access the data without using the '!' operator
          Map<String, dynamic> userData = userProfile.data() as Map<String, dynamic>; // Cast the data to the correct type
          bool profileSetupComplete = userData['profileSetupComplete'] as bool? ?? false; // Cast to bool and provide a default value of false if the field doesn't exist

          // If the 'profileSetupComplete' field is true, navigate to HomeScreen, else to ProfileSetup
          if (profileSetupComplete) {
            Navigator.pushReplacementNamed(context, '/home');
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
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again later.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0FA7E0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center( // Centering the content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 48),
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Image.asset(
                'assets/logo.png',
                height: 120.0,
              ),
              SizedBox(height: 48), // Space between logo and form
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
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
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _login(context),
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFFFA726), // Background color
                        onPrimary: Colors.white, // Text color
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => RegistrationScreen()),
                        );
                      },
                      child: Text(
                        "Don't have an account? Register here",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.blue,
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
