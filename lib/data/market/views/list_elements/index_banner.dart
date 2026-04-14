import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/index_model.dart';

class IndexBanner extends StatelessWidget {
  final List<IndexModel> indices;
  const IndexBanner({super.key, required this.indices});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: indices
          .map(
            (idx) => RepaintBoundary(
              child: _indexCard(index: idx, isDark: isDark, theme: theme),
            ),
          )
          .toList(),
    );
  }

  ///
  Widget _indexCard({required IndexModel index, required bool isDark, required ThemeData theme}) {
    final isUp = index.isUp;
    final color = isUp ? AppColors.gain : AppColors.loss;
    final arrow = isUp ? '▲' : '▼';

    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            index.shortName,
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 4),
          Text(index.value.toStringAsFixed(2), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            '$arrow ${index.change.abs().toStringAsFixed(2)} (${index.changePercent.abs().toStringAsFixed(2)}%)',
            style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
