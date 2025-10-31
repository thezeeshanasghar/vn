import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final res = await http.post(
      Uri.parse(ApiConfig.login),
      headers: ApiConfig.defaultHeaders,
      body: json.encode({
        'identifier': identifier,
        'password': password,
      }),
    );

    final data = json.decode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && data['success'] == true) {
      final token = data['token'] as String;
      final doctor = data['doctor'] as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('doctor', json.encode(doctor));
      return {'success': true, 'token': token, 'doctor': doctor};
    }

    return {'success': false, 'message': data['message'] ?? 'Invalid credentials'};
  }

  Future<Map<String, dynamic>> verify(String token) async {
    final res = await http.post(
      Uri.parse(ApiConfig.verify),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    );
    final data = json.decode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'doctor': data['doctor']};
    }
    return {'success': false, 'message': data['message'] ?? 'Unauthorized'};
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('doctor');
  }
}


