import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/patient.dart';

class PaPatientService {
  static const String baseUrl = 'http://localhost:3000/api';

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<List<PaPatient>> getPatients({
    required int paId,
    int? clinicId,
    String? search,
    bool? isActive,
  }) async {
    final query = <String, String>{};
    if (clinicId != null) {
      query['clinicId'] = clinicId.toString();
    }
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    if (isActive != null) {
      query['isActive'] = isActive.toString();
    }

    final uri = Uri.parse('$baseUrl/patients/by-pa/$paId')
        .replace(queryParameters: query.isEmpty ? null : query);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> list = body['data'] as List<dynamic>? ?? [];
      return list
          .map((item) => PaPatient.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(_extractError(response.body, 'Failed to load patients'));
  }

  Future<PaPatient> createPatient(PaPatient patient) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patients'),
      headers: _headers,
      body: json.encode(patient.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
      return PaPatient.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception(_extractError(response.body, 'Failed to create patient'));
  }

  Future<PaPatient> updatePatient(int patientId, PaPatient patient) async {
    final response = await http.put(
      Uri.parse('$baseUrl/patients/$patientId'),
      headers: _headers,
      body: json.encode(patient.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
      return PaPatient.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception(_extractError(response.body, 'Failed to update patient'));
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

