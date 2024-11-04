import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:peticiones_http/services/weather_service.dart';
import 'package:peticiones_http/models/weather_model.dart';
import 'package:logging/logging.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('a908cb43d34712e9b5cffa6beae37bcb');
  Weather? _weather;

  // Configuración del logger
  final Logger _logger = Logger('WeatherPage');

  _fetchWeather() async {
    String cityName =
        'Santa Marta'; // Cambia aquí el nombre de la ciudad que deseas

    _logger.info('Fetching weather for city: $cityName');

    try {
      final weather = await _weatherService.getWeatherByCity(cityName);
      setState(() {
        _weather = weather;
      });
      _logger.info('Weather fetched successfully: ${weather.toJson()}');
    } catch (e) {
      _logger.severe('Error fetching weather data: $e');
      // Aquí podrías mostrar un mensaje al usuario sobre el error
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sun.json';

    switch (mainCondition.toLowerCase()) {
      case 'fog':
        return 'assets/cloud.json';
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sun.json';
      default:
        return 'assets/sun.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weather?.cityName ?? "Cargando Ciudad...",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
            Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
            Text(
              "${_weather?.temperature.round()}°C",
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w600,
                color: Colors.yellowAccent,
                fontFamily: 'Roboto',
              ),
            ),
            Text(
              _weather?.mainCondition ?? "",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: const Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.all(16.0), // Espaciado
          child: Text(
            "Realizado por Juan Pablo Ramirez :)",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }
}
