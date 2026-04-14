import 'dart:ui';

import '../theme/app_colors.dart';

enum AuthStatus { splash, initial, loading, pendingBiometric, authenticated, error }

enum AppBiometricType { fingerprint, face, none }

enum AppAuthResult { success, cancelled, lockedOut, permanentlyLockedOut, failed }

enum SortBy { name, price, change, changePercent, volume }

enum SortOrder { asc, desc }

enum RefreshInterval {
  s1('1s', 1000),
  s3('3s', 3000),
  s5('5s', 5000),
  s10('10s', 10000),
  s30('30s', 30000);

  const RefreshInterval(this.label, this.ms);
  final String label;
  final int ms;
}

enum CurrencyMode {
  inr('INR', '₹', 1.0),
  usd('USD', '\$', 0.01075);

  const CurrencyMode(this.code, this.symbol, this.rate);
  final String code;
  final String symbol;
  final double rate;
}

enum OrderType {
  buy('BUY'),
  sell('SELL');

  const OrderType(this.label);
  final String label;
}

enum TradeFilter { all, executed, pending, cancelled, rejected }

enum TradeStatus {
  executed('Executed'),
  pending('Pending'),
  cancelled('Cancelled'),
  rejected('Rejected');

  const TradeStatus(this.label);
  final String label;
}

Color statusColor(TradeStatus status) {
  return switch (status) {
    TradeStatus.executed => AppColors.gain,
    TradeStatus.pending => AppColors.warning,
    TradeStatus.cancelled => AppColors.neutral,
    TradeStatus.rejected => AppColors.loss,
  };
}
