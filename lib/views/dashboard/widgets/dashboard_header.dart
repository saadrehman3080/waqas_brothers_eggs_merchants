import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/format_helpers.dart';

/// Top header for the dashboard — date, title, printer status pill, exit.
class DashboardHeader extends StatelessWidget {
  final bool printerOn;
  final VoidCallback onTogglePrinter;
  final VoidCallback? onExit;

  const DashboardHeader({
    super.key,
    required this.printerOn,
    required this.onTogglePrinter,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FormatHelpers.dayOfWeek(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.ink600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  FormatHelpers.headerDate(),
                  style: AppTextStyles.pageTitle,
                ),
              ],
            ),
          ),
          _PrinterPill(printerOn: printerOn, onTap: onTogglePrinter),
          const SizedBox(width: 8),
          _ExitButton(onPressed: onExit),
        ],
      ),
    );
  }
}

class _PrinterPill extends StatelessWidget {
  final bool printerOn;
  final VoidCallback onTap;

  const _PrinterPill({required this.printerOn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: printerOn ? AppColors.successSoft : AppColors.background,
          border: Border.all(
            color: printerOn ? AppColors.successSoftBorder : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: printerOn ? AppColors.success : AppColors.ink400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              printerOn ? 'Printer On' : 'Offline',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: printerOn ? AppColors.success : AppColors.ink600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _ExitButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Exit',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.ink600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
