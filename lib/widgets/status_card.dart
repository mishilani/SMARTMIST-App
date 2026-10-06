import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_container.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color? iconColor;

  const StatusCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double iconSize = size.width * 0.075;
    final double iconPadding = size.width * 0.025;

    return GlassContainer(
      color: color.withValues(alpha: 0.45),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),

            decoration: BoxDecoration(
              color: Colors.transparent,

              borderRadius: BorderRadius.circular(size.width * 0.04),
            ),

            child: Icon(icon, color: iconColor ?? Colors.white, size: iconSize),
          ),

          SizedBox(width: size.width * 0.03),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: size.width * 0.028,
                  ),
                ),

                SizedBox(height: size.height * 0.003),

                Text(
                  value,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  label,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: size.width * 0.023,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: size.width * 0.08,
            height: size.height * 0.02,

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.20),

              borderRadius: BorderRadius.circular(size.width * 0.05),
            ),
          ),
        ],
      ),
    );
  }
}
