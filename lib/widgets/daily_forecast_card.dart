import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmist_app/widgets/weather_lottie_icon.dart';

class DailyForecastCard extends StatelessWidget {
  final String day;
  final String temp;
  final String humidity;
  final String heatIndex;
  final String icon;

  const DailyForecastCard({
    super.key,
    required this.day,
    required this.temp,
    required this.humidity,
    required this.heatIndex,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double cardHeight = size.height * 0.10;
    final double horizontalPadding = size.width * 0.05;
    final double iconSize = size.width * 0.15;

    return Container(
      width: double.infinity,
      height: cardHeight,

      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: size.height * 0.012,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(size.width * 0.08),

        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: size.width * 0.03,
            offset: Offset(0, size.height * 0.008),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              day,

              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            temp,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(
            width: iconSize,
            height: iconSize,

            child: WeatherLottieIcon(weather: icon, size: iconSize),
          ),
        ],
      ),
    );
  }
}
