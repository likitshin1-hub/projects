import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CallScreen extends StatefulWidget {
  final String driverId;
  const CallScreen({super.key, required this.driverId});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isCallEnded = false;

  // Button States
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isAudioEffectOn = false;
  bool _isHoldOn = false;
  bool _isVideoOn = false;

  // Call Timer
  Timer? _timer;
  int _secondsElapsed = 92;

  // ── Light Gray Palette ──────────────────────────
  static const Color _bgTop    = Color(0xFFF4F5F7); // light gray top
  static const Color _bgBottom = Color(0xFFE2E6EA); // slightly deeper gray bottom
  static const Color _cardBg   = Color(0xFFFFFFFF); // white card
  static const Color _textMain = Color(0xFF1A1A2E); // dark text
  static const Color _textSub  = Color(0xFF6B7280); // muted gray text
  static const Color _accent   = Color(0xFF3B82F6); // blue accent
  // ───────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isCallEnded) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  String _formatDuration(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int remaining = seconds % 60;
    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = remaining.toString().padLeft(2, '0');
    if (hours > 0) return '${hours.toString().padLeft(2, '0')}:$mm:$ss';
    return '$mm:$ss';
  }

  void _endCall() {
    _timer?.cancel();
    setState(() => _isCallEnded = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.pop();
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.kanit(fontSize: 14, color: Colors.white)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF374151),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text('ตัวเลือกเพิ่มเติม',
                style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: _textMain)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.fiber_manual_record, color: Colors.redAccent),
                title: Text('บันทึกเสียงการสนทนา', style: GoogleFonts.kanit(color: _textMain, fontSize: 16)),
                onTap: () { Navigator.pop(context); _showToast('เริ่มบันทึกเสียงการสนทนาแล้ว'); },
              ),
              ListTile(
                leading: const Icon(Icons.swap_calls_rounded, color: Color(0xFF3B82F6)),
                title: Text('โอนสายไปยังเจ้าหน้าที่อื่น', style: GoogleFonts.kanit(color: _textMain, fontSize: 16)),
                onTap: () { Navigator.pop(context); _showToast('กำลังโอนสาย...'); },
              ),
              ListTile(
                leading: const Icon(Icons.dialpad_rounded, color: Colors.amber),
                title: Text('ปุ่มกดตัวเลข (Keypad)', style: GoogleFonts.kanit(color: _textMain, fontSize: 16)),
                onTap: () { Navigator.pop(context); _showToast('เปิดปุ่มกดตัวเลข'); },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isCallEnded ? _buildEndedCall() : _buildActiveCall();
  }

  // ─────────────────────────────────────────────
  //  ACTIVE CALL SCREEN (Light Gray)
  // ─────────────────────────────────────────────
  Widget _buildActiveCall() {
    final isCallCenter = widget.driverId == 'call_center' ||
        widget.driverId == 'support' ||
        widget.driverId == 'center';
    final displayName  = isCallCenter ? 'ศูนย์บริการลูกค้า (Call Center)' : 'ทนงทวย ตีหอย';
    final displayPhone = isCallCenter ? '02-123-4567' : '099-000-0009';
    final displayIcon  = isCallCenter ? Icons.headset_mic_rounded : Icons.person;

    return Scaffold(
      backgroundColor: _bgTop,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxHeight < 680;
              final avatarSize = isSmallScreen ? 100.0 : 128.0;
              final buttonSize = isSmallScreen ? 68.0 : 76.0;
              final iconSize   = isSmallScreen ? 28.0 : 32.0;

              return Column(
                children: [
                  const SizedBox(height: 20),

                  // ── Avatar + Name + Phone + Timer ──
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar with blue ring
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: _accent, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.18),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(displayIcon, size: avatarSize * 0.52, color: _accent),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            displayName,
                            style: GoogleFonts.kanit(
                              color: _textMain,
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Phone
                        Text(
                          displayPhone,
                          style: GoogleFonts.kanit(color: _textSub, fontSize: 16),
                        ),
                        const SizedBox(height: 14),

                        // Timer badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDuration(_secondsElapsed),
                                style: GoogleFonts.kanit(
                                  color: _textMain,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Thin divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Divider(color: Colors.black.withValues(alpha: 0.08), height: 1),
                  ),
                  const SizedBox(height: 20),

                  // ── Button Row 1: Mic / Speaker / Audio ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                          label: _isMuted ? 'เปิดไมค์' : 'ปิดไมค์',
                          isActive: _isMuted,
                          buttonSize: buttonSize, iconSize: iconSize,
                          onTap: () {
                            setState(() => _isMuted = !_isMuted);
                            _showToast(_isMuted ? 'ปิดไมโครโฟนแล้ว' : 'เปิดไมโครโฟนแล้ว');
                          },
                        ),
                        _buildActionButton(
                          icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          label: _isSpeakerOn ? 'ลำโพงเปิด' : 'ลำโพงปิด',
                          isActive: _isSpeakerOn,
                          buttonSize: buttonSize, iconSize: iconSize,
                          onTap: () {
                            setState(() => _isSpeakerOn = !_isSpeakerOn);
                            _showToast(_isSpeakerOn ? 'เปิดลำโพงแล้ว' : 'ปิดลำโพงแล้ว');
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.graphic_eq_rounded,
                          label: 'เสียงสาย',
                          isActive: _isAudioEffectOn,
                          buttonSize: buttonSize, iconSize: iconSize,
                          onTap: () {
                            setState(() => _isAudioEffectOn = !_isAudioEffectOn);
                            _showToast(_isAudioEffectOn ? 'เปิดระบบตัดเสียงรบกวน' : 'ปิดระบบตัดเสียงรบกวน');
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Button Row 2: Hold / Video / More ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: _isHoldOn ? Icons.pause_circle_rounded : Icons.add_rounded,
                          label: _isHoldOn ? 'พักสายอยู่' : 'เพิ่มสาย',
                          isActive: _isHoldOn,
                          buttonSize: buttonSize, iconSize: iconSize,
                          onTap: () {
                            setState(() => _isHoldOn = !_isHoldOn);
                            _showToast(_isHoldOn ? 'พักสายชั่วคราว' : 'กำลังเพิ่มสายโทร...');
                          },
                        ),
                        _buildActionButton(
                          icon: _isVideoOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                          label: _isVideoOn ? 'กล้องเปิด' : 'วิดีโอคอล',
                          isActive: _isVideoOn,
                          buttonSize: buttonSize, iconSize: iconSize,
                          onTap: () {
                            setState(() => _isVideoOn = !_isVideoOn);
                            _showToast(_isVideoOn ? 'เปิดกล้องวิดีโอคอล' : 'ปิดกล้องวิดีโอคอล');
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.more_horiz_rounded,
                          label: 'เพิ่มเติม',
                          isActive: false,
                          buttonSize: buttonSize, iconSize: iconSize,
                          onTap: _showMoreOptions,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── End Call Button ──
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          color: Colors.redAccent,
                          shape: const CircleBorder(),
                          elevation: 6,
                          shadowColor: Colors.redAccent.withValues(alpha: 0.4),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _endCall,
                            child: Container(
                              width: buttonSize + 16,
                              height: buttonSize + 16,
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 36),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'วางสาย',
                          style: GoogleFonts.kanit(color: _textSub, fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  ENDED CALL SCREEN (Light Gray)
  // ─────────────────────────────────────────────
  Widget _buildEndedCall() {
    final isCallCenter = widget.driverId == 'call_center' ||
        widget.driverId == 'support' ||
        widget.driverId == 'center';
    final displayName  = isCallCenter ? 'ศูนย์บริการลูกค้า (Call Center)' : 'ทนงทวย ตีหอย';
    final displayPhone = isCallCenter ? '02-123-4567' : '099-000-0009';
    final displayIcon  = isCallCenter ? Icons.headset_mic_rounded : Icons.person;

    return Scaffold(
      backgroundColor: _bgTop,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar (greyed out)
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFD1D5DB), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(displayIcon, size: 56, color: const Color(0xFF9CA3AF)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  Text(
                    displayName,
                    style: GoogleFonts.kanit(color: _textMain, fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Phone
                  Text(displayPhone, style: GoogleFonts.kanit(color: _textSub, fontSize: 15)),
                  const SizedBox(height: 28),

                  // Ended status card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.call_end_rounded, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'สิ้นสุดการสนทนาแล้ว',
                              style: GoogleFonts.kanit(
                                color: Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ระยะเวลาสนทนา  ${_formatDuration(_secondsElapsed)}',
                          style: GoogleFonts.kanit(color: _textSub, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Reusable Action Button (light theme)
  // ─────────────────────────────────────────────
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required double buttonSize,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    // All active buttons use blue accent tone (same as speaker button)
    const activeColor = _accent;
    const activeBg    = Color(0xFFEFF6FF); // very light blue fill
    const inactiveBg  = Colors.white;
    const inactiveBorder = Color(0xFFCBD5E1); // visible light gray border

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeBg : inactiveBg,
                border: Border.all(
                  color: isActive ? activeColor : inactiveBorder,
                  width: isActive ? 2.0 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? activeColor.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.07),
                    blurRadius: isActive ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isActive ? activeColor : _textMain,
                size: iconSize,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.kanit(
            color: isActive ? activeColor : _textSub,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
