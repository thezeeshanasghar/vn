import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/personal_assistant.dart';

class PersonalAssistantService {
  static const String baseUrl = 'http://localhost:3000/api';

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<List<PersonalAssistant>> getAssistantsByDoctor(int doctorId) async {
    final uri = Uri.parse('$baseUrl/personal-assistants/doctor/$doctorId');
    final res = await http.get(uri, headers: _headers);

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;
      final List<dynamic> list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((item) => PersonalAssistant.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(_extractErrorMessage(res.body, 'Failed to load personal assistants'));
  }

  Future<PersonalAssistant> createAssistant({
    required int doctorId,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? mobileNumber,
    PaPermissions? permissions,
    List<PaClinicAccess>? clinicAccess,
  }) async {
    final payload = {
      'doctorId': doctorId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobileNumber': mobileNumber ?? '',
      'password': password,
      'permissions': (permissions ?? const PaPermissions()).toJson(),
      'clinicAccess': (clinicAccess ?? const <PaClinicAccess>[]) 
          .map((access) => access.toUpdatePayload())
          .toList(),
    };

    final res = await http.post(
      Uri.parse('$baseUrl/personal-assistants'),
      headers: _headers,
      body: json.encode(payload),
    );

    if (res.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;
      return PersonalAssistant.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception(_extractErrorMessage(res.body, 'Failed to create personal assistant'));
  }

  Future<PersonalAssistant> updatePermissions(int paId, PaPermissions permissions) async {
    final res = await http.put(
      Uri.parse('$baseUrl/personal-assistants/$paId/permissions'),
      headers: _headers,
      body: json.encode(permissions.toJson()),
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;
      return PersonalAssistant.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception(_extractErrorMessage(res.body, 'Failed to update permissions'));
  }

  Future<PersonalAssistant> updateClinicAccess(int paId, List<PaClinicAccess> clinicAccess) async {
    final payload = {
      'clinicAccess': clinicAccess.map((access) => access.toUpdatePayload()).toList(),
    };

    final res = await http.put(
      Uri.parse('$baseUrl/personal-assistants/$paId/access'),
      headers: _headers,
      body: json.encode(payload),
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;
      return PersonalAssistant.fromJson(data['data'] as Map<String, dynamic>);
    }

    throw Exception(_extractErrorMessage(res.body, 'Failed to update clinic access'));
  }

  Future<void> deactivateAssistant(int paId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/personal-assistants/$paId'),
      headers: _headers,
    );

    if (res.statusCode != 200) {
      throw Exception(_extractErrorMessage(res.body, 'Failed to deactivate assistant'));
    }
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final Map<String, dynamic> data = json.decode(body) as Map<String, dynamic>;
      return data['message'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}

