import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/helpers/formatters.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/stock_model.dart';
import '../../provider/market_provider.dart';

class StockTile extends StatefulWidget {
  const StockTile({super.key, required this.stock, this.onTap});

  final StockModel stock;
  final VoidCallback? onTap;

  @override
  State<StockTile> createState() => _StockTileState();
}

class _StockTileState extends State<StockTile> with SingleTickerProviderStateMixin {
  late AnimationController _flashCtrl;
  late Animation<Color?> _flashAnim;
  double _prevPrice = 0;

  @override
  void initState() {
    super.initState();
    _prevPrice = widget.stock.price;
    _flashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _flashAnim = ColorTween(begin: Colors.transparent, end: Colors.transparent).animate(_flashCtrl);
  }

  @override
  void didUpdateWidget(covariant StockTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newPrice = widget.stock.price;
    if (newPrice != _prevPrice) {
      final isUp = newPrice > _prevPrice;
      _flashAnim = ColorTween(begin: (isUp ? AppColors.gain : AppColors.loss).withValues(alpha: 0.18), end: Colors.transparent).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));
      _flashCtrl.forward(from: 0);
      _prevPrice = newPrice;
    }
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stock = widget.stock;
    final market = context.read<MarketProvider>();

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

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _flashAnim,
        builder: (context, child) => Material(color: _flashAnim.value ?? Colors.transparent, child: child, clipBehavior: Clip.antiAlias, borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          onTap: widget.onTap ?? () => context.pushNamed(Routes.stockDetail, pathParameters: {'symbol': stock.symbol}),
          child: Container(
            clipBehavior: Clip.antiAlias,
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.7),
            ),
            child: Row(
              children: [
                ///
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(stock.symbol, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        stock.name,
                        style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                ///
                Expanded(
                  flex: 2,
                  child: Text(
                    Formatters.compact(stock.volume),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 11),
                  ),
                ),

                ///
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(market.formatPrice(stock.price), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: changeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '$arrow ${market.formatChange(stock.change)} (${stock.changePercent.abs().toStringAsFixed(2)}%)',
                          style: TextStyle(color: changeColor, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
