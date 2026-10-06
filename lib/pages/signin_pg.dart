import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smartmist_app/pages/dashboard.dart';
import 'package:smartmist_app/services/log_service.dart';
import 'package:smartmist_app/widgets/app_notifications.dart';
import 'package:smartmist_app/widgets/custom_scaffold.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInState();
}

class _SignInState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSigningIn = false;
  bool _isVerifyingToken = false;

  String? _emailError;
  String? _passwordError;

  Future<void> signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isSigningIn = true;
    });

    try {
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

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

      unawaited(
        LogService.addLog(
          action: "Login",
          category: "Authentication",
          description: "Personnel logged into the system",
        ).catchError((e, stack) {
          print("DEBUG log write failed: $e");
        }),
      );

      setState(() {
        _emailError = null;
        _passwordError = null;
      });

      showTokenDialog();
    } on FirebaseAuthException catch (e) {
      print("DEBUG auth error: ${e.code} - ${e.message}");

      setState(() {
        _emailError = null;
        _passwordError = null;

        if (e.code == "wrong-password" || e.code == "invalid-credential") {
          _passwordError = "Incorrect password";
        } else if (e.code == "user-not-found") {
          _emailError = "Email not registered";
        } else if (e.code == "invalid-email") {
          _emailError = "Please enter a valid email";
        } else if (e.code == "user-disabled") {
          _emailError = "This account has been disabled";
        }
      });

      final handledInline = _emailError != null || _passwordError != null;

      if (!handledInline && mounted) {
        AppNotification.show(
          context,
          "Sign in failed: ${e.message ?? e.code}",
          icon: CupertinoIcons.exclamationmark_triangle_fill,
        );
      }
    } catch (e, stack) {
      print("DEBUG unexpected signIn error: $e");
      print(stack);

      if (mounted) {
        AppNotification.show(
          context,
          "Something went wrong: $e",
          icon: CupertinoIcons.exclamationmark_triangle_fill,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  void showTokenDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Authorization Token"),
              content: TextField(
                controller: _tokenController,
                decoration: const InputDecoration(hintText: "Enter token"),
              ),
              actions: [
                TextButton(
                  onPressed: _isVerifyingToken
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: _isVerifyingToken
                      ? null
                      : () async {
                          setDialogState(() {
                            _isVerifyingToken = true;
                          });
                          await verifyToken();
                          setDialogState(() {
                            _isVerifyingToken = false;
                          });
                        },
                  child: _isVerifyingToken
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Verify"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> verifyToken() async {
    try {
      final ref = FirebaseDatabase.instance.ref("Authentication/accessToken");
      final snapshot = await ref.get();
      final storedToken = snapshot.value.toString();

      if (_tokenController.text.trim() == storedToken) {
        if (mounted) Navigator.pop(context);

        if (mounted) {
          AppNotification.show(
            context,
            "Token Verified",
            color: Colors.green,
            icon: CupertinoIcons.checkmark_circle_fill,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Dashboard(isAdmin: true)),
          );
        }
      } else {
        if (mounted) {
          AppNotification.show(
            context,
            "Token verification error",
            icon: CupertinoIcons.exclamationmark_triangle_fill,
          );
        }
      }
    } catch (e) {
      print("DEBUG verifyToken error: $e");
      if (mounted) {
        AppNotification.show(
          context,
          "Token verification error",
          icon: CupertinoIcons.exclamationmark_triangle_fill,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;

    return CustomScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
            child: Column(
              children: [
                SizedBox(height: height * 0.05),

                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: width * 0.30,
                    height: width * 0.30,
                    fit: BoxFit.cover,
                  ),
                ),

                SizedBox(height: height * 0.015),

                Text(
                  "SMARTMIST",
                  style: GoogleFonts.poppins(
                    fontSize: width * 0.07,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: height * 0.03),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: width * 0.88,
                      padding: EdgeInsets.all(width * 0.055),
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
                        child: Column(
                          children: [
                            Text(
                              "Personnel Login",
                              style: GoogleFonts.poppins(
                                fontSize: width * 0.075,
                                fontWeight: FontWeight.w900,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),

                            SizedBox(height: height * 0.04),

                            TextFormField(
                              controller: _emailController,
                              enabled: !_isSigningIn,
                              style: GoogleFonts.poppins(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your email";
                                }

                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return "Please enter a valid email";
                                }

                                return null;
                              },
                              decoration: inputDecoration("Email", _emailError),
                            ),

                            SizedBox(height: height * 0.02),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              obscuringCharacter: "*",
                              enabled: !_isSigningIn,
                              style: GoogleFonts.poppins(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your password";
                                }

                                return null;
                              },
                              decoration:
                                  inputDecoration(
                                    "Password",
                                    _passwordError,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                            ),

                            SizedBox(height: height * 0.035),

                            SizedBox(
                              width: double.infinity,
                              height: height * 0.055,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFF4FC3F7,
                                  ).withValues(alpha: 0.75),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: _isSigningIn
                                    ? null
                                    : () {
                                        setState(() {
                                          _emailError = null;
                                          _passwordError = null;
                                        });

                                        final isValid = _formSignInKey
                                            .currentState!
                                            .validate();

                                        if (isValid) {
                                          signIn();
                                        }
                                      },
                                child: _isSigningIn
                                    ? SizedBox(
                                        width: width * 0.05,
                                        height: width * 0.05,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Sign In",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.04,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(height: height * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String label, String? error) {
    return InputDecoration(
      errorText: error,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.15),

      labelText: label,

      labelStyle: GoogleFonts.poppins(
        color: Colors.white.withValues(alpha: 0.8),
      ),

      floatingLabelStyle: const TextStyle(color: Colors.white),

      hintText: "Enter your $label",

      hintStyle: GoogleFonts.poppins(
        color: Colors.white.withValues(alpha: 0.75),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.9),
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();

    super.dispose();
  }
}
