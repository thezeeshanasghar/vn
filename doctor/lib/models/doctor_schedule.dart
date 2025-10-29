class DoctorSchedule {
  final String? id;
  final int? scheduleId;
  final int doctorId;
  final int doseId;
  final String? planDate;
  final bool isActive;
  final DoseInfo? dose;

  DoctorSchedule({
    this.id,
    this.scheduleId,
    required this.doctorId,
    required this.doseId,
    this.planDate,
    this.isActive = true,
    this.dose,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorSchedule(
      id: json['_id'] as String?,
      scheduleId: (json['scheduleId'] as num?)?.toInt(),
      doctorId: (json['doctorId'] as num).toInt(),
      doseId: (json['doseId'] as num).toInt(),
      planDate: json['planDate'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
      dose: json['dose'] != null
          ? DoseInfo.fromJson(json['dose'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (scheduleId != null) 'scheduleId': scheduleId,
        'doctorId': doctorId,
        'doseId': doseId,
        if (planDate != null) 'planDate': planDate,
        'isActive': isActive,
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
