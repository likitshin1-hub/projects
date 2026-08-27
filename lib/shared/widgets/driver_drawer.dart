import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_routes.dart';
import '../../core/providers/theme_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/user_role_provider.dart';
import '../../features/driver/providers/driver_shift_provider.dart';

class DriverDrawer extends ConsumerWidget {
  const DriverDrawer({super.key});

  void _showWalletModal(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF10B981), size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('กระเป๋าเงินคนขับ (Driver Wallet)', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                    Text('ยอดเงินสะสมพร้อมถอนสะสมวันนี้', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Balance Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ยอดเงินคงเหลือสุทธิ', style: GoogleFonts.kanit(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('฿1,250.00', style: GoogleFonts.kanit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showWithdrawModal(context, isDarkMode);
                        },
                        icon: const Icon(Icons.payments_rounded, size: 16),
                        label: Text('ถอนเงิน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF059669),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text('รายการรายได้ล่าสุด', style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
            const SizedBox(height: 10),
            _buildWalletTransactionTile('ค่าขนส่งคำสั่งซื้อ #ORD-9981', 'วันนี้ 10:15 น.', '+฿350.00', isDarkMode),
            _buildWalletTransactionTile('ค่าขนส่งคำสั่งซื้อ #ORD-9974', 'วันนี้ 09:30 น.', '+฿420.00', isDarkMode),
            _buildWalletTransactionTile('โบนัสพิเศษประจำสัปดาห์', 'เมื่อวาน 18:00 น.', '+฿480.00', isDarkMode),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletTransactionTile(String title, String subtitle, String amount, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_downward_rounded, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                  Text(subtitle, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          Text(amount, style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
        ],
      ),
    );
  }

  void _showWithdrawModal(BuildContext context, bool isDarkMode) {
    final amountController = TextEditingController(text: '1250');
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.payments_rounded, color: Color(0xFF3B82F6), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ถอนเงินรายได้เข้าบัญชีธนาคาร', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                      Text('โอนเข้าบัญชีที่ผูกไว้อัตโนมัติใน 15 นาที', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bank Account Details Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A950),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('K+', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ธนาคารกสิกรไทย (KBANK)', style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                        Text('เลขที่บัญชี: xxx-x-x1234-x (คุณสมชาย)', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text('ระบุจำนวนเงินที่ต้องการถอน (บาท)', style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                decoration: InputDecoration(
                  prefixText: '฿ ',
                  prefixStyle: GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                  filled: true,
                  fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF10B981))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 ยื่นคำขอถอนเงิน ฿${amountController.text} เรียบร้อยแล้ว! เงินจะเข้าบัญชีใน 15 นาที', style: GoogleFonts.kanit()),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: Text('ยืนยันส่งคำขอถอนเงิน', style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClockOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('🔴 ยืนยันการออกงาน (Clock Out)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text('คุณต้องการออกจากระบบงานคนขับและสลับกลับเป็นผู้ใช้ทั่วไปหรือไม่?', style: GoogleFonts.kanit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('ยกเลิก', style: GoogleFonts.kanit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(driverShiftProvider.notifier).clockOut();
              ref.read(userActiveModeProvider.notifier).setMode(UserActiveMode.customer);
              Navigator.of(dialogCtx).pop();
              GoRouter.of(dialogCtx).go(AppRoutes.home);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('ยืนยันออกงาน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final shiftStatus = ref.watch(driverShiftProvider);

    final drawerBg = isDarkMode ? const Color(0xFF0B0F17) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Drawer(
      backgroundColor: drawerBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Rider Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 54, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F192C),
                  Color(0xFF1E3A8A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 36, color: Colors.white),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: shiftStatus == DriverShiftStatus.working
                                  ? Colors.greenAccent
                                  : shiftStatus == DriverShiftStatus.breakTime
                                      ? Colors.amberAccent
                                      : Colors.redAccent,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (user != null && user.name.isNotEmpty) ? user.name : 'คุณสมชาย สายบิด',
                            style: GoogleFonts.kanit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '4.95 (148 รีวิว)',
                                style: GoogleFonts.kanit(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'ทะเบียน 1กข-9988 • ไรเดอร์ยืนยันตัวตนแล้ว',
                        style: GoogleFonts.kanit(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 7 Key Menu Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // 1. กระเป๋าเงิน
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'กระเป๋าเงิน',
                  iconColor: const Color(0xFF10B981),
                  iconBgColor: isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    _showWalletModal(context, isDarkMode);
                  },
                ),

                // 2. ถอนเงิน
                _buildDrawerItem(
                  icon: Icons.payments_rounded,
                  title: 'ถอนเงินรายได้',
                  iconColor: const Color(0xFF3B82F6),
                  iconBgColor: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    _showWithdrawModal(context, isDarkMode);
                  },
                ),

                // 3. ประวัติการขนส่ง
                _buildDrawerItem(
                  icon: Icons.history_rounded,
                  title: 'ประวัติการขนส่ง',
                  iconColor: const Color(0xFF8B5CF6),
                  iconBgColor: isDarkMode ? const Color(0xFF4C1D95) : const Color(0xFFEDE9FE),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.history);
                  },
                ),

                // 4. รีวอร์ด
                _buildDrawerItem(
                  icon: Icons.emoji_events_rounded,
                  title: 'รีวอร์ดและโบนัส',
                  iconColor: const Color(0xFFF59E0B),
                  iconBgColor: isDarkMode ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.rewards);
                  },
                ),

                // 5. ศูนย์ช่วยเหลือ
                _buildDrawerItem(
                  icon: Icons.support_agent_rounded,
                  title: 'ศูนย์ช่วยเหลือคนขับ',
                  iconColor: const Color(0xFF06B6D4),
                  iconBgColor: isDarkMode ? const Color(0xFF164E63) : const Color(0xFFCFFAFE),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.help);
                  },
                ),

                // 6. ตั้งค่า
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'ตั้งค่าระบบงาน',
                  iconColor: const Color(0xFF64748B),
                  iconBgColor: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.settings);
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: dividerColor),
                ),

                // 7. ออกงาน (Clock Out)
                _buildDrawerItem(
                  icon: Icons.power_settings_new_rounded,
                  title: '🔴 ออกงาน (Clock Out)',
                  iconColor: const Color(0xFFEF4444),
                  iconBgColor: isDarkMode ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
                  textColor: const Color(0xFFEF4444),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmClockOut(context, ref);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.kanit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
