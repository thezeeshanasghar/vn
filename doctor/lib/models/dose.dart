class Dose {
  final String? id;
  final int? doseId;
  final String? name;
  final int minAge;
  final int maxAge;
  final int minGap;
  final String? vaccineID;
  final VaccineInfo? vaccine;

  Dose({
    this.id,
    this.doseId,
    this.name,
    required this.minAge,
    required this.maxAge,
    this.minGap = 0,
    this.vaccineID,
    this.vaccine,
  });

  factory Dose.fromJson(Map<String, dynamic> json) {
    return Dose(
      id: json['_id'] as String?,
      doseId: (json['doseId'] as num?)?.toInt(),
      name: json['name'] as String?,
      minAge: ((json['minAge'] as num?) ?? 0).toInt(),
      maxAge: ((json['maxAge'] as num?) ?? 0).toInt(),
      minGap: (json['minGap'] as num?)?.toInt() ?? 0,
      vaccineID: json['vaccineID'] == null
          ? null
          : json['vaccineID'] is String
              ? json['vaccineID'] as String?
              : (json['vaccineID'] as Map<String, dynamic>?)?['_id'] as String?,
      vaccine: json['vaccineID'] != null && json['vaccineID'] is Map
          ? VaccineInfo.fromJson(json['vaccineID'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (doseId != null) 'doseId': doseId,
        if (name != null) 'name': name,
        'minAge': minAge,
        'maxAge': maxAge,
        'minGap': minGap,
        if (vaccineID != null) 'vaccineID': vaccineID,
      };
}

class VaccineInfo {
  final String? id;
  final String? name;
  final int? vaccineID;

  VaccineInfo({
    this.id,
    this.name,
    this.vaccineID,
  });

  factory VaccineInfo.fromJson(Map<String, dynamic> json) {
    return VaccineInfo(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      vaccineID: (json['vaccineID'] as num?)?.toInt(),
    );
  }
}
