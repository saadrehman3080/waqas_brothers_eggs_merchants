import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/inventory_viewmodel.dart';

/// First screen shown on launch. Triggers initial data load while displaying
/// branded animation, then navigates to home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final inventory = context.read<InventoryViewModel>();
    await Future.wait<void>([
      inventory.load(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted) return;
    context.goNamed('home');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primarySoftBorder),
              ),
              child: const Icon(
                Icons.egg_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              AppStrings.appName,
              style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.appNameUrdu,
              style: AppTextStyles.urdu(size: 16, color: AppColors.ink600),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.tagline,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.ink400,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 36),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final t = (_ctrl.value + i * 0.2) % 1.0;
                  final opacity = (0.3 + (1 - (t - 0.5).abs() * 2) * 0.7).clamp(
                    0.3,
                    1.0,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
