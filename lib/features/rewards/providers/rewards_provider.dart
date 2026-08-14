import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/network/dio_client.dart';

class RewardMilestone {
  final int id;
  final int times;
  final int discount;
  final bool isClaimed;

  RewardMilestone({
    required this.id,
    required this.times,
    required this.discount,
    this.isClaimed = false,
  });

  RewardMilestone copyWith({
    int? id,
    int? times,
    int? discount,
    bool? isClaimed,
  }) {
    return RewardMilestone(
      id: id ?? this.id,
      times: times ?? this.times,
      discount: discount ?? this.discount,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class UserCoupon {
  final String id;
  final String discountText;
  final String unitText;
  final String badgeText;
  final String title;
  final String subtitle;
  final String expiryText;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final Color cardColor;
  final IconData illustrationIcon;

  UserCoupon({
    required this.id,
    required this.discountText,
    required this.unitText,
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.expiryText,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.cardColor,
    this.illustrationIcon = Icons.local_shipping_outlined,
  });
}

class RewardsState {
  final int currentTrips;
  final List<RewardMilestone> milestones;
  final List<UserCoupon> userCoupons;
  final bool isLoading;

  RewardsState({
    required this.currentTrips,
    required this.milestones,
    required this.userCoupons,
    this.isLoading = false,
  });

  RewardsState copyWith({
    int? currentTrips,
    List<RewardMilestone>? milestones,
    List<UserCoupon>? userCoupons,
    bool? isLoading,
  }) {
    return RewardsState(
      currentTrips: currentTrips ?? this.currentTrips,
      milestones: milestones ?? this.milestones,
      userCoupons: userCoupons ?? this.userCoupons,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  RewardMilestone? get nextMilestone {
    for (final m in milestones) {
      if (currentTrips < m.times) {
        return m;
      }
    }
    return milestones.isNotEmpty ? milestones.last : null;
  }
}

class RewardsNotifier extends ChangeNotifier {
  late RewardsState _state;
  final DioClient _dioClient = DioClient();

  RewardsNotifier() {
    _state = RewardsState(
      currentTrips: 7,
      milestones: [
        RewardMilestone(id: 1, times: 5, discount: 20, isClaimed: false),
        RewardMilestone(id: 2, times: 10, discount: 50, isClaimed: false),
        RewardMilestone(id: 3, times: 20, discount: 120, isClaimed: false),
        RewardMilestone(id: 4, times: 30, discount: 200, isClaimed: false),
        RewardMilestone(id: 5, times: 50, discount: 400, isClaimed: false),
      ],
      userCoupons: [
        UserCoupon(
          id: 'init_50',
          discountText: '50',
          unitText: 'บาท',
          badgeText: 'คูปองส่วนลด',
          title: 'ส่วนลด 50 บาท',
          subtitle: 'เมื่อใช้บริการครบ 399 บาทขึ้นไป',
          expiryText: 'หมดอายุ 31 ส.ค. 2569',
          badgeBgColor: const Color(0xFFE8F2FE),
          badgeTextColor: const Color(0xFF1C7FF6),
          cardColor: const Color(0xFF1C7FF6),
          illustrationIcon: Icons.local_shipping_outlined,
        ),
        UserCoupon(
          id: 'init_20',
          discountText: '20',
          unitText: 'บาท',
          badgeText: 'คูปองส่วนลด',
          title: 'ส่วนลด 20 บาท',
          subtitle: 'เมื่อใช้บริการครบ 150 บาทขึ้นไป',
          expiryText: 'หมดอายุ 25 ก.ย. 2569',
          badgeBgColor: const Color(0xFFECFDF5),
          badgeTextColor: const Color(0xFF10B981),
          cardColor: const Color(0xFF10B981),
          illustrationIcon: Icons.motorcycle_rounded,
        ),
        UserCoupon(
          id: 'init_freeship',
          discountText: 'ฟรี',
          unitText: 'ส่งฟรี',
          badgeText: 'คูปองส่งฟรี',
          title: 'ส่งฟรีทั่วไทย',
          subtitle: 'รับส่วนลดค่าส่งสูงสุด 40 บาท',
          expiryText: 'หมดอายุ 10 ส.ค. 2569',
          badgeBgColor: const Color(0xFFF3E8FF),
          badgeTextColor: const Color(0xFF8B5CF6),
          cardColor: const Color(0xFF8B5CF6),
          illustrationIcon: Icons.local_shipping_outlined,
        ),
      ],
    );

    // โหลดข้อมูลคูปองจริงจาก Backend API
    fetchCouponsFromBackend();
  }

  RewardsState get state => _state;

  Future<void> fetchCouponsFromBackend() async {
    try {
      final response = await _dioClient.get('/coupons');
      if (response.data is List) {
        final List list = response.data as List;
        final List<UserCoupon> fetchedCoupons = list.map((item) {
          final isFree = item['discount_type'] == 'freeship';
          final discountVal = item['discount_amount'] != null ? '${(item['discount_amount'] as num).toInt()}' : '50';
          
          return UserCoupon(
            id: item['code'] ?? 'c_${item['id']}',
            discountText: isFree ? 'ฟรี' : discountVal,
            unitText: isFree ? 'ส่งฟรี' : 'บาท',
            badgeText: isFree ? 'คูปองส่งฟรี' : 'คูปองส่วนลด',
            title: item['title'] ?? 'ส่วนลดพิเศษ',
            subtitle: item['subtitle'] ?? '',
            expiryText: 'หมดอายุ ${item['expiry_date'] ?? '31 ธ.ค. 2569'}',
            badgeBgColor: isFree ? const Color(0xFFF3E8FF) : const Color(0xFFE8F2FE),
            badgeTextColor: isFree ? const Color(0xFF8B5CF6) : const Color(0xFF1C7FF6),
            cardColor: isFree ? const Color(0xFF8B5CF6) : const Color(0xFF1C7FF6),
          );
        }).toList();

        if (fetchedCoupons.isNotEmpty) {
          _state = _state.copyWith(userCoupons: fetchedCoupons);
          notifyListeners();
        }
      }
    } catch (_) {
      // ใช้ข้อมูล default เดิมเป็น fallback
    }
  }

  Future<bool> claimCouponBackend(String code, String title, double discount, String subtitle) async {
    try {
      await _dioClient.post('/coupons/claim', data: {
        'code': code,
        'title': title,
        'discount_amount': discount,
        'subtitle': subtitle,
      });
      await fetchCouponsFromBackend();
      return true;
    } catch (_) {
      addUserCoupon(UserCoupon(
        id: code,
        discountText: '${discount.toInt()}',
        unitText: 'บาท',
        badgeText: 'คูปองส่วนลด',
        title: title,
        subtitle: subtitle,
        expiryText: 'หมดอายุ 31 ธ.ค. 2569',
        badgeBgColor: const Color(0xFFE8F2FE),
        badgeTextColor: const Color(0xFF1C7FF6),
        cardColor: const Color(0xFF1C7FF6),
      ));
      return true;
    }
  }

  void addUserCoupon(UserCoupon coupon) {
    if (_state.userCoupons.any((c) => c.id == coupon.id)) return;
    _state = _state.copyWith(
      userCoupons: [coupon, ..._state.userCoupons],
    );
    notifyListeners();
  }

  void addTrip() {
    _state = _state.copyWith(currentTrips: _state.currentTrips + 1);
    notifyListeners();
  }

  void resetTrips() {
    _state = RewardsState(
      currentTrips: 0,
      milestones: _state.milestones
          .map((m) => m.copyWith(isClaimed: false))
          .toList(),
      userCoupons: _state.userCoupons,
    );
    notifyListeners();
  }

  void claimReward(int milestoneId) {
    final updated = _state.milestones.map((m) {
      if (m.id == milestoneId && _state.currentTrips >= m.times) {
        return m.copyWith(isClaimed: true);
      }
      return m;
    }).toList();

    _state = _state.copyWith(milestones: updated);
    notifyListeners();
  }
}

final rewardsProvider = ChangeNotifierProvider<RewardsNotifier>((ref) {
  return RewardsNotifier();
});
