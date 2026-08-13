import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/booking_repository.dart';

// ===== State =====

enum BookingStatus { idle, calculating, ready, submitting, success, error }

class BookingState {
  final BookingStatus status;
  final String pickup;
  final String pickupName;
  final double pickupLat;
  final double pickupLng;
  final String dropoff;
  final String dropoffName;
  final double dropoffLat;
  final double dropoffLng;
  final String receiverPhone;
  final String vehicleType;
  final String parcelType;
  final int parcelWeight;
  final String details;
  final double distanceKm;
  final int estimatedDurationMinutes;
  final double estimatedPrice;
  final String? bookingId;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStatus.idle,
    this.pickup = '123 อาคาร ชั้น 5 ถนนสุขุมวิท กรุงเทพมหานคร',
    this.pickupName = 'บริษัท เอ็นเทค จำกัด',
    this.pickupLat = 13.7466,
    this.pickupLng = 100.5393,
    this.dropoff = '88/9 หมู่ 3 ตำบลแม่เหียะ อำเภอเมืองเชียงใหม่ จังหวัดเชียงใหม่',
    this.dropoffName = 'คุณสมชาย ใจดี',
    this.dropoffLat = 18.7883,
    this.dropoffLng = 98.9853,
    this.receiverPhone = '081-234-5678',
    this.vehicleType = 'มอเตอร์ไซค์',
    this.parcelType = 'กล่อง',
    this.parcelWeight = 2,
    this.details = 'เครื่องใช้ไฟฟ้า',
    this.distanceKm = 82.5,
    this.estimatedDurationMinutes = 45,
    this.estimatedPrice = 120.0,
    this.bookingId,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStatus? status,
    String? pickup,
    String? pickupName,
    double? pickupLat,
    double? pickupLng,
    String? dropoff,
    String? dropoffName,
    double? dropoffLat,
    double? dropoffLng,
    String? receiverPhone,
    String? vehicleType,
    String? parcelType,
    int? parcelWeight,
    String? details,
    double? distanceKm,
    int? estimatedDurationMinutes,
    double? estimatedPrice,
    String? bookingId,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      pickup: pickup ?? this.pickup,
      pickupName: pickupName ?? this.pickupName,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoff: dropoff ?? this.dropoff,
      dropoffName: dropoffName ?? this.dropoffName,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      vehicleType: vehicleType ?? this.vehicleType,
      parcelType: parcelType ?? this.parcelType,
      parcelWeight: parcelWeight ?? this.parcelWeight,
      details: details ?? this.details,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      bookingId: bookingId ?? this.bookingId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ===== Notifier (Riverpod 3.x) =====

class BookingNotifier extends Notifier<BookingState> {
  late final BookingRepository _repository;

  @override
  BookingState build() {
    _repository = BookingRepository();
    return const BookingState();
  }

  void updateForm({
    String? pickup,
    String? pickupName,
    double? pickupLat,
    double? pickupLng,
    String? dropoff,
    String? dropoffName,
    double? dropoffLat,
    double? dropoffLng,
    String? receiverPhone,
    String? vehicleType,
    String? parcelType,
    int? parcelWeight,
    String? details,
    double? distanceKm,
    int? estimatedDurationMinutes,
    double? estimatedPrice,
  }) {
    state = state.copyWith(
      pickup: pickup,
      pickupName: pickupName,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoff: dropoff,
      dropoffName: dropoffName,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      receiverPhone: receiverPhone,
      vehicleType: vehicleType,
      parcelType: parcelType,
      parcelWeight: parcelWeight,
      details: details,
      distanceKm: distanceKm,
      estimatedDurationMinutes: estimatedDurationMinutes,
      estimatedPrice: estimatedPrice,
      status: BookingStatus.idle,
    );
  }

  Future<void> _calculatePrice() async {
    state = state.copyWith(status: BookingStatus.calculating);
    try {
      final price = await _repository.calculatePrice(
        pickup: state.pickup,
        dropoff: state.dropoff,
        vehicleType: state.vehicleType,
      );
      state = state.copyWith(
        status: BookingStatus.ready,
        estimatedPrice: price,
      );
    } catch (e) {
      state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: 'คำนวณราคาล้มเหลว',
      );
    }
  }

  Future<bool> submitBooking() async {
    if (state.pickup.isEmpty || state.dropoff.isEmpty) {
      state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: 'กรุณาระบุจุดรับและจุดส่ง',
      );
      return false;
    }

    state = state.copyWith(status: BookingStatus.submitting);
    try {
      final bId = await _repository.submitBooking(
        pickup: state.pickup,
        dropoff: state.dropoff,
        vehicleType: state.vehicleType,
        details: state.details,
        price: state.estimatedPrice,
      );
      state = state.copyWith(status: BookingStatus.success, bookingId: bId);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: 'การจองล้มเหลว กรุณาลองใหม่',
      );
      return false;
    }
  }

  void reset() {
    state = const BookingState();
  }
}

// ===== Provider =====

final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(() {
  return BookingNotifier();
});
