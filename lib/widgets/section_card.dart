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
    final size = MediaQuery.of(context).size;

    final double iconBoxSize = size.width * 0.12;
    final double iconSize = size.width * 0.055;

    return GlassContainer(
      borderRadius: size.width * 0.075,

      color: color ?? Colors.white.withValues(alpha: 0.20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),

                  borderRadius: BorderRadius.circular(size.width * 0.045),
                ),

                child: Icon(icon, color: Colors.white, size: iconSize),
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
                        color: Colors.white,
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (subtitle != null)
                      Text(
                        subtitle!,

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: size.width * 0.025,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.018),

          child,
        ],
      ),
    );
  }
}
