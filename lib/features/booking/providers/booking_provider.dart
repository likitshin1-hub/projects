import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/booking_repository.dart';

// ===== State =====

enum BookingStatus { idle, calculating, ready, submitting, success, error }

class BookingState {
  final BookingStatus status;
  final String pickup;
  final String dropoff;
  final String vehicleType;
  final String details;
  final double estimatedPrice;
  final String? bookingId;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStatus.idle,
    this.pickup = '',
    this.dropoff = '',
    this.vehicleType = 'มอเตอร์ไซค์',
    this.details = '',
    this.estimatedPrice = 0.0,
    this.bookingId,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStatus? status,
    String? pickup,
    String? dropoff,
    String? vehicleType,
    String? details,
    double? estimatedPrice,
    String? bookingId,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      vehicleType: vehicleType ?? this.vehicleType,
      details: details ?? this.details,
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
    String? dropoff,
    String? vehicleType,
    String? details,
  }) {
    state = state.copyWith(
      pickup: pickup,
      dropoff: dropoff,
      vehicleType: vehicleType,
      details: details,
      status: BookingStatus.idle,
    );

    // Calculate price automatically if both pickup and dropoff are filled
    if (state.pickup.isNotEmpty && state.dropoff.isNotEmpty) {
      _calculatePrice();
    }
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
