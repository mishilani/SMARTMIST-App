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
    return GlassContainer(
      color: color.withValues(alpha: 0.45),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),

            child: Icon(icon, color: iconColor ?? Colors.white, size: 30),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}
