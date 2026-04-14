import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/auth/provider/auth_provider.dart';
import '../../data/auth/views/login_screen.dart';
import '../../data/auth/views/splash_screen.dart';
import '../../data/home/views/main_nav_bar.dart';
import '../../data/market/views/market_watch_screen.dart';
import '../../data/market/views/stock_detail_screen.dart';
import '../../data/settings/views/settings_screen.dart';
import '../../data/trades/views/trade_history_screen.dart';
import '../../data/watchlist/views/watchlist_screen.dart';
import '../app_enums/app_enums.dart';
import 'route_paths.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final currentPath = state.matchedLocation;

      if (status == AuthStatus.splash) {
        if (currentPath != RoutePaths.splash) return RoutePaths.splash;
        return null;
      }

      if (status == AuthStatus.authenticated) {
        if (currentPath == RoutePaths.splash || currentPath == RoutePaths.login) {
          return RoutePaths.market;
        }
        return null;
      }

      if (status == AuthStatus.pendingBiometric) {
        return null;
      }

      if (currentPath != RoutePaths.login) {
        return RoutePaths.login;
      }

      return null;
    },
    routes: [
      ///AUTH
      GoRoute(path: RoutePaths.splash, name: Routes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: RoutePaths.login, name: Routes.login, builder: (context, state) => const LoginScreen()),

      ///MAIN NAV BAR
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return MainNavBar(navigationShell: navigationShell);
        },
        branches: [
          // 1 — Market
          StatefulShellBranch(
            routes: [GoRoute(path: RoutePaths.market, name: Routes.market, builder: (context, state) => const MarketWatchScreen())],
          ),

          // 2 — Watchlist
          StatefulShellBranch(
            routes: [GoRoute(path: RoutePaths.watchlist, name: Routes.watchlist, builder: (context, state) => const WatchlistScreen())],
          ),

          // 3 — Trade History
          StatefulShellBranch(
            routes: [GoRoute(path: RoutePaths.tradeHistory, name: Routes.tradeHistory, builder: (context, state) => const TradeHistoryScreen())],
          ),
        ],
      ),

      ///OTHER
      GoRoute(parentNavigatorKey: _rootNavigatorKey, path: RoutePaths.settings, name: Routes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.stockDetail,
        name: Routes.stockDetail,
        builder: (context, state) {
          final symbol = state.pathParameters['symbol'] ?? '';
          return StockDetailScreen(symbol: symbol);
        },
      ),
    ],
  );
}
