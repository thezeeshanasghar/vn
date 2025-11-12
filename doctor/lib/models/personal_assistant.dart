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

  Map<String, dynamic> toJson() {
    return {
      'allowPatients': allowPatients,
      'allowSchedules': allowSchedules,
      'allowInventory': allowInventory,
      'allowAlerts': allowAlerts,
      'allowBilling': allowBilling,
    };
  }

  PaPermissions copyWith({
    bool? allowPatients,
    bool? allowSchedules,
    bool? allowInventory,
    bool? allowAlerts,
    bool? allowBilling,
  }) {
    return PaPermissions(
      allowPatients: allowPatients ?? this.allowPatients,
      allowSchedules: allowSchedules ?? this.allowSchedules,
      allowInventory: allowInventory ?? this.allowInventory,
      allowAlerts: allowAlerts ?? this.allowAlerts,
      allowBilling: allowBilling ?? this.allowBilling,
    );
  }
}

class PaClinicAccess {
  final int? paAccessId;
  final int clinicId;
  final String? clinicName;
  final bool allowPatients;
  final bool allowSchedules;
  final bool allowInventory;
  final bool allowAlerts;
  final bool allowBilling;

  const PaClinicAccess({
    this.paAccessId,
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
      paAccessId: (json['paAccessId'] as num?)?.toInt(),
      clinicId: (json['clinicId'] as num).toInt(),
      clinicName: json['clinicName'] as String?,
      allowPatients: json['allowPatients'] as bool? ?? false,
      allowSchedules: json['allowSchedules'] as bool? ?? false,
      allowInventory: json['allowInventory'] as bool? ?? false,
      allowAlerts: json['allowAlerts'] as bool? ?? false,
      allowBilling: json['allowBilling'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paAccessId': paAccessId,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'allowPatients': allowPatients,
      'allowSchedules': allowSchedules,
      'allowInventory': allowInventory,
      'allowAlerts': allowAlerts,
      'allowBilling': allowBilling,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'clinicId': clinicId,
      'allowPatients': allowPatients,
      'allowSchedules': allowSchedules,
      'allowInventory': allowInventory,
      'allowAlerts': allowAlerts,
      'allowBilling': allowBilling,
    };
  }

  PaClinicAccess copyWith({
    int? paAccessId,
    int? clinicId,
    String? clinicName,
    bool? allowPatients,
    bool? allowSchedules,
    bool? allowInventory,
    bool? allowAlerts,
    bool? allowBilling,
  }) {
    return PaClinicAccess(
      paAccessId: paAccessId ?? this.paAccessId,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      allowPatients: allowPatients ?? this.allowPatients,
      allowSchedules: allowSchedules ?? this.allowSchedules,
      allowInventory: allowInventory ?? this.allowInventory,
      allowAlerts: allowAlerts ?? this.allowAlerts,
      allowBilling: allowBilling ?? this.allowBilling,
    );
  }
}

class PersonalAssistant {
  final String? id;
  final int? paId;
  final int doctorId;
  final String firstName;
  final String lastName;
  final String email;
  final String? mobileNumber;
  final bool isActive;
  final PaPermissions permissions;
  final List<PaClinicAccess> clinicAccess;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PersonalAssistant({
    this.id,
    this.paId,
    required this.doctorId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.mobileNumber,
    this.isActive = true,
    this.permissions = const PaPermissions(),
    this.clinicAccess = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory PersonalAssistant.fromJson(Map<String, dynamic> json) {
    return PersonalAssistant(
      id: json['_id'] as String?,
      paId: (json['paId'] as num?)?.toInt(),
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
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  PersonalAssistant copyWith({
    String? id,
    int? paId,
    int? doctorId,
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNumber,
    bool? isActive,
    PaPermissions? permissions,
    List<PaClinicAccess>? clinicAccess,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonalAssistant(
      id: id ?? this.id,
      paId: paId ?? this.paId,
      doctorId: doctorId ?? this.doctorId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
      clinicAccess: clinicAccess ?? this.clinicAccess,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toCreatePayload({
    required String password,
    PaPermissions? permissions,
    List<PaClinicAccess>? clinicAccess,
  }) {
    return {
      'doctorId': doctorId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobileNumber': mobileNumber ?? '',
      'password': password,
      'permissions': (permissions ?? this.permissions).toJson(),
      'clinicAccess': (clinicAccess ?? this.clinicAccess)
          .map((access) => access.toUpdatePayload())
          .toList(),
    };
  }
}

