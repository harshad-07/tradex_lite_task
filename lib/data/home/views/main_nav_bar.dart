import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../watchlist/provider/watchlist_provider.dart';

class MainNavBar extends StatelessWidget {
  const MainNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final watchlist = context.watch<WatchlistProvider>();

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.candlestick_chart_rounded), label: 'Market'),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: watchlist.count > 0,
                label: Text('${watchlist.count}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                backgroundColor: AppColors.primary,
                textColor: Colors.black,
                child: const Icon(Icons.bookmark_rounded),
              ),
              label: 'Watchlist',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Trades'),
          ],
        ),
      ),
    );
  }
}
