import 'package:flutter/material.dart';
import '../models/delivery_model.dart';
import 'delivery_card.dart';

class DeliveryHistoryCard extends StatelessWidget {
  final DeliveryModel delivery;
  final VoidCallback? onTap;

  const DeliveryHistoryCard({
    super.key,
    required this.delivery,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DeliveryCard(
      delivery: delivery,
      onTap: onTap,
    );
  }
}
