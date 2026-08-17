import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../providers/admin_provider.dart';
import 'tabs/admin_overview_tab.dart';
import 'tabs/admin_customers_tab.dart';
import 'tabs/admin_drivers_tab.dart';
import 'tabs/admin_management_tab.dart';
import 'tabs/admin_orders_tab.dart';
import 'tabs/admin_tracking_tab.dart';
import 'tabs/admin_finance_tab.dart';
import 'tabs/admin_reports_tab.dart';
import 'tabs/admin_settings_tab.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isSidebarCollapsed = false;

  Widget _buildActiveTabContent(int index) {
    switch (index) {
      case 0:
        return const AdminOverviewTab();
      case 1:
        return const AdminCustomersTab();
      case 2:
        return const AdminDriversTab();
      case 3:
        return const AdminManagementTab();
      case 4:
        return const AdminOrdersTab();
      case 5:
        return const AdminTrackingTab();
      case 6:
        return const AdminFinanceTab();
      case 7:
        return const AdminReportsTab();
      case 8:
        return const AdminSettingsTab();
      default:
        return const AdminOverviewTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(adminActiveTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          // Sidebar Drawer
          Container(
            width: _isSidebarCollapsed ? 80 : 260,
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                // Header Logo
                Container(
                  height: 70,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C7FF6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 22),
                      ),
                      if (!_isSidebarCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'TBMoveHub',
                            style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Navigation Items List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    children: [
                      _buildNavItem(0, 'Dashboard', Icons.dashboard_rounded, activeTab),
                      _buildNavItem(1, 'Customers (ลูกค้า)', Icons.people_rounded, activeTab),
                      _buildNavItem(2, 'Drivers (คนขับ/ไรเดอร์)', Icons.two_wheeler_rounded, activeTab),
                      _buildNavItem(3, 'Admins (ผู้ดูแลระบบ)', Icons.admin_panel_settings_rounded, activeTab),
                      _buildNavItem(4, 'Orders (คำสั่งซื้อ)', Icons.shopping_bag_rounded, activeTab),
                      _buildNavItem(5, 'Tracking (ติดตามพิกัด)', Icons.map_rounded, activeTab),
                      _buildNavItem(6, 'Finance (การเงิน)', Icons.account_balance_wallet_rounded, activeTab),
                      _buildNavItem(7, 'Reports (รายงานสถิติ)', Icons.bar_chart_rounded, activeTab),
                      _buildNavItem(8, 'Settings (ตั้งค่าราคา)', Icons.settings_rounded, activeTab),
                    ],
                  ),
                ),

                // Collapse Toggle
                InkWell(
                  onTap: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: const Color(0xFF0F172A),
                    child: Row(
                      mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                      children: [
                        if (!_isSidebarCollapsed)
                          Text('ย่อเมนู', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13)),
                        Icon(_isSidebarCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: const Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Header + Dynamic Content
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTabTitle(activeTab),
                        style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🔔 มี 2 คนขับใหม่รอการอนุมัติเอกสาร', style: GoogleFonts.kanit()),
                                  backgroundColor: const Color(0xFF3B82F6),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          PopupMenuButton<String>(
                            color: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (val) {
                              if (val == 'logout') context.go(AppRoutes.login);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'profile',
                                child: Text('Super Admin (admin@tbmovehub.com)', style: GoogleFonts.kanit(color: Colors.white, fontSize: 13)),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'logout',
                                child: Text('ออกจากระบบ (Logout)', style: GoogleFonts.kanit(color: Colors.redAccent, fontSize: 13)),
                              ),
                            ],
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFF1C7FF6),
                                  child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Super Admin', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('admin@tbmovehub.com', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 11)),
                                  ],
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Tab Content Area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF0F172A),
                    child: _buildActiveTabContent(activeTab),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon, int activeTab) {
    final isSelected = activeTab == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => ref.read(adminActiveTabProvider.notifier).setTab(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1C7FF6) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : const Color(0xFF94A3B8), size: 22),
              if (!_isSidebarCollapsed) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.kanit(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return '🏠 Overview Dashboard';
      case 1:
        return '👤 Customers Management (จัดการลูกค้า)';
      case 2:
        return '🚚 Drivers Management (ตรวจสอบเอกสาร & จัดการคนขับ)';
      case 3:
        return '👨‍💼 Admin Users & Roles (ผู้ดูแลระบบและกำหนดสิทธิ์)';
      case 4:
        return '📦 Orders Management (จัดการคำสั่งซื้อและสถานะ)';
      case 5:
        return '📍 Live Map Tracking (ติดตามสถานะแบบเรียลไทม์)';
      case 6:
        return '💰 Finance & Driver Wallets (การเงินและกระเป๋าเงินไรเดอร์)';
      case 7:
        return '📊 Reports & Analytics (รายงานและส่งออกไฟล์ CSV)';
      case 8:
        return '⚙️ Vehicle Pricing & System Settings (ตั้งค่าราคาและกฎระบบ)';
      default:
        return 'Admin Dashboard';
    }
  }
}
