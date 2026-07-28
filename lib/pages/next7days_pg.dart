import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:smartmist_app/models/weather_model.dart';
import 'package:smartmist_app/services/weather_service.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';
import 'package:smartmist_app/widgets/glass_container.dart';
import 'package:smartmist_app/widgets/daily_forecast_card.dart';
import 'package:smartmist_app/widgets/weather_lottie_icon.dart';
import 'package:intl/intl.dart';

class Next7daysPage extends StatefulWidget {
  const Next7daysPage({super.key});

  @override
  State<Next7daysPage> createState() => _Next7daysPageState();
}

class _Next7daysPageState extends State<Next7daysPage> {
  WeatherModel? weather;
  final WeatherService weatherService = WeatherService();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadWeather();
  }

  Future<void> loadWeather() async {
    final result = await weatherService.getWeather();

    setState(() {
      weather = result;

      isLoading = false;
    });
  }

  String getWeatherAnimation(int code) {
    switch (code) {
      case 0:
        return "clear-day";

      case 1:
      case 2:
        return "partly-cloudy-day";

      case 3:
      case 45:
      case 48:
        return "overcast";

      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return "rain";

      case 95:
      case 96:
      case 99:
        return "thunderstorms-overcast-rain";

      default:
        return "overcast";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: "Next 7 Days",
      subtitle: "Bacolor Weather Forecast",
      showBackButton: true,
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : weather == null
          ? const Center(
              child: Text(
                "Failed to load weather",

                style: TextStyle(color: Colors.white),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 15),

                GlassContainer(
                  borderRadius: 30,
                  color: Colors.white.withValues(alpha: 0.25),
                  child: SizedBox(
                    height: 220,
                    child: Padding(
                      padding: const EdgeInsetsGeometry.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat("EEEE").format(
                                    DateTime.now().add(const Duration(days: 2)),
                                  ),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                WeatherLottieIcon(
                                  weather: getWeatherAnimation(
                                    weather!.daily[2].weatherCode,
                                  ),
                                  size: 70,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 0),

                          Center(
                            child: Text(
                              "${weather!.daily[2].temp.round()}°C",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const Spacer(),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              weatherSmallCard(
                                CupertinoIcons.drop_fill,
                                "${weather!.daily[2].humidity.round()}%",
                                "Humidity",
                              ),

                              weatherSmallCard(
                                CupertinoIcons.thermometer,
                                "${calculatedHeatIndex(weather!.daily[2].temp, weather!.daily[2].humidity.round()).round()}°C",
                                "Heat Index",
                              ),

                              weatherSmallCard(
                                CupertinoIcons.sun_max_fill,
                                "${weather!.daily[2].temp.round()}°C",
                                "Temperature",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Expanded(
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(
                      scrollbars: false,
                    ),

                    child: ListView.builder(
                      itemCount: weather!.daily.length - 3,

                      itemBuilder: (context, index) {
                        final day = weather!.daily[index + 3];
                        final date = DateTime.now().add(
                          Duration(days: index + 3),
                        );
                        final dayName = DateFormat("EEEE").format(date);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),

                          child: DailyForecastCard(
                            day: dayName,
                            temp: "${day.temp.round()}°C",
                            humidity: "${day.humidity.round()}%",
                            heatIndex:
                                "${calculatedHeatIndex(day.temp, day.humidity.round()).round()}°C",
                            icon: getWeatherAnimation(day.weatherCode),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget weatherSmallCard(IconData icon, String value, String label) {
    return Container(
      width: 85,
      height: 75,

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF0288D1), size: 22),

          const SizedBox(height: 3),

          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  double calculatedHeatIndex(double tempC, int humidity) {
    // Convert Celsius to Fahrenheit
    double tempF = (tempC * 9 / 5) + 32;

    // NOAA Heat Index formula
    double heatIndexF =
        -42.379 +
        2.04901523 * tempF +
        10.14333127 * humidity -
        0.22475541 * tempF * humidity -
        0.00683783 * tempF * tempF -
        0.05481717 * humidity * humidity +
        0.00122874 * tempF * tempF * humidity +
        0.00085282 * tempF * humidity * humidity -
        0.00000199 * tempF * tempF * humidity * humidity;

    // Convert Fahrenheit back to Celsius
    double heatIndexC = (heatIndexF - 32) * 5 / 9;

    return heatIndexC;
  }

  IconData getWeatherIcon(int code) {
    if (code == 0) {
      return CupertinoIcons.sun_max_fill;
    } else if (code <= 3) {
      return CupertinoIcons.cloud_sun_fill;
    } else if (code <= 67) {
      return CupertinoIcons.cloud_rain_fill;
    } else {
      return CupertinoIcons.cloud_fill;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
