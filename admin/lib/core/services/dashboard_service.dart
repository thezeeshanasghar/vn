import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class DashboardService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get dashboard statistics
  static Future<Map<String, int>> getDashboardStats() async {
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _getVaccinesCount(),
        _getBrandsCount(),
        _getDosesCount(),
        _getDoctorsCount(),
      ]);

      return {
        'vaccines': results[0],
        'brands': results[1],
        'doses': results[2],
        'doctors': results[3],
        'users': 156, // Static value as there's no users API
      };
    } catch (e) {
      throw Exception('Failed to load dashboard statistics: $e');
    }
  }

  // Get vaccines count
  static Future<int> _getVaccinesCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/vaccines'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'].length;
      }
    }
    throw Exception('Failed to load vaccines count');
  }

  // Get brands count
  static Future<int> _getBrandsCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/brands'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'].length;
      }
    }
    throw Exception('Failed to load brands count');
  }

  // Get doses count
  static Future<int> _getDosesCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/doses'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'].length;
      }
    }
    throw Exception('Failed to load doses count');
  }

  // Get doctors count
  static Future<int> _getDoctorsCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctors'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'].length;
      }
    }
    throw Exception('Failed to load doctors count');
  }

  // Health check
  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
