import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Weather = ({double tempC, String summary});

// Open-Meteo needs no API key. Coordinates are Salem, the hub this app serves.
const _url = 'https://api.open-meteo.com/v1/forecast'
    '?latitude=11.66&longitude=78.15&current=temperature_2m,weather_code';

/// Current conditions for the home card; null when offline so the chip hides.
final weatherProvider = FutureProvider.autoDispose<Weather?>((ref) async {
  try {
    final res = await Dio().get<Map<String, dynamic>>(
      _url,
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final current = res.data!['current'] as Map<String, dynamic>;
    return (
      tempC: (current['temperature_2m'] as num).toDouble(),
      summary: _describe(current['weather_code'] as int),
    );
  } catch (_) {
    return null;
  }
});

String _describe(int code) => switch (code) {
      0 => 'Clear',
      1 || 2 => 'Partly cloudy',
      3 => 'Overcast',
      45 || 48 => 'Fog',
      >= 51 && <= 57 => 'Drizzle',
      >= 61 && <= 67 => 'Rain',
      >= 71 && <= 77 => 'Snow',
      >= 80 && <= 82 => 'Showers',
      >= 95 => 'Thunderstorm',
      _ => 'Cloudy',
    };
