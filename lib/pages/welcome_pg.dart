import 'package:flutter/material.dart';
import 'package:smartmist_app/pages/signin_pg.dart';
import 'package:smartmist_app/widgets/custom_scaffold.dart';
import 'package:smartmist_app/widgets/app_notifications.dart';
import 'package:smartmist_app/widgets/welcome_btn.dart';
import 'package:smartmist_app/pages/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showBackButton: false,
      child: Column(
        children: [
          Flexible(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'assets/images/logo.jpg',
                                width: 170,
                                height: 170,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'SMARTMIST\n',
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.white,
                              height: 2,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Real-time heat monitoring and automated misting for a more comfortable commute.',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xB3FFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 4,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                child: Transform.translate(
                  offset: const Offset(0, -70),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Choose how you would like to continue',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color(0xFF07111F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: WelcomeBtn(
                          btnText: 'View Dashboard',
                          icon: CupertinoIcons.rectangle_grid_2x2_fill,
                          onTap: () {
                            AppNotification.show(
                              context,
                              "Welcome to SMARTMIST Dashboard",
                              icon: CupertinoIcons.checkmark_circle,
                            );

                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const Dashboard(isAdmin: false),
                                  ),
                                );
                              },
                            );
                          },
                          color: const Color(0xFFF0F4F8),
                          textColor: const Color(0xFF07111F),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: WelcomeBtn(
                          btnText: 'Personnel Login',
                          icon: CupertinoIcons
                              .person_crop_circle_fill_badge_checkmark,
                          onTap: () {
                            AppNotification.show(
                              context,
                              "Please sign in to continue",
                              icon: CupertinoIcons.person_crop_circle,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          },
                          color: Colors.white,
                          textColor: const Color(0xFF07111F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'SMARTMIST IT31',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Color(0xFF546E7A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
