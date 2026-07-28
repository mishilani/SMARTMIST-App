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
    return Container(
      width: double.infinity,
      height: 80,

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(30),

        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Transform.translate(
              offset: Offset(10, 0),
              child: Text(
                day,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          Text(
            temp,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(
            width: 70,
            height: 70,
            child: WeatherLottieIcon(weather: icon, size: 70),
          ),
        ],
      ),
    );
  }
}
