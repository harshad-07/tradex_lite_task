import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/watchlist_item.dart';

class WatchlistProvider extends ChangeNotifier {
  static const String _boxName = 'watchlist';

  ///VARS
  Box<WatchlistItem>? _box;
  List<WatchlistItem> _items = [];

  ///GETTERS
  List<WatchlistItem> get items => _items;
  int get count => _items.length;

  ///
  Future<void> init() async {
    _box = await Hive.openBox<WatchlistItem>(_boxName);
    _items = (_box?.values ?? []).toList();
    notifyListeners();
  }

  ///
  bool isWatchlisted(String symbol) => _items.any((item) => item.symbol == symbol);

  Future<void> add(String symbol) async {
    if (isWatchlisted(symbol)) return;

    final item = WatchlistItem(symbol: symbol);
    await _box?.add(item);
    _items = (_box?.values ?? []).toList();
    notifyListeners();
  }

  Future<void> remove(String symbol) async {
    final index = _items.indexWhere((item) => item.symbol == symbol);
    if (index == -1) return;

    final item = _items[index];
    await item.delete();
    _items = (_box?.values ?? []).toList();
    notifyListeners();
  }

  Future<void> toggle(String symbol) async {
    if (isWatchlisted(symbol)) {
      await remove(symbol);
    } else {
      await add(symbol);
    }
  }

  Future<void> clearAll() async {
    await _box?.clear();
    _items = [];
    notifyListeners();
  }
}
