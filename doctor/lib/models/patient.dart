class EmergencyContact {
  final String? name;
  final String? relation;
  final String? phone;

  EmergencyContact({this.name, this.relation, this.phone});

  factory EmergencyContact.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EmergencyContact();
    return EmergencyContact(
      name: json['name'] as String?,
      relation: json['relation'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (relation != null) 'relation': relation,
        if (phone != null) 'phone': phone,
      };
}

class Patient {
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
  final EmergencyContact? emergencyContact;
  final String? medicalHistory;
  final String? allergies;
  final String? bloodGroup;
  final int clinicId;
  final int doctorId;
  final bool isActive;

  Patient({
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

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id'] as String?,
      patientId: (json['patientId'] as num?)?.toInt(),
      name: (json['name'] ?? '') as String,
      fatherName: json['fatherName'] as String?,
      gender: (json['gender'] ?? 'Male') as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      email: json['email'] as String?,
      cnic: json['cnic'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      emergencyContact: EmergencyContact.fromJson(json['emergencyContact'] as Map<String, dynamic>?),
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
        if (fatherName != null) 'fatherName': fatherName,
        'gender': gender,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        if (email != null) 'email': email,
        if (cnic != null) 'cnic': cnic,
        if (mobileNumber != null) 'mobileNumber': mobileNumber,
        if (city != null) 'city': city,
        if (address != null) 'address': address,
        if (emergencyContact != null) 'emergencyContact': emergencyContact!.toJson(),
        if (medicalHistory != null) 'medicalHistory': medicalHistory,
        if (allergies != null) 'allergies': allergies,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        'clinicId': clinicId,
        'doctorId': doctorId,
        'isActive': isActive,
      };
}


