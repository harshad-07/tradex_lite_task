import '../../../core/app_enums/app_enums.dart';

class TradeModel {
  final String id;
  final String symbol;
  final String name;
  final OrderType orderType;
  final int quantity;
  final double price;
  final TradeStatus status;
  final DateTime timestamp;

  const TradeModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.orderType,
    required this.quantity,
    required this.price,
    required this.status,
    required this.timestamp,
  });

  double get totalValue => price * quantity;
}
