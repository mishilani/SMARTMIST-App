import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherLottieIcon extends StatelessWidget {
  final String weather;
  final double size;

  const WeatherLottieIcon({super.key, required this.weather, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      "assets/weather_icons/$weather.json",
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
