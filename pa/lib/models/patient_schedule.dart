class PaPatientSchedule {
  final String? id;
  final int? scheduleId;
  final int childId;
  final int doseId;
  final String? planDate;
  final DateTime? givenDate;
  final int? brandId;
  final bool isDone;
  final PaDoseInfo? dose;
  final PaBrandInfo? brand;

  PaPatientSchedule({
    this.id,
    this.scheduleId,
    required this.childId,
    required this.doseId,
    this.planDate,
    this.givenDate,
    this.brandId,
    this.isDone = false,
    this.dose,
    this.brand,
  });

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      if (value is DateTime) return value;
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return null;
        if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(trimmed)) {
          return DateTime.tryParse('${trimmed}T00:00:00');
        }
        return DateTime.tryParse(trimmed);
      }
      return DateTime.tryParse(value.toString());
    } catch (_) {
      return null;
    }
  }

  factory PaPatientSchedule.fromJson(Map<String, dynamic> json) {
    return PaPatientSchedule(
      id: json['_id'] as String?,
      scheduleId: (json['scheduleId'] as num?)?.toInt(),
      childId: (json['childId'] as num).toInt(),
      doseId: (json['doseId'] as num).toInt(),
      planDate: json['planDate'] as String?,
      givenDate: _parseDate(json['givenDate']),
      brandId: (json['brandId'] as num?)?.toInt(),
      isDone: (json['IsDone'] as bool?) ?? false,
      dose: json['dose'] != null
          ? PaDoseInfo.fromJson(json['dose'] as Map<String, dynamic>)
          : null,
      brand: json['brand'] != null
          ? PaBrandInfo.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PaDoseInfo {
  final int? doseId;
  final String? name;
  final int? minAge;
  final int? maxAge;
  final int? minGap;
  final String? vaccineId;

  PaDoseInfo({
    this.doseId,
    this.name,
    this.minAge,
    this.maxAge,
    this.minGap,
    this.vaccineId,
  });

  factory PaDoseInfo.fromJson(Map<String, dynamic> json) {
    return PaDoseInfo(
      doseId: (json['doseId'] as num?)?.toInt(),
      name: json['name'] as String?,
      minAge: (json['minAge'] as num?)?.toInt(),
      maxAge: (json['maxAge'] as num?)?.toInt(),
      minGap: (json['minGap'] as num?)?.toInt(),
      vaccineId: json['vaccineID'] as String?,
    );
  }
}

class PaBrandInfo {
  final int? brandId;
  final String? name;
  final double? amount;

  PaBrandInfo({
    this.brandId,
    this.name,
    this.amount,
  });

  factory PaBrandInfo.fromJson(Map<String, dynamic> json) {
    return PaBrandInfo(
      brandId: (json['brandId'] as num?)?.toInt(),
      name: json['name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }
}

