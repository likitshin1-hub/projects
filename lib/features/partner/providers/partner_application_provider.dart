import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartnerApplicationModel {
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final String vehicleType;
  final String brand;
  final String model;
  final String color;
  final String plate;
  final bool idCardUploaded;
  final bool driverLicenseUploaded;
  final bool vehicleDocUploaded;
  final bool bankBookUploaded;
  final int photosUploadedCount;
  final DateTime submittedAt;

  const PartnerApplicationModel({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.address,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.color,
    required this.plate,
    required this.idCardUploaded,
    required this.driverLicenseUploaded,
    required this.vehicleDocUploaded,
    required this.bankBookUploaded,
    required this.photosUploadedCount,
    required this.submittedAt,
  });
}

class PartnerApplicationNotifier extends StateNotifier<PartnerApplicationModel?> {
  PartnerApplicationNotifier() : super(null);

  void submitApplication(PartnerApplicationModel app) {
    state = app;
  }

  void clearApplication() {
    state = null;
  }
}

final partnerApplicationProvider =
    StateNotifierProvider<PartnerApplicationNotifier, PartnerApplicationModel?>(
  (ref) => PartnerApplicationNotifier(),
);
