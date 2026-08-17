import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DriverModel {
  final String name;
  final String phone;
  final double rating;
  final int reviewCount;
  final String vehicleType;
  final String vehicleModel;
  final String vehicleColor;
  final String licensePlate;
  final Color avatarBgColor;
  final IconData avatarIcon;

  const DriverModel({
    required this.name,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.licensePlate,
    required this.avatarBgColor,
    required this.avatarIcon,
  });

  String get fullVehicleInfo => '$vehicleModel $vehicleColor (ทะเบียน $licensePlate)';
}

class DriverNotifier extends Notifier<DriverModel> {
  static final _random = Random();

  static final List<String> _names = [
    'นาย สมปอง มีดี',
    'นาย สมชาย มั่นคง',
    'นาย กิตติศักดิ์ ชัยชนะ',
    'นาย วิชัย สายฟ้า',
    'นาย อนันต์ เจริญสุข',
    'นาย ธีระพงษ์ วงศ์สว่าง',
    'นาย อนุรักษ์ มิ่งขวัญ',
    'นาย ณัฐพงษ์ สุขเจริญ',
    'นาย ธนพล มั่งคั่ง',
  ];

  static final List<String> _phones = [
    '081-234-5678',
    '089-876-5432',
    '086-555-4444',
    '082-111-9999',
    '083-444-5555',
    '085-777-6666',
  ];

  static final List<Color> _avatarColors = [
    const Color(0xFF1C7FF6),
    const Color(0xFF10B981),
    const Color(0xFF6366F1),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
  ];

  // Motorcycle Pool
  static final List<String> _motoModels = [
    'Honda Wave 125i',
    'Yamaha Grand Filano',
    'Honda Click 160',
    'Yamaha NMAX 155',
    'Vespa GTS 150',
  ];
  static final List<String> _motoColors = ['สีฟ้า', 'สีดำเงา', 'สีขาวมุก', 'สีแดงสปอร์ต', 'สีเทาแรมโบ'];
  static final List<String> _motoPlates = ['1กข-9999 ชลบุรี', '2กท-8812 กรุงเทพฯ', '3ขค-4510 สมุทรปราการ', '1กง-7722 นนทบุรี'];

  // Car Pool
  static final List<String> _carModels = [
    'Toyota Camry 2.5',
    'Honda Civic RS',
    'Mazda 3 Sedan',
    'Nissan Almera',
    'Honda City Hatchback',
  ];
  static final List<String> _carColors = ['สีบรอนซ์เงิน', 'สีดำคริสตัล', 'สีขาวออร์คิด', 'สีเทาดำ', 'สีน้ำเงินเข้ม'];
  static final List<String> _carPlates = ['กท-5544 กรุงเทพฯ', 'ขก-3321 ชลบุรี', 'งน-1199 สมุทรปราการ'];

  // Truck / Pickup Pool
  static final List<String> _truckModels = [
    'Isuzu D-Max ตู้ทึบ',
    'Toyota Hilux Revo หลังคาสูง',
    'Ford Ranger XL',
    'Mitsubishi Triton',
  ];
  static final List<String> _truckColors = ['สีขาวตู้ทึบ', 'สีบรอนซ์เงิน', 'สีดำแม็กซ์', 'สีเทาแลมโบ'];
  static final List<String> _truckPlates = ['1กข-9999 ชลบุรี', '3ผก-2211 กรุงเทพฯ', '2ตท-4455 สมุทรปราการ'];

  @override
  DriverModel build() {
    return generateRandomDriver('มอเตอร์ไซค์');
  }

  DriverModel generateRandomDriver(String vehicleTypeInput) {
    final name = _names[_random.nextInt(_names.length)];
    final phone = _phones[_random.nextInt(_phones.length)];
    final rating = 4.7 + (_random.nextInt(4) * 0.1); // 4.7, 4.8, 4.9, 5.0
    final reviewCount = 120 + _random.nextInt(330); // 120 - 450
    final avatarBgColor = _avatarColors[_random.nextInt(_avatarColors.length)];

    String model = '';
    String color = '';
    String plate = '';

    final inputLower = vehicleTypeInput.toLowerCase();
    if (inputLower.contains('มอเตอร์ไซค์') || inputLower.contains('มอไซค์') || inputLower.contains('มอไซ') || inputLower.contains('bike')) {
      model = _motoModels[_random.nextInt(_motoModels.length)];
      color = _motoColors[_random.nextInt(_motoColors.length)];
      plate = _motoPlates[_random.nextInt(_motoPlates.length)];
    } else if (inputLower.contains('กระบะ') || inputLower.contains('ตู้ทึบ') || inputLower.contains('truck') || inputLower.contains('pickup')) {
      model = _truckModels[_random.nextInt(_truckModels.length)];
      color = _truckColors[_random.nextInt(_truckColors.length)];
      plate = _truckPlates[_random.nextInt(_truckPlates.length)];
    } else if (inputLower.contains('เก๋ง') || inputLower.contains('car')) {
      model = _carModels[_random.nextInt(_carModels.length)];
      color = _carColors[_random.nextInt(_carColors.length)];
      plate = _carPlates[_random.nextInt(_carPlates.length)];
    } else {
      model = _motoModels[_random.nextInt(_motoModels.length)];
      color = _motoColors[_random.nextInt(_motoColors.length)];
      plate = _motoPlates[_random.nextInt(_motoPlates.length)];
    }

    final driver = DriverModel(
      name: name,
      phone: phone,
      rating: double.parse(rating.toStringAsFixed(1)),
      reviewCount: reviewCount,
      vehicleType: vehicleTypeInput,
      vehicleModel: model,
      vehicleColor: color,
      licensePlate: plate,
      avatarBgColor: avatarBgColor,
      avatarIcon: Icons.person_rounded,
    );

    state = driver;
    return driver;
  }
}

final driverProvider = NotifierProvider<DriverNotifier, DriverModel>(
  DriverNotifier.new,
);
