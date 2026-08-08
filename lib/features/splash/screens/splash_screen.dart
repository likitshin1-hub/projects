import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/splash_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnim;
  late final Animation<double> _slideAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashProvider.notifier).initialize();
    });
  }

  void _initAnimations() {
    _entryController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 900),
    );

    _pulseController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(
      parent: _entryController,

      curve: Curves.easeOut,
    );

    _scaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );

    _slideAnim = Tween<double>(
      begin: 30,

      end: 0,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();

    _pulseController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SplashState>(splashProvider, (previous, next) {
      switch (next.status) {
        case SplashStatus.navigateToHome:
          _navigate(AppRoutes.home);

          break;

        case SplashStatus.navigateToLogin:
          _navigate(AppRoutes.login);

          break;

        default:
          break;
      }
    });

    final state = ref.watch(splashProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,

        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), AppColors.primary, Color(0xFF29B6F6)],

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),

            child: Column(
              children: [
                const Spacer(),

                _logo(),

                const SizedBox(height: 28),

                _appName(),

                const SizedBox(height: 10),

                Text(
                  AppStrings.appDescription,

                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),

                    fontSize: 13,
                  ),
                ),

                const Spacer(),

                state.status == SplashStatus.noInternet
                    ? _NoInternetWidget(
                        onRetry: () {
                          ref.read(splashProvider.notifier).retry();
                        },
                      )
                    : _ProgressWidget(state: state),

                const SizedBox(height: 40),

                Text(
                  'v1.0.0',

                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),

                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigate(String route) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    context.go(route);
  }

  Widget _logo() {
    return FadeTransition(
      opacity: _fadeAnim,

      child: ScaleTransition(
        scale: _scaleAnim,

        child: ScaleTransition(
          scale: _pulseAnim,

          child: Container(
            width: 110,

            height: 110,

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(28),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),

                  blurRadius: 40,

                  offset: const Offset(0, 12),
                ),
              ],
            ),

            child: const Icon(
              Icons.local_shipping_rounded,

              size: 58,

              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _appName() {
    return AnimatedBuilder(
      animation: _entryController,

      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnim.value),

          child: FadeTransition(opacity: _fadeAnim, child: child),
        );
      },

      child: const Text(
        AppStrings.appName,

        style: TextStyle(
          fontSize: 38,

          fontWeight: FontWeight.w800,

          color: Colors.white,

          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ProgressWidget extends StatelessWidget {
  final SplashState state;

  const _ProgressWidget({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          state.message,

          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),

        const SizedBox(height: 14),

        LinearProgressIndicator(
          value: state.progress,

          minHeight: 3,

          backgroundColor: Colors.white24,

          valueColor: const AlwaysStoppedAnimation(Colors.white),
        ),
      ],
    );
  }
}

class _NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const _NoInternetWidget({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 40),

        const SizedBox(height: 20),

        OutlinedButton(onPressed: onRetry, child: const Text('ลองใหม่')),
      ],
    );
  }
}
