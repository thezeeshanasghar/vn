import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient_schedule.dart';

class PatientScheduleService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<List<PatientSchedule>> getSchedulesByChild(int childId) async {
    final uri = Uri.parse('$baseUrl/patient-schedules').replace(queryParameters: {
      'childId': childId.toString(),
    });
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final list = (data['data'] as List).cast<dynamic>();
      return list.map((e) => PatientSchedule.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load patient schedules: ${res.statusCode}');
  }

  static Future<PatientSchedule> updateSchedule(
    int scheduleId,
    Map<String, dynamic> updates,
  ) async {
    final uri = Uri.parse('$baseUrl/patient-schedules/$scheduleId');
    final res = await http.put(uri, headers: _headers, body: json.encode(updates));
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return PatientSchedule.fromJson(data['data'] as Map<String, dynamic>);
    }
    // Extract error message from response
    try {
      final errorData = json.decode(res.body) as Map<String, dynamic>;
      final message = errorData['message'] as String? ?? 'Failed to update patient schedule';
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to update patient schedule');
    }
  }

  /// Reschedule a specific patient dose by updating only the planDate
  /// This only affects the patient's schedule, NOT the doctor's schedule
  static Future<PatientSchedule> rescheduleDose(
    int scheduleId,
    String planDate, // Format: YYYY-MM-DD
  ) async {
    return await updateSchedule(scheduleId, {'planDate': planDate});
  }

  /// Toggle IsDone status for a specific patient dose
  /// When setting to true, also sets givenDate to current date (date only, YYYY-MM-DD) if not already set
  /// When setting to false, clears the givenDate
  /// brandId is required when marking as done (isDone = true)
  static Future<PatientSchedule> toggleIsDone(
    int scheduleId,
    bool isDone, {
    int? brandId,
  }) async {
    final updates = <String, dynamic>{'IsDone': isDone};
    
    // If marking as done and givenDate is null, set it to current date (date only)
    if (isDone) {
      final now = DateTime.now();
      final dateOnly = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      updates['givenDate'] = dateOnly;
      
      // BrandId is required when marking as done
      if (brandId != null) {
        updates['brandId'] = brandId;
      }
    } else {
      // If marking as undone, clear the givenDate but keep brandId
      updates['givenDate'] = null;
      // Note: We keep the brandId so inventory can be restored when undoing
    }
    
    return await updateSchedule(scheduleId, updates);
  }

  static Future<void> deleteSchedule(int scheduleId) async {
    final uri = Uri.parse('$baseUrl/patient-schedules/$scheduleId');
    final res = await http.delete(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete patient schedule');
    }
  }
}
