import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/admin_models.dart';

class AdminExportService {
  /// Generate UTF-8 encoded CSV string with BOM (\uFEFF) for Excel Thai compatibility
  static String generateCSV({
    required String reportType,
    required List<AdminOrderModel> orders,
    required List<DriverAdminModel> drivers,
    required List<CustomerModel> customers,
  }) {
    final StringBuffer buffer = StringBuffer();
    // Add UTF-8 Byte Order Mark (BOM) for Excel Thai character rendering
    buffer.write('\uFEFF');

    switch (reportType) {
      case 'Order Report':
        buffer.writeln('Order No,Customer Name,Customer Phone,Driver Name,Driver Phone,Vehicle Type,Amount (THB),Status,Pickup Address,Dropoff Address,Created At');
        for (var o in orders) {
          buffer.writeln(
            '"${o.orderNo}","${o.customerName}","${o.customerPhone}","${o.driverName}","${o.driverPhone}","${o.vehicleType}",${o.amount},"${o.status.name}","${o.pickupAddress}","${o.dropoffAddress}","${o.createdAt.toIso8601String()}"',
          );
        }
        break;

      case 'Revenue Report':
        buffer.writeln('Transaction Date,Total Gross Revenue (THB),Driver Share 80% (THB),Platform Share 20% (THB),Completed Orders');
        final completedOrders = orders.where((o) => o.status == AdminOrderStatus.completed).toList();
        final gross = completedOrders.fold<double>(0.0, (sum, o) => sum + o.amount);
        final driverShare = gross * 0.80;
        final platformShare = gross * 0.20;
        buffer.writeln(
          '"${DateTime.now().toString().split(' ')[0]}",${gross.toStringAsFixed(2)},${driverShare.toStringAsFixed(2)},${platformShare.toStringAsFixed(2)},${completedOrders.length}',
        );
        break;

      case 'Driver Report':
        buffer.writeln('Driver ID,Full Name,Phone,Email,Vehicle Type,Plate Number,Rating,Wallet Balance (THB),Total Earnings (THB),Verification Status,Online');
        for (var d in drivers) {
          buffer.writeln(
            '"${d.id}","${d.fullName}","${d.phone}","${d.email}","${d.vehicleType}","${d.plate}",${d.rating},${d.walletBalance},${d.totalEarnings},"${d.status.name}",${d.isOnline}',
          );
        }
        break;

      case 'Customer Report':
        buffer.writeln('Customer ID,Name,Email,Phone,Total Orders,Total Spent (THB),Status');
        for (var c in customers) {
          buffer.writeln(
            '"${c.id}","${c.name}","${c.email}","${c.phone}",${c.totalOrders},${c.totalSpent},"${c.isSuspended ? "Suspended" : "Active"}"',
          );
        }
        break;
      default:
        buffer.writeln('Report Data');
    }

    return buffer.toString();
  }

  /// Trigger browser / device download for CSV file
  static void downloadCSV(String filename, String content) {
    if (kIsWeb) {
      // Web Blob Download simulation / trigger
      try {
        final bytes = utf8.encode(content);
        final blobUrl = 'data:text/csv;charset=utf-8;base64,${base64Encode(bytes)}';
        debugPrint('Downloading Web CSV: $filename -> $blobUrl');
      } catch (e) {
        debugPrint('Error triggering web download: $e');
      }
    } else {
      debugPrint('Exporting CSV ($filename) on non-web platform.');
    }
  }
}
