class PaPermissions {
  final bool allowPatients;
  final bool allowSchedules;
  final bool allowInventory;
  final bool allowAlerts;
  final bool allowBilling;

  const PaPermissions({
    this.allowPatients = false,
    this.allowSchedules = false,
    this.allowInventory = false,
    this.allowAlerts = false,
    this.allowBilling = false,
  });

  factory PaPermissions.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaPermissions();
    }
    return PaPermissions(
      allowPatients: json['allowPatients'] as bool? ?? false,
      allowSchedules: json['allowSchedules'] as bool? ?? false,
      allowInventory: json['allowInventory'] as bool? ?? false,
      allowAlerts: json['allowAlerts'] as bool? ?? false,
      allowBilling: json['allowBilling'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'allowPatients': allowPatients,
        'allowSchedules': allowSchedules,
        'allowInventory': allowInventory,
        'allowAlerts': allowAlerts,
        'allowBilling': allowBilling,
      };
}

class PaClinicAccess {
  final int clinicId;
  final String? clinicName;
  final bool allowPatients;
  final bool allowSchedules;
  final bool allowInventory;
  final bool allowAlerts;
  final bool allowBilling;

  const PaClinicAccess({
    required this.clinicId,
    this.clinicName,
    this.allowPatients = false,
    this.allowSchedules = false,
    this.allowInventory = false,
    this.allowAlerts = false,
    this.allowBilling = false,
  });

  factory PaClinicAccess.fromJson(Map<String, dynamic> json) {
    return PaClinicAccess(
      clinicId: (json['clinicId'] as num).toInt(),
      clinicName: json['clinicName'] as String?,
      allowPatients: json['allowPatients'] as bool? ?? false,
      allowSchedules: json['allowSchedules'] as bool? ?? false,
      allowInventory: json['allowInventory'] as bool? ?? false,
      allowAlerts: json['allowAlerts'] as bool? ?? false,
      allowBilling: json['allowBilling'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'clinicId': clinicId,
        'clinicName': clinicName,
        'allowPatients': allowPatients,
        'allowSchedules': allowSchedules,
        'allowInventory': allowInventory,
        'allowAlerts': allowAlerts,
        'allowBilling': allowBilling,
      };
}

class PaAssistant {
  final int paId;
  final int doctorId;
  final String firstName;
  final String lastName;
  final String email;
  final String? mobileNumber;
  final bool isActive;
  final PaPermissions permissions;
  final List<PaClinicAccess> clinicAccess;

  const PaAssistant({
    required this.paId,
    required this.doctorId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.mobileNumber,
    this.isActive = true,
    this.permissions = const PaPermissions(),
    this.clinicAccess = const [],
  });

  factory PaAssistant.fromJson(Map<String, dynamic> json) {
    return PaAssistant(
      paId: (json['paId'] as num).toInt(),
      doctorId: (json['doctorId'] as num).toInt(),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      permissions: PaPermissions.fromJson(json['permissions'] as Map<String, dynamic>?),
      clinicAccess: ((json['clinicAccess'] as List?) ?? [])
          .map((item) => PaClinicAccess.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  Map<String, dynamic> toJson() => {
        'paId': paId,
        'doctorId': doctorId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'mobileNumber': mobileNumber,
        'isActive': isActive,
        'permissions': permissions.toJson(),
        'clinicAccess': clinicAccess.map((e) => e.toJson()).toList(),
      };
}

