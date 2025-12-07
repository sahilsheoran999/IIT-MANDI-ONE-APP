import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = 'c4db88fccd91b5b59941e202e8cbda17'; // Replace with your OpenWeatherMap API key

  Future<Map<String, dynamic>> getWeather(String city) async {
  try {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

}
