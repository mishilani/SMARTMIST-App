import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  Future<WeatherModel> getWeather() async {
    const latitude = 14.995;
    const longitude = 120.652;

    final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast"
      "?latitude=$latitude"
      "&longitude=$longitude"
      "&current=temperature_2m,relative_humidity_2m,weather_code"
      "&hourly=temperature_2m,weather_code"
      "&daily=temperature_2m_max,relative_humidity_2m_max,weather_code"
      "&forecast_days=9"
      "&timezone=Asia%2FManila",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final current = data["current"];
      final hourly = data["hourly"];
      final daily = data["daily"];

      List<HourlyWeather> hourlyToday = [];
      List<HourlyWeather> hourlyTomorrow = [];

      DateTime now = DateTime.parse(current["time"]);

      DateTime nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);

      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      for (int i = 0; i < hourly["time"].length; i++) {
        DateTime forecastTime = DateTime.parse(hourly["time"][i]);

        final forecastDay = DateTime(
          forecastTime.year,
          forecastTime.month,
          forecastTime.day,
        );

        HourlyWeather item = HourlyWeather(
          time: formatTime(forecastTime),
          temp: hourly["temperature_2m"][i].toDouble(),
          weatherCode: hourly["weather_code"][i],
        );

        if (forecastDay.isAtSameMomentAs(today) &&
            !forecastTime.isBefore(nextHour)) {
          hourlyToday.add(item);
        } else if (forecastDay.isAtSameMomentAs(tomorrow)) {
          hourlyTomorrow.add(item);
        }
        // any day beyond tomorrow is intentionally ignored —
        // only used for the separate 7-day daily forecast
      }

      print("========== TODAY ==========");

      for (final h in hourlyToday) {
        print(h.time);
      }
      List<DailyWeather> dailyList = [];

      for (int i = 0; i < daily["time"].length; i++) {
        DateTime date = DateTime.parse(daily["time"][i]);

        dailyList.add(
          DailyWeather(
            day: getDayName(date),
            temp: daily["temperature_2m_max"][i].toDouble(),
            humidity: daily["relative_humidity_2m_max"][i],
            weatherCode: daily["weather_code"][i],
          ),
        );
      }

      return WeatherModel(
        temp: current["temperature_2m"].toDouble(),
        humidity: current["relative_humidity_2m"],
        heatIndex: calculatedHeatIndex(
          current["temperature_2m"].toDouble(),
          current["relative_humidity_2m"],
        ),
        weatherCode: current["weather_code"],
        hourlyToday: hourlyToday,
        hourlyTomorrow: hourlyTomorrow,
        daily: dailyList,
      );
    } else {
      throw Exception("Failed to load weather");
    }
  }

  String formatTime(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? "PM" : "AM";
    int displayHour = hour % 12;

    if (displayHour == 0) {
      displayHour = 12;
    }

    return "$displayHour $period";
  }

  String getDayName(DateTime date) {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return days[date.weekday - 1];
  }

  double calculatedHeatIndex(double temp, int humidity) {
    return temp + (humidity * 0.05);
  }
}
