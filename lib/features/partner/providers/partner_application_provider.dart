import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admin/providers/admin_provider.dart';
import '../repositories/partner_repository.dart';

enum ApplicationStatus {
  submitted,
  documentReview,
  preApproved,
  approved,
}

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
  final ApplicationStatus status;
  final String currentStatusText;

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
    this.status = ApplicationStatus.submitted,
    this.currentStatusText = 'ยื่นใบสมัครเรียบร้อยแล้ว อยู่ระหว่างตรวจสอบเอกสาร',
  });

  PartnerApplicationModel copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? address,
    String? vehicleType,
    String? brand,
    String? model,
    String? color,
    String? plate,
    bool? idCardUploaded,
    bool? driverLicenseUploaded,
    bool? vehicleDocUploaded,
    bool? bankBookUploaded,
    int? photosUploadedCount,
    DateTime? submittedAt,
    ApplicationStatus? status,
    String? currentStatusText,
  }) {
    return PartnerApplicationModel(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      plate: plate ?? this.plate,
      idCardUploaded: idCardUploaded ?? this.idCardUploaded,
      driverLicenseUploaded: driverLicenseUploaded ?? this.driverLicenseUploaded,
      vehicleDocUploaded: vehicleDocUploaded ?? this.vehicleDocUploaded,
      bankBookUploaded: bankBookUploaded ?? this.bankBookUploaded,
      photosUploadedCount: photosUploadedCount ?? this.photosUploadedCount,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      currentStatusText: currentStatusText ?? this.currentStatusText,
    );
  }
}

class SystemNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  SystemNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });
}

class PartnerApplicationNotifier extends Notifier<PartnerApplicationModel?> {
  late final PartnerRepository _repository;
  Timer? _statusTimer;

  @override
  PartnerApplicationModel? build() {
    _repository = PartnerRepository();
    return null;
  }

  Future<void> submitApplication(
    PartnerApplicationModel app, {
    File? idCardFile,
    File? driverLicenseFile,
    File? vehicleDocFile,
    File? bankBookFile,
    List<File>? vehiclePhotos,
  }) async {
    state = app.copyWith(
      status: ApplicationStatus.submitted,
      currentStatusText: 'ยื่นใบสมัครเรียบร้อยแล้ว อยู่ระหว่างตรวจสอบเอกสาร',
    );

    // Call backend API repository
    await _repository.submitDriverApplication(
      application: app,
      idCardFile: idCardFile,
      driverLicenseFile: driverLicenseFile,
      vehicleDocFile: vehicleDocFile,
      bankBookFile: bankBookFile,
      vehiclePhotos: vehiclePhotos,
    );

    // Push new driver application to Admin Drivers Provider so Admin can inspect & approve!
    ref.read(adminDriversProvider.notifier).addDriverApplication(
          fullName: app.fullName,
          phone: app.phone,
          email: app.email,
          vehicleType: app.vehicleType,
          brand: app.brand,
          model: app.model,
          color: app.color,
          plate: app.plate,
          submittedAt: app.submittedAt,
        );

    // Cancel existing timer if any
    _statusTimer?.cancel();

    // Periodic status updates (Simulate rounds of status updates)
    _statusTimer = Timer(const Duration(seconds: 15), () {
      if (state != null) {
        state = state!.copyWith(
          status: ApplicationStatus.documentReview,
          currentStatusText: 'ทีมงานกำลังตรวจสอบเอกสารและข้อมูลรถของคุณอย่างละเอียดยิบ',
        );
      }
    });
  }

  void clear() {
    _statusTimer?.cancel();
    state = null;
  }
}

final partnerApplicationProvider =
    NotifierProvider<PartnerApplicationNotifier, PartnerApplicationModel?>(
  PartnerApplicationNotifier.new,
);

