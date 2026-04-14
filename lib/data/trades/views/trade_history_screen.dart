import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/app_enums/app_enums.dart';
import '../../../core/routes/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../market/provider/market_provider.dart';
import '../models/trade_model.dart';
import '../provider/trade_provider.dart';

class TradeHistoryScreen extends StatelessWidget {
  const TradeHistoryScreen({super.key});

  static final _timeFmt = DateFormat('dd MMM · hh:mm a');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tradeProv = context.watch<TradeProvider>();
    final market = context.read<MarketProvider>();
    final trades = tradeProv.trades;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade History'),
        actions: [IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.pushNamed(Routes.settings))],
      ),
      body: Column(
        children: [
          // ── Filter chips ─────────────────────────────────
          _filterChip(current: tradeProv.filter, tradeProv: tradeProv, isDark: isDark),
          const SizedBox(height: 8),

          // ── Trade count ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [Text('${trades.length} trade${trades.length != 1 ? 's' : ''}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))],
            ),
          ),

          // ── Trade list ───────────────────────────────────
          Expanded(
            child: trades.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        const SizedBox(height: 12),
                        Text('No trades found', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: trades.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final trade = trades[i];
                      return RepaintBoundary(
                        child: _tradeTile(trade: trade, theme: theme, market: market),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({required TradeFilter current, required TradeProvider tradeProv, required bool isDark}) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: TradeFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = TradeFilter.values[i];
          final isSelected = filter == current;
          final count = tradeProv.countByStatus(filter);
          final label = switch (filter) {
            TradeFilter.all => 'All',
            TradeFilter.executed => 'Executed',
            TradeFilter.pending => 'Pending',
            TradeFilter.cancelled => 'Cancelled',
            TradeFilter.rejected => 'Rejected',
          };

          return GestureDetector(
            onTap: () => tradeProv.setFilter(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : isDark
                    ? AppColors.darkCard
                    : AppColors.lightCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    label,
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
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : (isDark ? AppColors.darkBorder : AppColors.lightBorder).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tradeTile({required TradeModel trade, required ThemeData theme, required MarketProvider market}) {
    final isDark = theme.brightness == Brightness.dark;

    final isBuy = trade.orderType == OrderType.buy;
    final orderColor = isBuy ? AppColors.gain : AppColors.loss;
    final _statusColor = statusColor(trade.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: orderColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5)),
                child: Text(
                  trade.orderType.label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: orderColor),
                ),
              ),
              const SizedBox(width: 10),
              Text(trade.symbol, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  trade.name,
                  style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5)),
                child: Text(
                  trade.status.label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ///
          Row(
            children: [
              _detailCell(label: 'Qty', value: '${trade.quantity}', theme: theme),
              _detailCell(label: 'Price', value: market.formatPrice(trade.price), theme: theme),
              _detailCell(
                label: 'Value',
                value: market.formatPrice(trade.totalValue),
                theme: theme,
                valueStyle: GoogleFonts.spaceMono(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ///
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(_timeFmt.format(trade.timestamp), style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              const Spacer(),
              Text(
                '#${trade.id}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withValues(alpha: 0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailCell({required String label, required String value, required ThemeData theme, TextStyle? valueStyle}) {
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 3),
          Text(value, style: valueStyle ?? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
