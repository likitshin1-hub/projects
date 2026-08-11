import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class PartnerService {
  final DioClient _dioClient;

  PartnerService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// ส่งข้อมูลสมัครพาร์ทเนอร์ไปยัง Backend (POST /api/partner/apply)
  Future<Response> applyPartner({
    required String nationalId,
    required String licenseNumber,
    required String vehicleType,
    required String brand,
    required String model,
    required String color,
    required String licensePlate,
    MultipartFile? idCardFile,
    MultipartFile? driverLicenseFile,
    MultipartFile? vehicleRegFile,
  }) async {
    final formDataMap = <String, dynamic>{
      'national_id': nationalId,
      'license_number': licenseNumber,
      'vehicle_type': vehicleType,
      'brand': brand,
      'model': model,
      'color': color,
      'license_plate': licensePlate,
    };

    if (idCardFile != null) {
      formDataMap['id_card'] = idCardFile;
    }
    if (driverLicenseFile != null) {
      formDataMap['driver_license'] = driverLicenseFile;
    }
    if (vehicleRegFile != null) {
      formDataMap['vehicle_registration'] = vehicleRegFile;
    }

    final formData = FormData.fromMap(formDataMap);

    return _dioClient.post(
      '/partner/apply',
      data: formData,
    );
  }

  /// ดึงสถานะอนุมัติพาร์ทเนอร์ (GET /api/partner/status)
  Future<Response> getPartnerStatus() {
    return _dioClient.get('/partner/status');
  }
}
