import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';

class CallScreen extends StatefulWidget {
  final String driverId;
  const CallScreen({super.key, required this.driverId});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isCallEnded = false;

  void _endCall() {
    setState(() {
      _isCallEnded = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCallEnded) {
      return _buildEndedCall();
    }
    return _buildActiveCall();
  }

  Widget _buildActiveCall() {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(), // No back button
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmallScreen = screenHeight < 700;
            final avatarSize = isSmallScreen ? 80.0 : 120.0;
            final spacing = isSmallScreen ? 8.0 : 16.0;

            return Column(
              children: [
                // Top section (Avatar, Info)
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Icon(Icons.person,
                              size: avatarSize * 0.6,
                              color: const Color(0xFF4285F4)),
                        ),
                      ),
                      SizedBox(height: spacing),
                      Text(
                        'ทนงทวย ตีหอย',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '099-000-0009',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      SizedBox(height: spacing),
                      Text(
                        '00:01:32',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Middle section (Row 1 buttons)
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildActionButton(Icons.mic_off, 'ปิดไมค์', false, isSmallScreen),
                          _buildActionButton(Icons.volume_up, 'ลำโพง', true, isSmallScreen),
                          _buildActionButton(Icons.graphic_eq, 'เสียงระหว่างสาย', false, isSmallScreen),
                        ],
                      ),
                    ),
                  ),
                ),

                // Middle section (Row 2 buttons)
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildActionButton(Icons.add, 'เพิ่มสาย', false, isSmallScreen),
                          _buildActionButton(Icons.videocam, 'วิดีโอคอล', false, isSmallScreen),
                          _buildActionButton(Icons.more_horiz, 'เพิ่มเติม', false, isSmallScreen),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom section (End call)
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _endCall,
                        child: Container(
                          width: isSmallScreen ? 60 : 72,
                          height: isSmallScreen ? 60 : 72,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.call_end,
                              color: Colors.white,
                              size: isSmallScreen ? 28 : 36),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'วางสาย',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 12 : 14),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEndedCall() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              'สิ้นสุดการสนทนา',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '00:01:32',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.person, size: 60, color: Color(0xFF4285F4)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ทนงทวย ตีหอย',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '099-000-0009',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Text(
              'วางสายแล้ว',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, bool isActive, bool isSmallScreen) {
    final buttonSize = isSmallScreen ? 50.0 : 64.0;
    final iconSize = isSmallScreen ? 24.0 : 32.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.primary : Colors.white,
            size: iconSize,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 10 : 12,
          ),
        ),
      ],
    );
  }
}
