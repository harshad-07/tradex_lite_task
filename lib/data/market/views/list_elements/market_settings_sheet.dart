import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_enums/app_enums.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../provider/market_provider.dart';

class MarketSettingsSheet extends StatelessWidget {
  const MarketSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (_) => const MarketSettingsSheet());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final market = context.watch<MarketProvider>();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 20),

          ///
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Text('Market Settings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ///
          _sectionLabel(label: 'Refresh Interval', isDark: isDark),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: RefreshInterval.values.map((interval) {
                final isSelected = market.selectedRefreshInterval == interval;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => market.setRefreshInterval(interval),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : isDark
                            ? AppColors.darkSurface
                            : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder), width: isSelected ? 1.2 : 0.5),
                      ),
                      child: Text(
                        interval.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          ///
          _sectionLabel(label: 'Currency Display', isDark: isDark),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: CurrencyMode.values.map((mode) {
                final isSelected = market.currency == mode;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => market.setCurrency(mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : isDark
                            ? AppColors.darkSurface
                            : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder), width: isSelected ? 1.2 : 0.5),
                      ),
                      child: Column(
                        children: [
                          Text(
                            mode.symbol,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.primary
                                  : isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mode.code,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 28),
        ],
      ),
    );
  }

  ///
  Widget _sectionLabel({required String label, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
      ),
    );
  }
}
