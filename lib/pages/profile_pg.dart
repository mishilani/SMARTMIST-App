import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smartmist_app/services/notification_service.dart';
import 'package:smartmist_app/widgets/app_notifications.dart';
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
    final size = MediaQuery.of(context).size;
    final width = size.width;

    nameController.text = userData["name"] ?? "";
    emailController.text = userData["email"] ?? "";
    currentPassController.clear();
    newPassController.clear();
    confirmPassController.clear();
    changePassword = false;

    bool showCurrentPass = false;
    bool showNewPass = false;
    bool showConfirmPass = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Container(
                padding: EdgeInsets.all(width * 0.06),
                decoration: BoxDecoration(
                  color: const Color(0xFF0288D1).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(width * 0.08),
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
                          fontSize: width * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: width * 0.06),

                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: inputDecoration("Name"),
                      ),

                      SizedBox(height: width * 0.035),

                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: inputDecoration("Email"),
                      ),

                      SizedBox(height: width * 0.02),

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
                        SizedBox(height: width * 0.02),

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

                        SizedBox(height: width * 0.025),

                        TextField(
                          controller: newPassController,
                          obscureText: !showNewPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: inputDecoration("New Password"),
                        ),
                      ],

                      SizedBox(height: width * 0.025),

                      if (changePassword)
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

                      SizedBox(height: width * 0.06),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Expanded(
                            child: SizedBox(
                              height: width * 0.12,

                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white24,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      width * 0.05,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },

                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: width * 0.04),

                          Expanded(
                            child: SizedBox(
                              height: width * 0.12,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4FC3F7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      width * 0.05,
                                    ),
                                  ),
                                ),

                                onPressed: () {
                                  saveChanges(userRef);
                                },
                                child: Text(
                                  "Save",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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

      await NotificationService.show(
        title: "SMARTMIST",
        body: "Your profile has been updated successfully.",
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
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: width * 0.035),
      padding: EdgeInsets.all(width * 0.045),
      decoration: BoxDecoration(
        color: const Color(0xFF0288D1).withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(width * 0.06),

        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: width * 0.075),

          SizedBox(width: width * 0.04),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: GoogleFonts.poppins(
                    color: Colors.white70,

                    fontSize: width * 0.03,
                  ),
                ),

                Text(
                  value,

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,

                    fontSize: width * 0.035,
                  ),
                ),
              ],
            ),
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
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width * 0.36,

      height: width * 0.11,

      child: ElevatedButton.icon(
        icon: Icon(icon, size: width * 0.05),

        label: Text(
          text,

          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,

            fontSize: width * 0.03,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: danger ? Colors.red : const Color(0xFF4FC3F7),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.05),
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
    final size = MediaQuery.of(context).size;

    final width = size.width;

    final height = size.height;

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

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),

              child: Column(
                children: [
                  SizedBox(height: height * 0.03),

                  CircleAvatar(
                    radius: width * 0.14,

                    backgroundColor: Colors.white24,

                    child: Icon(
                      CupertinoIcons.person_fill,

                      size: width * 0.14,

                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: height * 0.025),

                  Text(
                    "Personnel ${userData["name"] ?? ""}",

                    textAlign: TextAlign.center,

                    style: GoogleFonts.poppins(
                      color: Colors.white,

                      fontSize: width * 0.065,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: height * 0.035),

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

                  SizedBox(height: height * 0.08),

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

                      SizedBox(width: width * 0.04),

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

                          await NotificationService.show(
                            title: "SMARTMIST",
                            body: "You have successfully logged out.",
                          );

                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.03),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
