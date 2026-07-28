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
    return Container(
      width: 85,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            time,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
          ),

          SizedBox(width: 60, height: 60, child: icon),

          Text(
            temp,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
