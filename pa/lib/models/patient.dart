class PaEmergencyContact {
  final String? name;
  final String? relation;
  final String? phone;

  const PaEmergencyContact({this.name, this.relation, this.phone});

  factory PaEmergencyContact.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PaEmergencyContact();
    return PaEmergencyContact(
      name: json['name'] as String?,
      relation: json['relation'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (name != null && name!.isNotEmpty) 'name': name,
        if (relation != null && relation!.isNotEmpty) 'relation': relation,
        if (phone != null && phone!.isNotEmpty) 'phone': phone,
      };
}

class PaPatient {
  final String? id;
  final int? patientId;
  final String name;
  final String? fatherName;
  final String gender;
  final DateTime dateOfBirth;
  final String? email;
  final String? cnic;
  final String? mobileNumber;
  final String? city;
  final String? address;
  final PaEmergencyContact? emergencyContact;
  final String? medicalHistory;
  final String? allergies;
  final String? bloodGroup;
  final int clinicId;
  final int doctorId;
  final bool isActive;

  const PaPatient({
    this.id,
    this.patientId,
    required this.name,
    this.fatherName,
    required this.gender,
    required this.dateOfBirth,
    this.email,
    this.cnic,
    this.mobileNumber,
    this.city,
    this.address,
    this.emergencyContact,
    this.medicalHistory,
    this.allergies,
    this.bloodGroup,
    required this.clinicId,
    required this.doctorId,
    this.isActive = true,
  });

  factory PaPatient.fromJson(Map<String, dynamic> json) {
    return PaPatient(
      id: json['_id'] as String?,
      patientId: (json['patientId'] as num?)?.toInt(),
      name: json['name'] as String? ?? '',
      fatherName: json['fatherName'] as String?,
      gender: json['gender'] as String? ?? 'Male',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : DateTime.now(),
      email: json['email'] as String?,
      cnic: json['cnic'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      emergencyContact:
          PaEmergencyContact.fromJson(json['emergencyContact'] as Map<String, dynamic>?),
      medicalHistory: json['medicalHistory'] as String?,
      allergies: json['allergies'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      clinicId: (json['clinicId'] as num).toInt(),
      doctorId: (json['doctorId'] as num).toInt(),
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        if (patientId != null) 'patientId': patientId,
        'name': name,
        if (fatherName != null && fatherName!.isNotEmpty) 'fatherName': fatherName,
        'gender': gender,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        if (email != null && email!.isNotEmpty) 'email': email,
        if (cnic != null && cnic!.isNotEmpty) 'cnic': cnic,
        if (mobileNumber != null && mobileNumber!.isNotEmpty) 'mobileNumber': mobileNumber,
        if (city != null && city!.isNotEmpty) 'city': city,
        if (address != null && address!.isNotEmpty) 'address': address,
        if (emergencyContact != null) 'emergencyContact': emergencyContact!.toJson(),
        if (medicalHistory != null && medicalHistory!.isNotEmpty)
          'medicalHistory': medicalHistory,
        if (allergies != null && allergies!.isNotEmpty) 'allergies': allergies,
        if (bloodGroup != null && bloodGroup!.isNotEmpty) 'bloodGroup': bloodGroup,
        'clinicId': clinicId,
        'doctorId': doctorId,
        'isActive': isActive,
      };

  String get displayName => name.isNotEmpty ? name : 'Patient';
}

