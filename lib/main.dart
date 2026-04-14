import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/theme_provider.dart';
import 'data/auth/provider/auth_provider.dart';
import 'data/market/provider/market_provider.dart';
import 'data/trades/provider/trade_provider.dart';
import 'data/watchlist/models/watchlist_item.dart';
import 'data/watchlist/provider/watchlist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive init ────────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(WatchlistItemAdapter());

  // Pre-open the box so the provider is ready synchronously
  final watchlistProvider = WatchlistProvider();
  final authProvider = AuthProvider();
  await watchlistProvider.init();
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider.value(value: watchlistProvider),
        ChangeNotifierProvider(create: (_) => TradeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router ??= createRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(title: "TradeX Lite", debugShowCheckedModeBanner: false, themeMode: themeProvider.mode, theme: buildLightTheme(), darkTheme: buildDarkTheme(), routerConfig: _router!);
  }
}
