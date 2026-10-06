import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HourlyWeatherCard extends StatelessWidget {
  final String time;
  final String temp;
  final Widget icon;

  const HourlyWeatherCard({
    super.key,
    required this.time,
    required this.temp,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double cardWidth = size.width * 0.20;
    final double iconSize = size.width * 0.14;

    return Container(
      width: cardWidth,

      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.008,
        horizontal: size.width * 0.015,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),

        borderRadius: BorderRadius.circular(size.width * 0.055),

        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: size.width * 0.002,
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

        children: [
          Text(
            time,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: size.width * 0.025,
            ),
          ),

          SizedBox(width: iconSize, height: iconSize, child: icon),

          Text(
            temp,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: size.width * 0.038,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
