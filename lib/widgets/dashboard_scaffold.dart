import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScaffold extends StatelessWidget {
  final String? subtitle;
  final String title;
  final Widget child;
  final bool showBackButton;

  const DashboardScaffold({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double horizontalPadding = size.width * 0.06;
    final double topPadding = size.height * 0.045;

    final double titleSize = size.width * 0.065;
    final double subtitleSize = size.width * 0.035;
    final double backIconSize = size.width * 0.05;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81D4FA), Color(0xFF0288D1)],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              topPadding,
              horizontalPadding,
              0,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    if (showBackButton)
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },

                        child: Icon(
                          Icons.arrow_back_ios,
                          color: const Color(0xFF263238),
                          size: backIconSize,
                        ),
                      ),

                    if (showBackButton) SizedBox(width: size.width * 0.02),

                    Expanded(
                      child: Text(
                        title,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.poppins(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF263238),
                        ),
                      ),
                    ),
                  ],
                ),

                if (subtitle != null) ...[
                  SizedBox(height: size.height * 0.008),

                  Text(
                    subtitle!,

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: GoogleFonts.poppins(
                      fontSize: subtitleSize,
                      color: const Color(0xFF455A64),
                    ),
                  ),
                ],

                SizedBox(height: size.height * 0.005),

                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
