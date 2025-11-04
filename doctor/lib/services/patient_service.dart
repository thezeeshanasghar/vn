import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient.dart';

class PatientService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<List<Patient>> getPatients({int? doctorId, int? clinicId, String? search, bool? isActive}) async {
    final params = <String, String>{};
    if (doctorId != null) params['doctorId'] = doctorId.toString();
    if (clinicId != null) params['clinicId'] = clinicId.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (isActive != null) params['isActive'] = isActive.toString();
    final uri = Uri.parse('$baseUrl/patients').replace(queryParameters: params.isEmpty ? null : params);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final list = (data['data'] as List).cast<dynamic>();
      return list.map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load patients');
  }

  static Future<Patient> createPatient(Patient patient) async {
    final res = await http.post(
      Uri.parse('$baseUrl/patients'),
      headers: _headers,
      body: json.encode(patient.toJson()),
    );
    if (res.statusCode == 201) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return Patient.fromJson(data['data'] as Map<String, dynamic>);
    }
    
    // Extract error message from response
    try {
      final errorData = json.decode(res.body) as Map<String, dynamic>;
      final message = errorData['message'] as String? ?? 'Failed to create patient';
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to create patient');
    }
  }

  static Future<Patient> updatePatient(int patientId, Patient patient) async {
    final res = await http.put(
      Uri.parse('$baseUrl/patients/$patientId'),
      headers: _headers,
      body: json.encode(patient.toJson()),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return Patient.fromJson(data['data'] as Map<String, dynamic>);
    }
    
    // Extract error message from response
    try {
      final errorData = json.decode(res.body) as Map<String, dynamic>;
      final message = errorData['message'] as String? ?? 'Failed to update patient';
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to update patient');
    }
  }

  static Future<void> deletePatient(int patientId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/patients/$patientId'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete patient');
    }
  }

  static Future<Map<int, int>> getPatientCountsByClinic(int doctorId) async {
    final uri = Uri.parse('$baseUrl/patients/counts').replace(queryParameters: {'doctorId': doctorId.toString()});
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final counts = data['data'] as Map<String, dynamic>;
      return counts.map((key, value) => MapEntry(int.parse(key), value as int));
    }
    throw Exception('Failed to load patient counts');
  }
}


