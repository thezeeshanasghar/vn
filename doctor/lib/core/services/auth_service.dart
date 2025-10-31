import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../../models/doctor.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'identifier': identifier,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return {
          'success': true,
          'token': responseData['token'],
          'doctor': Doctor.fromJson(responseData['doctor']),
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (error) {
      print('Login error: $error');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyEndpoint),
        headers: ApiConfig.getAuthHeaders(token),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success']) {
        return {
          'success': true,
          'doctor': Doctor.fromJson(responseData['doctor']),
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Token verification failed',
        };
      }
    } catch (error) {
      print('Token verification error: $error');
      return {
        'success': false,
        'message': 'Token verification failed',
      };
    }
  }
}
