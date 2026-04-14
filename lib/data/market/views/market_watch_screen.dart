import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tradex_lite/core/utils/globals.dart';

import '../../../core/app_enums/app_enums.dart';
import '../../../core/routes/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../watchlist/provider/watchlist_provider.dart';
import '../provider/market_provider.dart';
import 'list_elements/index_banner.dart';
import 'list_elements/market_settings_sheet.dart';
import 'list_elements/stock_tile.dart';

class MarketWatchScreen extends StatefulWidget {
  const MarketWatchScreen({super.key});

  @override
  State<MarketWatchScreen> createState() => _MarketWatchScreenState();
}

class _MarketWatchScreenState extends State<MarketWatchScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final market = context.watch<MarketProvider>();
    final watchlist = context.watch<WatchlistProvider>();
    final stocks = market.stocks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Watch'),
        actions: [
          GestureDetector(
            onTap: market.toggleMarket,
            child: Container(
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
          ),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.pushNamed(Routes.settings)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///
          IndexBanner(indices: market.indices),
          const SizedBox(height: 12),

          ///
          _marketSearchBar(controller: _searchCtrl, onChanged: market.setSearchQuery, onClear: market.clearSearch),
          const SizedBox(height: 12),

          ///
          _sectorFilterChips(sectors: market.sectors, selected: market.selectedSector, onSelected: market.setSector),
          const SizedBox(height: 8),

          ///
          _sortingWidgets(count: stocks.length, sortBy: market.sortBy, sortOrder: market.sortOrder, onSort: market.setSort),

          ///
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: []),
          ),

          ///
          Expanded(
            child: stocks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        const SizedBox(height: 12),
                        Text('No stocks found', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      ],
                    ),
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemCount: stocks.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemBuilder: (context, i) {
                      final stock = stocks[i];
                      final isWatchlisted = watchlist.isWatchlisted(stock.symbol);

                      return Dismissible(
                        key: ValueKey('market_${stock.symbol}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          if (isWatchlisted) {
                            showToast(context, "${stock.symbol} is already in your watchlist", icon: const Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 18));
                          } else {
                            await watchlist.add(stock.symbol);
                            if (context.mounted) {
                              showToast(context, "${stock.symbol} added to watchlist", icon: const Icon(Icons.bookmark_add_rounded, color: AppColors.primary, size: 18));
                            }
                          }
                          return false;
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: isWatchlisted ? AppColors.neutral.withValues(alpha: 0.10) : AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(isWatchlisted ? Icons.bookmark_rounded : Icons.bookmark_add_rounded, color: isWatchlisted ? AppColors.neutral : AppColors.primary),
                        ),
                        child: StockTile(key: ValueKey(stock.symbol), stock: stock),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => MarketSettingsSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        elevation: 4,
        child: const Icon(Icons.tune_rounded, size: 22),
      ),
    );
  }

  ///
  Widget _marketSearchBar({required TextEditingController controller, required ValueChanged<String> onChanged, required VoidCallback onClear}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search stocks...',
          hintStyle: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, size: 18),
                  onPressed: () {
                    controller.clear();
                    onClear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _sectorFilterChips({required List<String> sectors, required String selected, required ValueChanged<String> onSelected}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sectors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sector = sectors[i];
          final isSelected = sector == selected;

          return GestureDetector(
            onTap: () => onSelected(sector),
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
              child: Text(
                sector,
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
            ),
          );
        },
      ),
    );
  }

  Widget _sortingWidgets({required int count, required SortBy sortBy, required SortOrder sortOrder, required ValueChanged<SortBy> onSort}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBg,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: [
                _sortChip(label: 'Stock', field: SortBy.name, current: sortBy, order: sortOrder, onTap: onSort, color: secondary),
                _sortChip(label: 'Volume', field: SortBy.volume, current: sortBy, order: sortOrder, onTap: onSort, color: secondary),
                _sortChip(label: 'Price / Change', field: SortBy.changePercent, current: sortBy, order: sortOrder, onTap: onSort, color: secondary),
              ],
            ),
          ),
          Text('$count stocks', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        ],
      ),
    );
  }

  Widget _sortChip({required String label, required SortBy field, required SortBy current, required SortOrder order, required ValueChanged<SortBy> onTap, required Color color}) {
    final isActive = current == field;
    final arrow = isActive ? (order == SortOrder.asc ? ' ↑' : ' ↓') : '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onTap(field),
      borderRadius: BorderRadius.circular(18),
      highlightColor: AppColors.primary.withValues(alpha: 0.27),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : isDark
              ? AppColors.darkCard
              : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.5)
                : isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          '$label$arrow',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w900 : FontWeight.w500, color: isActive ? AppColors.primary : color),
        ),
      ),
    );
  }
}
