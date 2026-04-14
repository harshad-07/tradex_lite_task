import 'package:hive/hive.dart';

part 'watchlist_item.g.dart';

@HiveType(typeId: 0)
class WatchlistItem extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final DateTime addedAt;

  WatchlistItem({required this.symbol, DateTime? addedAt}) : addedAt = addedAt ?? DateTime.now();
}
