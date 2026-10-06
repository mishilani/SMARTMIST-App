import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/pages/dashboard.dart';
import 'package:smartmist_app/pages/signin_pg.dart';
import 'package:smartmist_app/widgets/app_notifications.dart';
import 'package:smartmist_app/widgets/custom_scaffold.dart';
import 'package:smartmist_app/widgets/welcome_btn.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return CustomScaffold(
      showBackButton: false,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.07),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          width: width * 0.42,
                          height: width * 0.42,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'SMARTMIST\n',
                            style: GoogleFonts.poppins(
                              fontSize: width * 0.085,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.white,
                              height: 1.8,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Real-time heat monitoring and automated misting for a more comfortable commute.',
                            style: GoogleFonts.poppins(
                              fontSize: width * 0.035,
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
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.08,
                    vertical: height * 0.025,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Choose how you would like to continue',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.038,
                          color: const Color(0xFF07111F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: height * 0.025),
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
                      SizedBox(height: height * 0.018),
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
                      SizedBox(height: height * 0.025),
                      Text(
                        'SMARTMIST IT31',
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.03,
                          color: const Color(0xFF546E7A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
