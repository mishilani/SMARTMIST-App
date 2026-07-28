import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/widgets/glass_container.dart';

class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final Color? color;

  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 30,
      color: color ?? Colors.white.withValues(alpha: 0.20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Icon(icon, color: Colors.white, size: 24),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          child,
        ],
      ),
    );
  }
}
