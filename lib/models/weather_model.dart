class WeatherModel {
  final double temp;
  final int humidity;
  final double heatIndex;
  final int weatherCode;
  final List<HourlyWeather> hourlyToday;
  final List<HourlyWeather> hourlyTomorrow;
  final List<DailyWeather> daily;

  WeatherModel({
    required this.temp,
    required this.humidity,
    required this.heatIndex,
    required this.weatherCode,
    required this.hourlyToday,
    required this.hourlyTomorrow,
    required this.daily,
  });
}

class HourlyWeather {
  final String time;
  final double temp;
  final int weatherCode;

  HourlyWeather({
    required this.time,
    required this.temp,
    required this.weatherCode,
  });
}

class DailyWeather {
  final String day;
  final double temp;
  final int humidity;
  final int weatherCode;

  DailyWeather({
    required this.day,
    required this.temp,
    required this.humidity,
    required this.weatherCode,
  });
}
