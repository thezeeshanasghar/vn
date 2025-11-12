import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/assistant.dart';

class PaAuthResult {
  final String token;
  final PaAssistant assistant;

  PaAuthResult({required this.token, required this.assistant});
}

class PaAuthService {
  static const String baseUrl = 'http://localhost:3000/api';

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<PaAuthResult> login(String identifier, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pa-auth/login'),
      headers: _headers,
      body: json.encode({
        'identifier': identifier,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
      final assistant = PaAssistant.fromJson(body['assistant'] as Map<String, dynamic>);
      final List<PaClinicAccess> clinicAccess = ((body['clinicAccess'] as List?) ?? [])
          .map((item) => PaClinicAccess.fromJson(item as Map<String, dynamic>))
          .toList();

      final enriched = PaAssistant(
        paId: assistant.paId,
        doctorId: assistant.doctorId,
        firstName: assistant.firstName,
        lastName: assistant.lastName,
        email: assistant.email,
        mobileNumber: assistant.mobileNumber,
        isActive: assistant.isActive,
        permissions: assistant.permissions,
        clinicAccess: clinicAccess,
      );

      return PaAuthResult(
        token: body['token'] as String,
        assistant: enriched,
      );
    }

    throw Exception(_extractError(response.body, 'Invalid credentials'));
  }

  Future<PaAssistant> verify(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pa-auth/verify'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
      final assistant = PaAssistant.fromJson(body['assistant'] as Map<String, dynamic>);
      final List<PaClinicAccess> clinicAccess = ((body['clinicAccess'] as List?) ?? [])
          .map((item) => PaClinicAccess.fromJson(item as Map<String, dynamic>))
          .toList();
      return PaAssistant(
        paId: assistant.paId,
        doctorId: assistant.doctorId,
        firstName: assistant.firstName,
        lastName: assistant.lastName,
        email: assistant.email,
        mobileNumber: assistant.mobileNumber,
        isActive: assistant.isActive,
        permissions: assistant.permissions,
        clinicAccess: clinicAccess,
      );
    }

    throw Exception('Session expired. Please login again.');
  }

  String _extractError(String body, String fallback) {
    try {
      final Map<String, dynamic> jsonData = json.decode(body) as Map<String, dynamic>;
      return jsonData['message'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}

