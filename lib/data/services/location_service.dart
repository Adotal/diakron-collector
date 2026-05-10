import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:logger/web.dart';

class LocationService {
  // Configuración de la distancia mínima para reportar (cada 200 metros)
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,    
    distanceFilter: 200,
  );

  final _logger = Logger();

  void startTracking(String userId, String? fcmToken) async {
    // 1. Verificar/Pedir permisos
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Servicios de ubicación desactivados.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Permisos denegados.');
    }

    // 2. Escuchar cambios de ubicación (Stream)
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        _sendToServer(userId, position.latitude, position.longitude, fcmToken);
      },
    );
  }

  Future<void> _sendToServer(String userId, double lat, double lon, String? token) async {
    final url = Uri.parse('https://diakron-backend.onrender.com/update-location');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'lat': lat,
          'lon': lon,
          'fcmToken': token, // Lo enviamos para que Node sepa a quién notificar
        }),
      );

      if (response.statusCode == 200) {
        _logger.i('Ubicación reportada: $lat, $lon');
      }
    } catch (e) {
      _logger.i('Error enviando ubicación: $e');
    }
  }
}