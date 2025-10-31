import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor_schedule.dart';

class DoctorScheduleService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<List<DoctorSchedule>> getSchedulesByDoctor(int doctorId) async {
    final uri = Uri.parse('$baseUrl/doctor-schedules').replace(queryParameters: {
      'doctorId': doctorId.toString(),
    });
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final list = (data['data'] as List).cast<dynamic>();
      return list.map((e) => DoctorSchedule.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load schedules: ${res.statusCode}');
  }

  static Future<List<DoctorSchedule>> createSchedules(int doctorId, List<int> doseIds) async {
    final uri = Uri.parse('$baseUrl/doctor-schedules');
    final body = json.encode({
      'doctorId': doctorId,
      'doseIds': doseIds,
    });
    final res = await http.post(uri, headers: _headers, body: body);
    if (res.statusCode == 201) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final list = (data['data'] as List).cast<dynamic>();
      return list.map((e) => DoctorSchedule.fromJson(e as Map<String, dynamic>)).toList();
    }
    final error = json.decode(res.body) as Map<String, dynamic>;
    throw Exception(error['message'] ?? 'Failed to create schedules');
  }

  static Future<DoctorSchedule> updateSchedule(int scheduleId, Map<String, dynamic> updates) async {
    final uri = Uri.parse('$baseUrl/doctor-schedules/$scheduleId');
    final res = await http.put(uri, headers: _headers, body: json.encode(updates));
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return DoctorSchedule.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to update schedule');
  }

  static Future<void> deleteSchedule(int scheduleId) async {
    final uri = Uri.parse('$baseUrl/doctor-schedules/$scheduleId');
    final res = await http.delete(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete schedule');
    }
  }
}
