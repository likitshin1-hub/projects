import 'package:flutter/material.dart';
import 'delivery_history_page.dart';


class DeliveryHistoryScreen extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const DeliveryHistoryScreen({
    super.key,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DeliveryHistoryPage(
      onMenuPressed: onMenuPressed,
    );
  }
}
