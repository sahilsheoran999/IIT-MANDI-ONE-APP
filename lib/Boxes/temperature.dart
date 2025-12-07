import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart';
import 'weather_service.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService weatherService = WeatherService();
  String city = 'Mandi';
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final data = await weatherService.getWeather(city);
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        weatherData = null; // Ensure it's set to null if fetching fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
 
    String temperature = weatherData?['main']['temp']?.toStringAsFixed(1) ?? '--';
    String description = weatherData?['weather']?[0]['description'] ?? '--';
    String feelsLike = weatherData?['main']['feels_like']?.toStringAsFixed(1) ?? '--';

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '$temperature°C',
              style:mainHeadingStyle(context)
            ),
            SizedBox(width: 10),
            Text(
              description,
              style: subheadingStyle(context),
            ),
          ],
        ),
        SizedBox(height: 3),
        Text(
          'Feels like: $feelsLike°C',
          style: normalsize(context),
        ),
        SizedBox(height: 50,)
      ],
    );
  }
}
