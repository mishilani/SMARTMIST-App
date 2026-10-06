import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class WelcomeBtn extends StatelessWidget {
  const WelcomeBtn({
    super.key,
    required this.btnText,
    required this.icon,
    required this.onTap,
    required this.color,
    required this.textColor,
  });

  final String btnText;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double borderRadius = size.width * 0.05;
    final double iconSize = size.width * 0.055;
    final double fontSize = size.width * 0.035;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),

        onTap: onTap,

        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),

          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: size.width * 0.025,
              sigmaY: size.width * 0.025,
            ),

            child: Container(
              width: double.infinity,

              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.02,
                horizontal: size.width * 0.05,
              ),

              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),

                borderRadius: BorderRadius.circular(borderRadius),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),

                    blurRadius: size.width * 0.025,

                    offset: Offset(0, size.height * 0.005),
                  ),
                ],
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(icon, size: iconSize, color: textColor),

                  SizedBox(width: size.width * 0.025),

                  Flexible(
                    child: Text(
                      btnText,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
