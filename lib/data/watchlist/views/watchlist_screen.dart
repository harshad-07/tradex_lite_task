import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../common/confirmation_dialog_box.dart';
import '../../../core/routes/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../market/provider/market_provider.dart';
import '../../market/views/list_elements/stock_tile.dart';
import '../provider/watchlist_provider.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  ///
  Future<bool> _confirmRemove(BuildContext context, String symbol) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmationDialogBox(title: 'Remove Stock', content: 'Remove $symbol from your watchlist?', elevatedButtonText: "Cancel", textButtonText: "Remove"),
    );

    return result ?? false;
  }

  void _confirmClearAll(BuildContext context, WatchlistProvider watchlist) async {
    final _res = await showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialogBox(title: 'Clear Watchlist', content: 'Remove all stocks from your watchlist?', elevatedButtonText: "Cancel", textButtonText: "Clear"),
    );

    if (_res == true) watchlist.clearAll();
  }

  ///
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final watchlist = context.watch<WatchlistProvider>();
    final market = context.watch<MarketProvider>();

    final watchedStocks = watchlist.items.map((item) => market.getStock(item.symbol)).where((s) => s != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          if (watchedStocks.isNotEmpty) IconButton(icon: const Icon(Icons.delete_sweep_outlined, size: 22), tooltip: 'Clear All', onPressed: () => _confirmClearAll(context, watchlist)),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.pushNamed(Routes.settings)),
        ],
      ),
      body: watchedStocks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 56, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(height: 16),
                  Text(
                    'No stocks in watchlist',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Swipe left on any stock in Market to add it here',
                    style: theme.textTheme.bodySmall?.copyWith(color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withValues(alpha: 0.7)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ── Count badge ────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '${watchedStocks.length} stock${watchedStocks.length != 1 ? 's' : ''}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Stock list ─────────────────────────────
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: watchedStocks.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemBuilder: (context, i) {
                      final stock = watchedStocks[i]!;
                      return Dismissible(
                        key: ValueKey('watchlist_${stock.symbol}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _confirmRemove(context, stock.symbol),
                        onDismissed: (_) => watchlist.remove(stock.symbol),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppColors.loss.withValues(alpha: 0.15),
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.loss),
                        ),
                        child: StockTile(key: ValueKey(stock.symbol), stock: stock),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
