class PatientSchedule {
  final String? id;
  final int? scheduleId;
  final int childId;
  final int doseId;
  final String? planDate;
  final DateTime? givenDate;
  final int? brandId;
  final bool IsDone;
  final DoseInfo? dose;

  PatientSchedule({
    this.id,
    this.scheduleId,
    required this.childId,
    required this.doseId,
    this.planDate,
    this.givenDate,
    this.brandId,
    this.IsDone = false,
    this.dose,
  });

  static DateTime? _parseDateString(dynamic dateValue) {
    if (dateValue == null) return null;
    
    try {
      if (dateValue is String) {
        final dateStr = dateValue.trim();
        if (dateStr.isEmpty) return null;
        
        // If it's already in YYYY-MM-DD format, parse it with time
        if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
          return DateTime.tryParse('${dateStr}T00:00:00');
        }
        
        // If it contains 'T', try parsing as ISO format
        if (dateStr.contains('T')) {
          return DateTime.tryParse(dateStr);
        }
        
        // Try parsing as is
        final parsed = DateTime.tryParse(dateStr);
        if (parsed != null) return parsed;
        
        // Try adding time and parsing
        return DateTime.tryParse('${dateStr}T00:00:00');
      } else {
        // Try converting to string and parsing
        return DateTime.tryParse(dateValue.toString());
      }
    } catch (e) {
      return null;
    }
  }

  factory PatientSchedule.fromJson(Map<String, dynamic> json) {
    return PatientSchedule(
      id: json['_id'] as String?,
      scheduleId: (json['scheduleId'] as num?)?.toInt(),
      childId: (json['childId'] as num).toInt(),
      doseId: (json['doseId'] as num).toInt(),
      planDate: json['planDate'] as String?,
      givenDate: _parseDateString(json['givenDate']),
      brandId: (json['brandId'] as num?)?.toInt(),
      IsDone: (json['IsDone'] as bool?) ?? false,
      dose: json['dose'] != null
          ? DoseInfo.fromJson(json['dose'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (scheduleId != null) 'scheduleId': scheduleId,
        'childId': childId,
        'doseId': doseId,
        if (planDate != null) 'planDate': planDate,
        if (givenDate != null) 'givenDate': givenDate!.toIso8601String(),
        if (brandId != null) 'brandId': brandId,
        'IsDone': IsDone,
      };
}

class DoseInfo {
  final int? doseId;
  final String? name;
  final int? minAge;
  final int? maxAge;
  final int? minGap;
  final String? vaccineID;

  DoseInfo({
    this.doseId,
    this.name,
    this.minAge,
    this.maxAge,
    this.minGap,
    this.vaccineID,
  });

  factory DoseInfo.fromJson(Map<String, dynamic> json) {
    return DoseInfo(
      doseId: (json['doseId'] as num?)?.toInt(),
      name: json['name'] as String?,
      minAge: (json['minAge'] as num?)?.toInt(),
      maxAge: (json['maxAge'] as num?)?.toInt(),
      minGap: (json['minGap'] as num?)?.toInt(),
      vaccineID: json['vaccineID'] as String?,
    );
  }
}
