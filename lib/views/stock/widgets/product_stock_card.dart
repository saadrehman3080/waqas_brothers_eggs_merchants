import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/product.dart';
import '../../../models/stock_entry.dart';

/// Stock card per product — pricing/availability tiles + read-only log.
class ProductStockCard extends StatelessWidget {
  final Product product;
  final List<StockEntry> entries;
  final VoidCallback onEdit;

  const ProductStockCard({
    super.key,
    required this.product,
    required this.entries,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <_StatTileData>[
      _StatTileData(
        label: 'Price',
        value: 'Rs.${product.price.toStringAsFixed(0)}',
        suffix: '',
        color: AppColors.ink600,
      ),
      _StatTileData(
        label: 'Available',
        value: '${product.remaining}',
        suffix: 'of ${product.stock}',
        color: AppColors.success,
      ),
      _StatTileData(
        label: 'Sold',
        value: '${product.sold}',
        suffix: 'units',
        color: AppColors.primary,
      ),
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(product: product, onEdit: onEdit),
          const SizedBox(height: 11),
          Row(
            children: List.generate(tiles.length, (i) {
              final isLast = i == tiles.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 7),
                  child: _StatTile(data: tiles[i]),
                ),
              );
            }),
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 10),
            _StockLog(entries: entries),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  const _Header({required this.product, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.nameEn, style: AppTextStyles.bodyLg),
              const SizedBox(height: 1),
              Text(product.nameUr, style: AppTextStyles.urdu(size: 11)),
            ],
          ),
        ),
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.ink600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTileData {
  final String label;
  final String value;
  final String suffix;
  final Color color;
  _StatTileData({
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
  });
}

class _StatTile extends StatelessWidget {
  final _StatTileData data;
  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label.toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.ink400,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: data.color,
            ),
          ),
          Text(
            data.suffix,
            style: const TextStyle(fontSize: 8, color: AppColors.ink400),
          ),
        ],
      ),
    );
  }
}

class _StockLog extends StatelessWidget {
  final List<StockEntry> entries;
  const _StockLog({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'STOCK LOG — READ ONLY',
            style: TextStyle(
              fontSize: 8,
              color: AppColors.ink400,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 5),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${e.date} ${e.time}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.ink600,
                    ),
                  ),
                  Text(
                    '+${e.qty} units',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink900,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
