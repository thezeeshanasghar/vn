import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import 'patient_service.dart';
import 'patient_schedule_service.dart';

class DashboardService {
  // Get total patient count for a doctor
  static Future<int> getTotalPatients(int doctorId) async {
    try {
      final counts = await PatientService.getPatientCountsByClinic(doctorId);
      int total = 0;
      for (final count in counts.values) {
        total += count;
      }
      return total;
    } catch (e) {
      print('Error getting total patients: $e');
      return 0;
    }
  }

  // Get all schedules for all patients of a doctor
  static Future<List<dynamic>> _getAllSchedulesForDoctor(int doctorId) async {
    try {
      // Get all patients for this doctor
      final patients = await PatientService.getPatients(doctorId: doctorId);
      
      // Get schedules for all patients
      final allSchedules = <dynamic>[];
      for (final patient in patients) {
        if (patient.patientId == null) continue;
        try {
          final schedules = await PatientScheduleService.getSchedulesByChild(patient.patientId!);
          allSchedules.addAll(schedules);
        } catch (e) {
          print('Error getting schedules for patient ${patient.patientId}: $e');
          // Continue with other patients
        }
      }
      
      return allSchedules;
    } catch (e) {
      print('Error getting all schedules: $e');
      return [];
    }
  }

  // Get total schedules for a doctor
  static Future<int> getTotalSchedules(int doctorId) async {
    try {
      final schedules = await _getAllSchedulesForDoctor(doctorId);
      return schedules.length;
    } catch (e) {
      print('Error getting total schedules: $e');
      return 0;
    }
  }

  // Get completed schedules (IsDone = true) for a doctor
  static Future<int> getCompletedSchedules(int doctorId) async {
    try {
      final schedules = await _getAllSchedulesForDoctor(doctorId);
      return schedules.where((s) => s.IsDone == true).length;
    } catch (e) {
      print('Error getting completed schedules: $e');
      return 0;
    }
  }

  // Get pending schedules (IsDone = false) for a doctor
  static Future<int> getPendingSchedules(int doctorId) async {
    try {
      final schedules = await _getAllSchedulesForDoctor(doctorId);
      return schedules.where((s) => s.IsDone != true).length;
    } catch (e) {
      print('Error getting pending schedules: $e');
      return 0;
    }
  }

  // Get today's schedules count
  static Future<int> getTodaySchedules(int doctorId) async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final schedules = await _getAllSchedulesForDoctor(doctorId);
      return schedules.where((s) {
        if (s.planDate == null) return false;
        // Extract date part from planDate (format: YYYY-MM-DD or YYYY-MM-DD HH:mm:ss)
        final planDateStr = s.planDate.toString().split(' ')[0];
        return planDateStr == todayStr;
      }).length;
    } catch (e) {
      print('Error getting today schedules: $e');
      return 0;
    }
  }

  // Get all dashboard stats
  static Future<Map<String, int>> getDashboardStats(int doctorId) async {
    try {
      final results = await Future.wait([
        getTotalPatients(doctorId),
        getTotalSchedules(doctorId),
        getCompletedSchedules(doctorId),
        getPendingSchedules(doctorId),
        getTodaySchedules(doctorId),
      ]);

      return {
        'totalPatients': results[0],
        'totalSchedules': results[1],
        'completedSchedules': results[2],
        'pendingSchedules': results[3],
        'todaySchedules': results[4],
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'totalPatients': 0,
        'totalSchedules': 0,
        'completedSchedules': 0,
        'pendingSchedules': 0,
        'todaySchedules': 0,
      };
    }
  }
}

