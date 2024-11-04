import 'dart:convert';
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logging/logging.dart';

class WeatherService {
  static const baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;
  final Logger _logger = Logger('WeatherService');

  WeatherService(this.apiKey) {
    Logger.root.level = Level.ALL; // Permite todos los niveles de logging
    Logger.root.onRecord.listen((record) {
      print(
          '${record.level.name}: ${record.time}: ${record.message}'); // Cambié _logger.info por print
    });
  }

  // Método para obtener el clima de una ciudad específica
  Future<Weather> getWeatherByCity(String cityName) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load weather data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error fetching weather data: $e');
      throw Exception('Failed to load weather data');
    }
  }

  // Método para obtener el clima de una ciudad predeterminada
  Future<Weather> getWeatherForSantaMarta() async {
    String cityName = 'London'; // Puedes cambiar el nombre de la ciudad aquí
    return await getWeatherByCity(cityName);
  }

  Future<String> getCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      for (var placemark in placemarks) {
        _logger.info('Placemark: ${placemark.toJson()}');
        _logger.info('Locality: ${placemark.locality}');
        _logger.info('Country: ${placemark.country}');
        _logger.info('Administrative Area: ${placemark.administrativeArea}');
      }

      String? city;
      if (placemarks.isNotEmpty && placemarks[0].locality != null) {
        city = placemarks[0].locality;
      } else {
        _logger.warning('No placemarks found or locality is null');
      }

      return city ?? "";
    } catch (e) {
      _logger.severe('Error fetching current city: $e');
      rethrow;
    }
  }
}
