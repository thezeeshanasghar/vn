import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/patient_schedule.dart';

class PaPatientScheduleService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<List<PaPatientSchedule>> getSchedulesByChild(int childId) async {
    final uri = Uri.parse('$baseUrl/patient-schedules').replace(
      queryParameters: {'childId': childId.toString()},
    );
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((item) => PaPatientSchedule.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load patient schedules');
  }

  static Future<PaPatientSchedule> _updateSchedule(
    int scheduleId,
    Map<String, dynamic> updates,
  ) async {
    final uri = Uri.parse('$baseUrl/patient-schedules/$scheduleId');
    final response = await http.put(uri, headers: _headers, body: json.encode(updates));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
      return PaPatientSchedule.fromJson(data['data'] as Map<String, dynamic>);
    }

    try {
      final Map<String, dynamic> error = json.decode(response.body) as Map<String, dynamic>;
      final message = error['message'] as String? ?? 'Failed to update patient schedule';
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to update patient schedule');
    }
  }

  static Future<PaPatientSchedule> toggleIsDone(
    int scheduleId,
    bool isDone, {
    int? brandId,
  }) async {
    final updates = <String, dynamic>{'IsDone': isDone};

    if (isDone) {
      final now = DateTime.now();
      final dateOnly = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      updates['givenDate'] = dateOnly;
      if (brandId != null) {
        updates['brandId'] = brandId;
      }
    } else {
      updates['givenDate'] = null;
    }

    return _updateSchedule(scheduleId, updates);
  }

  static Future<PaPatientSchedule> rescheduleDose(int scheduleId, String planDate) async {
    return _updateSchedule(scheduleId, {'planDate': planDate});
  }
}

