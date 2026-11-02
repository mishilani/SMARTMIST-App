import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smartmist_app/models/weather_model.dart';
import 'package:smartmist_app/services/weather_service.dart';
import 'package:smartmist_app/widgets/daily_forecast_card.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';
import 'package:smartmist_app/widgets/glass_container.dart';
import 'package:smartmist_app/widgets/weather_lottie_icon.dart';

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

  bool _isThunderCode(int c) => c == 95 || c == 96 || c == 99;

  bool _isRainCode(int c) =>
      const [51, 53, 55, 61, 63, 65, 80, 81, 82].contains(c);

  bool _isOvercastCode(int c) => c == 3 || c == 45 || c == 48;

  String getWeatherAnimation(int code, double heatValue) {
    if (_isThunderCode(code)) {
      return "thunderstorms-overcast-rain";
    }
    if (_isRainCode(code)) {
      return "rain";
    }
    if (_isOvercastCode(code)) {
      return "overcast";
    }

    if (heatValue >= 51) {
      return "clear-day";
    } else if (heatValue >= 39) {
      return "clear-day";
    } else if (heatValue >= 32) {
      return "clear-day";
    } else if (code == 0) {
      return "clear-day";
    } else {
      return "partly-cloudy-day";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return DashboardScaffold(
      title: "Next 7 Days",
      subtitle: "Bacolor Weather Forecast",
      showBackButton: true,
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: width * 0.008,
              ),
            )
          : weather == null
          ? const Center(
              child: Text(
                "Failed to load weather",
                style: TextStyle(color: Colors.white),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.03,
                vertical: height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.015),
                  Builder(
                    builder: (context) {
                      final featuredHeatIndex = calculatedHeatIndex(
                        weather!.daily[2].temp,
                        weather!.daily[2].humidity.round(),
                      );

                      return GlassContainer(
                        borderRadius: width * 0.07,
                        color: Colors.white.withValues(alpha: 0.25),
                        child: SizedBox(
                          height: height * 0.28,
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat("EEEE").format(
                                        DateTime.now().add(
                                          const Duration(days: 2),
                                        ),
                                      ),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: width * 0.045,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    WeatherLottieIcon(
                                      weather: getWeatherAnimation(
                                        weather!.daily[2].weatherCode,
                                        featuredHeatIndex,
                                      ),
                                      size: width * 0.18,
                                    ),
                                  ],
                                ),
                                SizedBox(height: height * 0.005),
                                Center(
                                  child: Text(
                                    "${weather!.daily[2].temp.round()}°C",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: width * 0.12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: weatherSmallCard(
                                        CupertinoIcons.drop_fill,
                                        "${weather!.daily[2].humidity.round()}%",
                                        "Humidity",
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Expanded(
                                      child: weatherSmallCard(
                                        CupertinoIcons.thermometer,
                                        "${featuredHeatIndex.round()}°C",
                                        "Heat Index",
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Expanded(
                                      child: weatherSmallCard(
                                        CupertinoIcons.sun_max_fill,
                                        "${weather!.daily[2].temp.round()}°C",
                                        "Temperature",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: height * 0.018),
                  Flexible(
                    child: ScrollConfiguration(
                      behavior: const ScrollBehavior().copyWith(
                        scrollbars: false,
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: weather!.daily.length - 3,
                        itemBuilder: (context, index) {
                          final day = weather!.daily[index + 3];
                          final date = DateTime.now().add(
                            Duration(days: index + 3),
                          );
                          final dayName = DateFormat("EEEE").format(date);
                          final dayHeatIndex = calculatedHeatIndex(
                            day.temp,
                            day.humidity.round(),
                          );

                          return Padding(
                            padding: EdgeInsets.only(bottom: height * 0.015),
                            child: DailyForecastCard(
                              day: dayName,
                              temp: "${day.temp.round()}°C",
                              humidity: "${day.humidity.round()}%",
                              heatIndex: "${dayHeatIndex.round()}°C",
                              icon: getWeatherAnimation(
                                day.weatherCode,
                                dayHeatIndex,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget weatherSmallCard(IconData icon, String value, String label) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      height: width * 0.22,
      padding: EdgeInsets.symmetric(horizontal: width * 0.01),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(width * 0.05),
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
          Icon(icon, color: const Color(0xFF0288D1), size: width * 0.06),
          SizedBox(height: width * 0.01),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: width * 0.038,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: width * 0.025,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double calculatedHeatIndex(double tempC, int humidity) {
    double tempF = (tempC * 9 / 5) + 32;

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
