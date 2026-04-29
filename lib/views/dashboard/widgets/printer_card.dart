import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/printer_device.dart';
import '../../widgets/app_button.dart';
import '../../widgets/section_card.dart';

class PrinterCard extends StatelessWidget {
  final List<PrinterDevice> printers;
  final ValueChanged<int> onConnect;
  final VoidCallback onPrintRates;

  const PrinterCard({
    super.key,
    required this.printers,
    required this.onConnect,
    required this.onPrintRates,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bluetooth Printer', style: AppTextStyles.sectionTitle),
                Text(
                  AppStrings.urdPrinter,
                  style: AppTextStyles.urdu(size: 10),
                ),
              ],
            ),
          ),
          for (var i = 0; i < printers.length; i++) ...[
            const CardDivider(),
            _PrinterRow(
              device: printers[i],
              onConnect: () => onConnect(i),
            ),
          ],
          const CardDivider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: AppButton(
              label: "Print Today's Rates",
              variant: AppButtonVariant.soft,
              full: true,
              icon: Icons.print_outlined,
              onPressed: onPrintRates,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrinterRow extends StatelessWidget {
  final PrinterDevice device;
  final VoidCallback onConnect;

  const _PrinterRow({required this.device, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    final connected = device.isConnected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.ink900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  device.description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.ink600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onConnect,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: connected ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: connected ? AppColors.success : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                connected ? 'Connected' : 'Connect',
                style: TextStyle(
                  color: connected ? Colors.white : AppColors.ink600,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
