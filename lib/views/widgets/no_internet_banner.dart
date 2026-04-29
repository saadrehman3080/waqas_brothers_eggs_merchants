import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/utils/connectivity_service.dart';

/// Slides down a thin banner when the device goes offline. Designed to wrap
/// the main app shell — does not block any underlying UI.
class NoInternetBanner extends StatelessWidget {
  final Widget child;
  const NoInternetBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final online = context.select<ConnectivityService, bool>(
      (s) => s.isOnline,
    );
    return Stack(
      children: [
        child,
        if (!online)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  border: Border.all(color: AppColors.warningSoftBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.noInternetSubtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
