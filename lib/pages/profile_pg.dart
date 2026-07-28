import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/widgets/app_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';

class ProfilePage extends StatefulWidget {
  final bool isAdmin;

  const ProfilePage({super.key, required this.isAdmin});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  bool changePassword = false;

  void showEditProfileDialog(
    BuildContext context,
    Map<dynamic, dynamic> userData,
    DatabaseReference userRef,
  ) {
    nameController.text = userData["name"] ?? "";
    emailController.text = userData["email"] ?? "";
    nameController.clear();
    currentPassController.clear();
    newPassController.clear();
    confirmPassController.clear();

    changePassword = false;
    bool showCurrentPass = false;
    bool showNewPass = false;
    bool showConfirmPass = false;

    showDialog(
      context: context,
      barrierDismissible: true,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),

              child: Container(
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: const Color(0xFF0288D1).withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Text(
                        "Edit Profile",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: inputDecoration("Name"),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: inputDecoration("Email"),
                      ),

                      const SizedBox(height: 10),

                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Change Password",
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        value: changePassword,
                        activeColor: Colors.white,
                        checkColor: const Color(0xFF0288D1),
                        onChanged: (value) {
                          setDialogState(() {
                            changePassword = value ?? false;
                          });
                        },
                      ),

                      if (changePassword) ...[
                        const SizedBox(height: 10),

                        TextField(
                          controller: currentPassController,
                          obscureText: !showCurrentPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: inputDecoration("Current Password")
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    showCurrentPass
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,

                                    color: Colors.white70,
                                  ),

                                  onPressed: () {
                                    setDialogState(() {
                                      showCurrentPass = !showCurrentPass;
                                    });
                                  },
                                ),
                              ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: newPassController,
                          obscureText: !showNewPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: inputDecoration("New Password").copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                showNewPass
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,

                                color: Colors.white70,
                              ),

                              onPressed: () {
                                setDialogState(() {
                                  showNewPass = !showNewPass;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: confirmPassController,
                          obscureText: !showConfirmPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: inputDecoration("Confirm Password")
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    showConfirmPass
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,

                                    color: Colors.white70,
                                  ),

                                  onPressed: () {
                                    setDialogState(() {
                                      showConfirmPass = !showConfirmPass;
                                    });
                                  },
                                ),
                              ),
                        ),
                      ],

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 45,

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white24,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),

                              onPressed: () {
                                Navigator.pop(context);
                              },

                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(width: 15),

                          SizedBox(
                            width: 120,
                            height: 45,

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4FC3F7),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),

                              onPressed: () {
                                saveChanges(userRef);
                              },

                              child: const Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
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
          },
        );
      },
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white, width: 1.2),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }

  Future<void> saveChanges(DatabaseReference userRef) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      if (changePassword) {
        if (newPassController.text != confirmPassController.text) {
          AppNotification.show(
            context,
            "Password does not match",
            color: Colors.red,
            icon: Icons.error,
          );
          return;
        }

        if (newPassController.text.length < 6) {
          AppNotification.show(
            context,
            "Password must be at least 6 characters",
            color: Colors.red,
            icon: Icons.warning,
          );
          return;
        }

        await user.updatePassword(newPassController.text.trim());
      }

      await userRef.update({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
      });

      if (emailController.text.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(emailController.text.trim());
      }

      Navigator.pop(context);

      AppNotification.show(
        context,
        "Profile Updated Successfully",
        icon: Icons.check_circle,
      );
    } catch (e) {
      AppNotification.show(
        context,
        "Unable to update profile",
        color: Colors.red,
        icon: Icons.error,
      );
    }
  }

  Widget profileInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0288D1).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(color: Colors.white70)),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget actionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,

    bool danger = false,
  }) {
    return SizedBox(
      width: 160,
      height: 45,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(
          text,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: danger ? Colors.red : const Color(0xFF4FC3F7),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        onPressed: onTap,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    currentPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text("No logged in user", style: TextStyle(color: Colors.white)),
      );
    }

    final DatabaseReference userRef = FirebaseDatabase.instance
        .ref("Users")
        .child(currentUser.uid);

    return DashboardScaffold(
      title: "Profile",
      child: StreamBuilder(
        stream: userRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          return Column(
            children: [
              const SizedBox(height: 25),

              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white24,
                child: Icon(
                  CupertinoIcons.person_fill,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Personnel ${userData["name"] ?? ""}",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              profileInfoCard(
                icon: CupertinoIcons.mail,
                title: "Email",
                value: userData["email"] ?? currentUser.email ?? "",
              ),

              profileInfoCard(
                icon: CupertinoIcons.lock_shield,
                title: "Access Level",
                value: userData["accessLevel"] ?? "control",
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  actionButton(
                    text: "Edit",
                    icon: CupertinoIcons.pencil,
                    onTap: () {
                      showEditProfileDialog(context, userData, userRef);
                    },
                  ),

                  const SizedBox(width: 15),

                  actionButton(
                    text: "Logout",
                    icon: CupertinoIcons.arrow_right_square,
                    danger: true,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();

                      AppNotification.show(
                        context,
                        "Successfully Logged Out",
                        icon: CupertinoIcons.checkmark_circle,
                      );

                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),
            ],
          );
        },
      ),
    );
  }
}
