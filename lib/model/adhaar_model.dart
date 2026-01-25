import 'dart:typed_data';

class AdhaarModel {
  final String name;
  final String fatherName;
  final String hindiName;
  final String hindiFatherName;
  final String address;
  final String hindiAddress;
  final String adhaarIssued;
  final String details;
  final String gender;

  final String vid;        // Virtual ID
  final String adhaarId;   // Aadhaar Number
  final String qrId;       // QR Data / QR ID

  final Uint8List? photo;  // image bytes

  AdhaarModel({
    required this.name,
    required this.fatherName,
    required this.hindiName,
    required this.hindiFatherName,
    required this.address,
    required this.hindiAddress,
    required this.adhaarIssued,
    required this.details,
    required this.gender,
    required this.vid,
    required this.adhaarId,
    required this.qrId,
    this.photo,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'fatherName': fatherName,
    'hindiName': hindiName,
    'hindiFatherName': hindiFatherName,
    'address': address,
    'hindiAddress': hindiAddress,
    'adhaarIssued': adhaarIssued,
    'details': details,
    'gender': gender,
    'vid': vid,
    'adhaarId': adhaarId,
    'qrId': qrId,
  };
}
