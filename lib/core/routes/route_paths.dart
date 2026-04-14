/// Route name constants
abstract final class Routes {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String market = 'market';
  static const String watchlist = 'watchlist';
  static const String portfolio = 'portfolio';
  static const String settings = 'settings';
  static const String stockDetail = 'stockDetail';
  static const String tradeHistory = 'tradeHistory';
}

/// Route path constants
abstract final class RoutePaths {
  static const String splash = '/';
  static const String login = '/login';
  static const String market = '/market';
  static const String watchlist = '/watchlist';
  static const String portfolio = '/portfolio';
  static const String settings = '/settings';
  static const String stockDetail = '/stock/:symbol';
  static const String tradeHistory = '/trades';
}
