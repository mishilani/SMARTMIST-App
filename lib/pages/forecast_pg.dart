import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smartmist_app/widgets/dashboard_scaffold.dart';
import 'package:smartmist_app/widgets/glass_container.dart';
import 'package:smartmist_app/widgets/hourly_weather_card.dart';
import 'package:smartmist_app/services/weather_service.dart';
import 'package:smartmist_app/models/weather_model.dart';
import 'package:smartmist_app/widgets/weather_lottie_icon.dart';
import 'package:smartmist_app/pages/next7days_pg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class WeatherDisplay {
  final String animation;
  final String condition;

  final double iconScale;
  final double tempScale;
  final double degreeScale;
  final double conditionScale;

  final double iconOffsetX;
  final double iconOffsetY;
  final double textOffsetX;
  final double textOffsetY;

  const WeatherDisplay({
    required this.animation,
    required this.condition,
    this.iconScale = 1.0,
    this.tempScale = 1.0,
    this.degreeScale = 1.0,
    this.conditionScale = 1.0,
    this.iconOffsetX = 0,
    this.iconOffsetY = 0,
    this.textOffsetX = 0,
    this.textOffsetY = 0,
  });
}

class ForecastPage extends StatefulWidget {
  const ForecastPage({super.key});

  @override
  State<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  WeatherModel? weather;

  String getCurrentDate() {
    return DateFormat("EEEE, MMMM d").format(DateTime.now());
  }

  final WeatherService weatherService = WeatherService();
  bool isLoading = true;
  int selectedForecast = 0;
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref('sensor');

  StreamSubscription<DatabaseEvent>? _sensorSub;

  double? liveTemp;
  double? liveHumidity;
  double? liveHeatIndex;

  @override
  void initState() {
    super.initState();
    loadWeather();
    _listenToSensor();
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    super.dispose();
  }

  Future<void> loadWeather() async {
    final result = await weatherService.getWeather();

    setState(() {
      weather = result;
      isLoading = false;
    });
  }

  void _listenToSensor() {
    _sensorSub = _sensorRef.onValue.listen(
      (event) {
        final data = event.snapshot.value;

        if (data is Map) {
          setState(() {
            liveTemp = (data['temperature'] as num?)?.toDouble();
            liveHumidity = (data['humidity'] as num?)?.toDouble();
            liveHeatIndex = (data['heatIndex'] as num?)?.toDouble();
          });
        }
      },
      onError: (error) {
        debugPrint("Sensor stream error: $error");
      },
    );
  }

  bool _isThunderCode(int c) => c == 95 || c == 96 || c == 99;

  bool _isRainCode(int c) =>
      const [51, 53, 55, 61, 63, 65, 80, 81, 82].contains(c);

  bool _isOvercastCode(int c) => c == 3 || c == 45 || c == 48;

  WeatherDisplay getWeatherDisplay(int code, double heatValue) {
    if (_isThunderCode(code)) {
      return const WeatherDisplay(
        animation: "thunderstorms-overcast-rain",
        condition: "Thunderstorms",
        iconScale: 0.9,
        tempScale: 0.8,
        degreeScale: 1.00,
        conditionScale: 0.8,
        iconOffsetX: 17,
        iconOffsetY: -2,
        textOffsetX: 33,
        textOffsetY: 28,
      );
    }

    if (_isRainCode(code)) {
      return const WeatherDisplay(
        animation: "rain",
        condition: "Rainy",
        iconScale: 0.9,
        tempScale: 0.8,
        degreeScale: 1.00,
        conditionScale: 0.8,
        iconOffsetX: -11,
        iconOffsetY: -5,
        textOffsetX: 13,
        textOffsetY: 6,
      );
    }

    if (_isOvercastCode(code)) {
      return const WeatherDisplay(
        animation: "overcast",
        condition: "Cloudy",
        iconScale: 1.0,
        tempScale: 0.8,
        degreeScale: 1.00,
        conditionScale: 0.8,
        iconOffsetX: -23,
        iconOffsetY: 18,
        textOffsetX: 14,
        textOffsetY: 18,
      );
    }

    if (heatValue >= 51) {
      return const WeatherDisplay(
        animation: "clear-day",
        condition: "Extreme Heat",
        iconScale: 0.9,
        tempScale: 0.8,
        degreeScale: 1.00,
        conditionScale: 0.75,
        iconOffsetX: -5,
        iconOffsetY: 17,
        textOffsetX: 14,
        textOffsetY: 15,
      );
    } else if (heatValue >= 39) {
      return const WeatherDisplay(
        animation: "clear-day",
        condition: "Very Hot",
        iconScale: 0.9,
        tempScale: 0.8,
        degreeScale: 1.00,
        conditionScale: 0.8,
        iconOffsetX: -5,
        iconOffsetY: 17,
        textOffsetX: 14,
        textOffsetY: 15,
      );
    } else if (heatValue >= 32) {
      return const WeatherDisplay(
        animation: "clear-day",
        condition: "Hot",
        iconScale: 0.9,
        tempScale: 0.8,
        degreeScale: 1.00,
        conditionScale: 0.8,
        iconOffsetX: -5,
        iconOffsetY: 17,
        textOffsetX: 14,
        textOffsetY: 15,
      );
    } else if (code == 0) {
      return const WeatherDisplay(
        animation: "clear-day",
        condition: "Sunny",
        iconScale: 0.9,
        tempScale: 0.8,
        degreeScale: 1.00,
        conditionScale: 0.8,
        iconOffsetX: -5,
        iconOffsetY: 17,
        textOffsetX: 14,
        textOffsetY: 15,
      );
    } else {
      return const WeatherDisplay(
        animation: "partly-cloudy-day",
        condition: "Partly Cloudy",
        iconScale: 1.0,
        tempScale: 0.8,
        degreeScale: 1.00,
        conditionScale: 0.8,
        iconOffsetX: 5,
        iconOffsetY: 18,
        textOffsetX: 18,
        textOffsetY: 15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return DashboardScaffold(
      title: "Bacolor Forecast",
      subtitle: getCurrentDate(),

      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : weather == null
          ? const Center(
              child: Text(
                "Failed to load weather",
                style: TextStyle(color: Colors.white),
              ),
            )
          : Builder(
              builder: (context) {
                final hourlyData = selectedForecast == 0
                    ? weather!.hourlyToday
                    : weather!.hourlyTomorrow;
                final displayTemp = liveTemp ?? weather!.temp;
                final displayHumidity = liveHumidity ?? weather!.humidity;
                final displayHeatIndex = liveHeatIndex ?? weather!.heatIndex;

                final display = getWeatherDisplay(
                  weather!.weatherCode,
                  displayHeatIndex,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: height * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: width * 0.35,
                          height: width * 0.35,
                          child: OverflowBox(
                            alignment: Alignment.center,
                            maxWidth: width,
                            maxHeight: width,
                            child: Transform.translate(
                              offset: Offset(
                                display.iconOffsetX,
                                display.iconOffsetY,
                              ),
                              child: WeatherLottieIcon(
                                weather: display.animation,
                                size: width * 0.70 * display.iconScale,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: width * 0.04),

                        Transform.translate(
                          offset: Offset(
                            display.textOffsetX,
                            display.textOffsetY,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${displayHeatIndex.round()}",
                                    style: GoogleFonts.poppins(
                                      fontSize:
                                          width * 0.14 * display.tempScale,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF263238),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: height * 0.01,
                                      left: width * 0.005,
                                    ),
                                    child: Text(
                                      "°C",
                                      style: GoogleFonts.poppins(
                                        fontSize:
                                            width * 0.05 * display.degreeScale,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF455A64),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: height * 0.0040),

                              Text(
                                display.condition,
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      width * 0.045 * display.conditionScale,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF455A64),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.05),

                    SizedBox(
                      height: height * 0.065,
                      child: GlassContainer(
                        child: weatherInfo(
                          context,
                          CupertinoIcons.drop_fill,
                          "${displayHumidity.round()}%",
                          "Humidity",
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.01),

                    SizedBox(
                      height: height * 0.065,
                      child: GlassContainer(
                        child: weatherInfo(
                          context,
                          CupertinoIcons.thermometer,
                          "${displayHeatIndex.round()}°C",
                          "Heat Index",
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.01),

                    SizedBox(
                      height: height * 0.065,
                      child: GlassContainer(
                        child: weatherInfo(
                          context,
                          CupertinoIcons.sun_max_fill,
                          "${displayTemp.round()}°C",
                          "Temperature",
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.030),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        forecastTab(context, "Today", 0),
                        forecastTab(context, "Tomorrow", 1),
                        forecastTab(
                          context,
                          "Next 7 Days",
                          2,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Next7daysPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.015),

                    SizedBox(
                      height: height * 0.15,
                      child: ScrollConfiguration(
                        behavior: const ScrollBehavior().copyWith(
                          scrollbars: false,
                        ),

                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          primary: false,
                          padding: EdgeInsets.only(right: width * 0.05),
                          itemCount: hourlyData.length,
                          itemBuilder: (context, index) {
                            final hourly = hourlyData[index];

                            return Padding(
                              padding: EdgeInsets.only(right: width * 0.03),

                              child: HourlyWeatherCard(
                                time: hourly.time,
                                temp: "${hourly.temp.round()}°C",
                                icon: WeatherLottieIcon(
                                  weather: getWeatherDisplay(
                                    hourly.weatherCode,
                                    hourly.temp,
                                  ).animation,
                                  size: width * 0.12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget weatherInfo(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final width = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Container(
          width: width * 0.08,
          height: width * 0.08,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(width * 0.03),
          ),
          child: Icon(icon, color: Colors.blue, size: width * 0.05),
        ),

        SizedBox(width: width * 0.03),

        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: width * 0.033,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        SizedBox(
          width: width * 0.18,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: width * 0.038,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget forecastTab(
    BuildContext context,
    String title,
    int index, {
    VoidCallback? onTap,
  }) {
    final width = MediaQuery.of(context).size.width;

    bool active = selectedForecast == index;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
          return;
        }

        setState(() {
          selectedForecast = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: width * 0.033,
              color: active
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.45),
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          SizedBox(height: width * 0.01),

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: active ? width * 0.09 : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
