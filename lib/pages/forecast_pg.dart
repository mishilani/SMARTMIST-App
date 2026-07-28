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
  final double size;
  final double x;
  final double y;
  final double textX;
  final double textY;
  final double degreeX;
  final double degreeY;
  final double conditionX;
  final double conditionY;

  WeatherDisplay({
    required this.animation,
    required this.condition,
    required this.size,
    required this.x,
    required this.y,
    required this.textX,
    required this.textY,
    required this.degreeX,
    required this.degreeY,
    required this.conditionX,
    required this.conditionY,
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

  WeatherDisplay getWeatherDisplay(int code) {
    switch (code) {
      case 0:
        return WeatherDisplay(
          animation: "clear-day",
          condition: "Sunny",
          size: 280,
          x: -29,
          y: 17,
          textX: 14,
          textY: 25,
          degreeX: 0,
          degreeY: 3,
          conditionX: 4,
          conditionY: -6,
        );

      case 1:
      case 2:
        return WeatherDisplay(
          animation: "partly-cloudy-day",
          condition: "Partly Cloudy",
          size: 360,
          x: -24,
          y: 35,
          textX: 19,
          textY: 29,
          degreeX: 0,
          degreeY: 3,
          conditionX: 4,
          conditionY: -6,
        );

      case 3:
      case 45:
      case 48:
        return WeatherDisplay(
          animation: "overcast",
          condition: "Cloudy",
          size: 430,
          x: -23,
          y: 23,
          textX: 60,
          textY: 30,
          degreeX: 0,
          degreeY: 3,
          conditionX: 4,
          conditionY: -6,
        );

      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return WeatherDisplay(
          animation: "rain",
          condition: "Rainy",
          size: 360,
          x: -29,
          y: -5,
          textX: 25,
          textY: 25,
          degreeX: 0,
          degreeY: 3,
          conditionX: 4,
          conditionY: -6,
        );

      case 95:
      case 96:
      case 99:
        return WeatherDisplay(
          animation: "thunderstorms-overcast-rain",
          condition: "Thunderstorms",
          size: 360,
          x: -20,
          y: -2,
          textX: 33,
          textY: 28,
          degreeX: 0,
          degreeY: 3,
          conditionX: 4,
          conditionY: -6,
        );

      default:
        return WeatherDisplay(
          animation: "overcast",
          condition: "Cloudy",
          size: 400,
          x: -25,
          y: 10,
          textX: 14,
          textY: 25,
          degreeX: 0,
          degreeY: 3,
          conditionX: 4,
          conditionY: -6,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                //////////
                final display = getWeatherDisplay(95);
                /////////////////
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(display.x, display.y),
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: OverflowBox(
                              alignment: Alignment.center,
                              maxWidth: 500,
                              maxHeight: 500,
                              child: WeatherLottieIcon(
                                weather: display.animation,
                                size: display.size,
                              ),
                            ),
                          ),
                        ),

                        Transform.translate(
                          offset: Offset(display.textX, display.textY),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${weather!.temp.round()}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 60,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF263238),
                                      height: 1,
                                    ),
                                  ),

                                  Transform.translate(
                                    offset: Offset(
                                      display.degreeX,
                                      display.degreeY,
                                    ),
                                    child: Text(
                                      "°C",
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF455A64),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Transform.translate(
                                offset: Offset(
                                  display.conditionX,
                                  display.conditionY,
                                ),
                                child: Text(
                                  display.condition,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF455A64),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 78),

                    SizedBox(
                      height: 50,
                      child: GlassContainer(
                        child: weatherInfo(
                          CupertinoIcons.drop_fill,
                          "${weather!.humidity}%",
                          "Humidity",
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      height: 50,
                      child: GlassContainer(
                        child: weatherInfo(
                          CupertinoIcons.thermometer,
                          "${weather!.heatIndex.round()}°C",
                          "Heat Index",
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      height: 50,
                      child: GlassContainer(
                        child: weatherInfo(
                          CupertinoIcons.sun_max_fill,
                          "${weather!.temp.round()}°C",
                          "Temperature",
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        forecastTab("Today", 0),
                        forecastTab("Tomorrow", 1),
                        forecastTab(
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

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 110,
                      child: ScrollConfiguration(
                        behavior: const ScrollBehavior().copyWith(
                          scrollbars: false,
                        ),

                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          primary: false,
                          padding: const EdgeInsets.only(right: 20),
                          itemCount: hourlyData.length,
                          itemBuilder: (context, index) {
                            final hourly = hourlyData[index];

                            return Padding(
                              padding: const EdgeInsets.only(right: 12),

                              child: HourlyWeatherCard(
                                time: hourly.time,
                                temp: "${hourly.temp.round()}°C",
                                icon: WeatherLottieIcon(
                                  weather: getWeatherDisplay(
                                    hourly.weatherCode,
                                  ).animation,
                                  size: 50,
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

  Widget weatherInfo(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),

        Expanded(
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        SizedBox(
          width: 60,
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget forecastTab(String title, int index, {VoidCallback? onTap}) {
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
              fontSize: 13,
              color: active
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.45),
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          const SizedBox(height: 5),

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: active ? 35 : 0,
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
