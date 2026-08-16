import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class PartnerService {
  final DioClient _dioClient;

  PartnerService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// ส่งใบสมัครคนขับพร้อมอัปโหลดไฟล์เอกสารแบบ Multipart (POST /api/driver/register)
  Future<Response> registerDriver({
    required Map<String, dynamic> fields,
    File? idCardFile,
    File? driverLicenseFile,
    File? vehicleDocFile,
    File? bankBookFile,
    List<File>? vehiclePhotos,
  }) async {
    final Map<String, dynamic> formDataMap = Map.from(fields);

    if (idCardFile != null && await idCardFile.exists()) {
      formDataMap['id_card_image'] = await MultipartFile.fromFile(
        idCardFile.path,
        filename: 'id_card_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    if (driverLicenseFile != null && await driverLicenseFile.exists()) {
      formDataMap['driver_license_image'] = await MultipartFile.fromFile(
        driverLicenseFile.path,
        filename: 'driver_license_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    if (vehicleDocFile != null && await vehicleDocFile.exists()) {
      formDataMap['vehicle_doc_image'] = await MultipartFile.fromFile(
        vehicleDocFile.path,
        filename: 'vehicle_doc_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    if (bankBookFile != null && await bankBookFile.exists()) {
      formDataMap['bank_book_image'] = await MultipartFile.fromFile(
        bankBookFile.path,
        filename: 'bank_book_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    if (vehiclePhotos != null && vehiclePhotos.isNotEmpty) {
      final List<MultipartFile> photoFiles = [];
      for (int i = 0; i < vehiclePhotos.length; i++) {
        final photo = vehiclePhotos[i];
        if (await photo.exists()) {
          photoFiles.add(
            await MultipartFile.fromFile(
              photo.path,
              filename: 'vehicle_photo_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          );
        }
      }
      if (photoFiles.isNotEmpty) {
        formDataMap['vehicle_photos[]'] = photoFiles;
      }
    }

    final FormData formData = FormData.fromMap(formDataMap);

    return _dioClient.post(
      '/driver/register',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  /// ตรวจสอบสถานะใบสมัคร (GET /api/driver/application-status)
  Future<Response> getApplicationStatus() {
    return _dioClient.get('/driver/application-status');
  }
}
