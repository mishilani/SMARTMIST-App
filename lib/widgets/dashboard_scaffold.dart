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
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81D4FA), Color(0xFF0288D1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 35, 25, 0),
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

                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF263238),
                          size: 20,
                        ),
                      ),

                    if (showBackButton) const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF263238),
                        ),
                      ),
                    ),
                  ],
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 6),

                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF455A64),
                    ),
                  ),
                ],

                const SizedBox(height: 0),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
