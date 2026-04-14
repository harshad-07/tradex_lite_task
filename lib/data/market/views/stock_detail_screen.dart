import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/helpers/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../watchlist/provider/watchlist_provider.dart';
import '../models/stock_model.dart';
import '../provider/market_provider.dart';
import 'detail_elements/candle_chart.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({super.key, required this.symbol});

  final String symbol;

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketProvider>().getCandleData(widget.symbol);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final market = context.watch<MarketProvider>();
    final watchlist = context.watch<WatchlistProvider>();
    final stock = market.getStock(widget.symbol);

    if (stock == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Stock not found')),
      );
    }

    final isWatchlisted = watchlist.isWatchlisted(stock.symbol);
    final changeColor = stock.isUp
        ? AppColors.gain
        : stock.isDown
        ? AppColors.loss
        : AppColors.neutral;
    final arrow = stock.isUp
        ? '▲'
        : stock.isDown
        ? '▼'
        : '';
    final candles = market.getCandleData(widget.symbol);

    return Scaffold(
      appBar: AppBar(
        title: Text(stock.symbol),
        actions: [
          ///
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(isWatchlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, key: ValueKey(isWatchlisted), color: isWatchlisted ? AppColors.primary : null, size: 24),
            ),
            tooltip: isWatchlisted ? 'Remove from Watchlist' : 'Add to Watchlist',
            onPressed: () => watchlist.toggle(stock.symbol),
          ),

          ///
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: market.isMarketOpen ? AppColors.gain.withValues(alpha: 0.12) : AppColors.loss.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: market.isMarketOpen ? AppColors.gain : AppColors.loss, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  market.isMarketOpen ? 'LIVE' : 'CLOSED',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: market.isMarketOpen ? AppColors.gain : AppColors.loss),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            ///
            RepaintBoundary(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stock.name, style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      stock.sector,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ///
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  market.formatPrice(stock.price),
                  style: GoogleFonts.spaceMono(fontSize: 32, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: changeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '$arrow ${market.formatChange(stock.change)} (${stock.changePercent.abs().toStringAsFixed(2)}%)',
                      style: TextStyle(color: changeColor, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ///
            RepaintBoundary(
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: Text(
                        'Intraday  ·  5min candles',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                    CandleChart(candles: candles, prevClose: stock.prevClose, currencySymbol: market.currency.symbol),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            ///
            RepaintBoundary(child: _stockStatsGrid(stock: stock)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  ///
  Widget _stockStatsGrid({required StockModel stock}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final market = context.read<MarketProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _statItem(label: 'Open', value: market.formatPrice(stock.open), isDark: isDark),
              _statItem(label: 'High', value: market.formatPrice(stock.high), isDark: isDark, valueColor: AppColors.gain),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem(label: 'Low', value: market.formatPrice(stock.low), isDark: isDark, valueColor: AppColors.loss),
              _statItem(label: 'Prev Close', value: market.formatPrice(stock.prevClose), isDark: isDark),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: (isDark ? AppColors.darkBorder : AppColors.lightBorder).withValues(alpha: 0.6)),
          ),
          Row(
            children: [
              _statItem(label: 'Volume', value: Formatters.compact(stock.volume), isDark: isDark),
              _statItem(label: 'Mkt Cap', value: '${market.currency.symbol}${Formatters.compact(stock.marketCap * market.currency.rate)} Cr', isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({required String label, required String value, required bool isDark, Color? valueColor}) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: valueColor),
          ),
        ],
      ),
    );
  }
}
