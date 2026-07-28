import 'package:flutter/material.dart';
import 'package:smartmist_app/widgets/custom_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smartmist_app/pages/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/services/log_service.dart';
import 'package:smartmist_app/widgets/app_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInState();
}

class _SignInState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  Future<bool> checkEmailExists(String email) async {
    final ref = FirebaseDatabase.instance.ref("Users");

    final snapshot = await ref.get();

    if (snapshot.exists) {
      final users = snapshot.value as Map;

      for (var user in users.values) {
        if (user["email"].toString().toLowerCase() == email.toLowerCase()) {
          return true;
        }
      }
    }

    return false;
  }

  Future<void> signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    bool emailExists = await checkEmailExists(email);

    if (!emailExists) {
      setState(() {
        _emailError = "Email not registered";
        _passwordError = null;
      });

      return;
    }

    try {
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = credential.user;

      if (user != null) {
        final userRef = FirebaseDatabase.instance.ref("Users").child(user.uid);

        final snapshot = await userRef.get();

        if (!snapshot.exists) {
          await userRef.set({
            "userID": user.uid,
            "email": user.email,
            "name": "",
            "role": "personnel",
            "accessLevel": "control",
            "createdAt": DateTime.now().millisecondsSinceEpoch,
          });
        } else {
          await userRef.update({"email": user.email});
        }
      }
      print("Logged in UID: ${user!.uid}");

      await LogService.addLog(
        action: "Login",
        category: "Authentication",
        description: "Personnel logged into the system",
      );

      setState(() {
        _emailError = null;
        _passwordError = null;
      });

      print(FirebaseAuth.instance.currentUser?.uid);

      showTokenDialog();
    } on FirebaseAuthException catch (e) {
      print("Firebase Error Code: ${e.code}");

      setState(() {
        _passwordError = null;
        _emailError = null;

        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _passwordError = "Incorrect password";
        }
      });
    }
  }

  void showTokenDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Authorization Token"),

          content: TextField(
            controller: _tokenController,
            decoration: const InputDecoration(hintText: "Enter token"),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back"),
            ),

            ElevatedButton(
              onPressed: () {
                verifyToken();
              },
              child: const Text("Vefiry"),
            ),
          ],
        );
      },
    );
  }

  Future<void> verifyToken() async {
    try {
      final ref = FirebaseDatabase.instance.ref(
        "Authentication/personnelAccessToken",
      );

      final snapshot = await ref.get();
      print(snapshot.exists);
      print(snapshot.value);
      print("FIrebase value: ${snapshot.value}");

      final storedToken = snapshot.value.toString();

      if (_tokenController.text.trim() == storedToken) {
        Navigator.pop(context);

        AppNotification.show(
          context,
          "Token Verified",
          color: Colors.green,
          icon: CupertinoIcons.checkmark_circle_fill,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Dashboard(isAdmin: true),
          ),
        );
      } else {
        AppNotification.show(
          context,
          "Token verification error",
          icon: CupertinoIcons.exclamationmark_triangle_fill,
        );
      }
    } catch (e) {
      AppNotification.show(
        context,
        "Token verification error",
        icon: CupertinoIcons.exclamationmark_triangle_fill,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(30),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'SMARTMIST',
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 25),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: 350,
                        constraints: const BoxConstraints(maxWidth: 350),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),

                        child: Form(
                          key: _formSignInKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    'Personnel Login',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 40),

                                TextFormField(
                                  controller: _emailController,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    } else if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    errorText: _emailError,
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    labelText: 'Email',
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                    floatingLabelStyle: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                    hintText: 'Enter your email',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                TextFormField(
                                  controller: _passwordController,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                  ),
                                  cursorColor: Colors.white,
                                  obscureText: _obscurePassword,
                                  obscuringCharacter: '*',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    errorText: _passwordError,
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    labelText: 'Password',
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                    floatingLabelStyle: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                    hintText: 'Enter your password',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: const Color.fromARGB(
                                          255,
                                          168,
                                          163,
                                          163,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: const Color(
                                        0xFF4FC3F7,
                                      ).withValues(alpha: 0.7),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _emailError = null;
                                        _passwordError = null;
                                      });
                                      if (_formSignInKey.currentState!
                                          .validate()) {
                                        signIn();
                                      }
                                    },
                                    child: Text(
                                      'Sign In',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
