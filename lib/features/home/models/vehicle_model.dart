import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';

class VehicleModel {
  final String name;
  final String description;
  final String dimensions;
  final String maxWeight;
  final String? tempControl;
  final String imagePath;
  final IconData icon;

  const VehicleModel({
    required this.name,
    required this.description,
    required this.dimensions,
    required this.maxWeight,
    this.tempControl,
    required this.imagePath,
    this.icon = Icons.local_shipping_rounded,
  });

  /// Mock data list matching the reference image and requirements
  static List<VehicleModel> get mockVehicles => [
        const VehicleModel(
          name: 'มอเตอร์ไซค์',
          description: 'เหมาะสำหรับอาหาร-เครื่องดื่ม, เอกสาร, พัสดุขนาดเล็ก',
          dimensions: '0.5 x 0.4 x 0.5 เมตร',
          maxWeight: 'สูงสุด 20 กิโลกรัม',
          imagePath: AppAssets.motorcycle,
          icon: Icons.two_wheeler_rounded,
        ),
        const VehicleModel(
          name: 'รถเก๋ง 4 ประตู',
          description: 'เหมาะสำหรับดอกไม้-ผลไม้, เค้ก, ลูกโป่ง, อาหารกล่องจำนวนมาก',
          dimensions: '0.9 x 1 x 0.7 เมตร',
          maxWeight: 'สูงสุด 100 กิโลกรัม',
          imagePath: AppAssets.sedan,
          icon: Icons.directions_car_rounded,
        ),
        const VehicleModel(
          name: 'รถกระบะ',
          description: 'เหมาะสำหรับผัก-ผลไม้(ลัง), อุปกรณ์ก่อสร้าง, อะไหล่รถยนต์, ต้นไม้, กล่องไม้จำนวนมาก',
          dimensions: '1.5 x 1.4 x 0.5 เมตร',
          maxWeight: 'สูงสุด 1100 กิโลกรัม',
          imagePath: AppAssets.pickup,
          icon: Icons.local_shipping_rounded,
        ),
        const VehicleModel(
          name: 'รถห้องเย็น',
          description: 'เหมาะสำหรับอาหารสด, เนื้อสัตว์, อาหารทะเล, สินค้าแช่เย็น-แช่แข็ง, ยาและเวชภัณฑ์',
          dimensions: '2.0 x 1.6 x 1.8 เมตร',
          maxWeight: 'สูงสุด 2000 กิโลกรัม',
          tempControl: 'ควบคุมอุณหภูมิ 0 ถึง -20 องศาเซลเซียส',
          imagePath: AppAssets.reefer,
          icon: Icons.kitchen_rounded,
        ),
        const VehicleModel(
          name: 'รถบรรทุกมีลิฟท์ท้าย',
          description: 'เหมาะสำหรับขนย้ายเครื่องใช้ไฟฟ้า, เฟอร์นิเจอร์, เครื่องจักร, สินค้าน้ำหนักมาก',
          dimensions: '3.1 x 1.7 x 1.8 เมตร',
          maxWeight: 'สูงสุด 3000 กิโลกรัม',
          imagePath: AppAssets.truckLift,
          icon: Icons.fire_truck_rounded,
        ),
      ];
}
