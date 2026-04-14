import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../../core/app_enums/app_enums.dart';
import '../models/chart_data.dart';
import '../models/index_model.dart';
import '../models/stock_model.dart';
import '../repo/mock_chart_data.dart';
import '../repo/mock_stock_data.dart';

class MarketProvider extends ChangeNotifier with WidgetsBindingObserver {
  MarketProvider() {
    _init();
    WidgetsBinding.instance.addObserver(this);
  }

  ///VARS
  List<StockModel> _allStocks = [];
  List<IndexModel> _indices = [];
  final _random = Random();

  final Map<String, List<CandleData>> _candleCache = {};

  String _searchQuery = '';
  String _selectedSector = 'All';
  SortBy _sortBy = SortBy.name;
  SortOrder _sortOrder = SortOrder.asc;

  List<StockModel>? _cachedStocks;
  bool _filtersDirty = true;

  Timer? _tickTimer;
  bool _isMarketOpen = true;

  Timer? _searchDebounce;

  RefreshInterval _selectedRefreshInterval = RefreshInterval.s3;
  CurrencyMode _currency = CurrencyMode.inr;

  ///GETTERS
  List<IndexModel> get indices => _indices;
  String get searchQuery => _searchQuery;
  String get selectedSector => _selectedSector;
  SortBy get sortBy => _sortBy;
  SortOrder get sortOrder => _sortOrder;
  bool get isMarketOpen => _isMarketOpen;
  RefreshInterval get selectedRefreshInterval => _selectedRefreshInterval;
  CurrencyMode get currency => _currency;

  String formatPrice(double inrPrice) {
    final converted = inrPrice * _currency.rate;
    return '${_currency.symbol}${converted.toStringAsFixed(2)}';
  }

  String formatChange(double inrChange) {
    final converted = inrChange.abs() * _currency.rate;
    return converted.toStringAsFixed(2);
  }

  StockModel? getStock(String symbol) {
    try {
      return _allStocks.firstWhere((s) => s.symbol == symbol);
    } catch (_) {
      return null;
    }
  }

  List<CandleData> getCandleData(String symbol) {
    if (!_candleCache.containsKey(symbol)) {
      final stock = getStock(symbol);
      if (stock == null) return [];
      _candleCache[symbol] = MockChartData.generateIntraday(stock);
    }
    return _candleCache[symbol]!;
  }

  List<String> get sectors {
    final set = <String>{'All'};
    for (final s in _allStocks) {
      set.add(s.sector);
    }
    return set.toList();
  }

  List<StockModel> get stocks {
    if (!_filtersDirty && _cachedStocks != null) return _cachedStocks!;

    var list = List<StockModel>.from(_allStocks);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) => s.symbol.toLowerCase().contains(q) || s.name.toLowerCase().contains(q)).toList();
    }

    if (_selectedSector != 'All') {
      list = list.where((s) => s.sector == _selectedSector).toList();
    }

    list.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case SortBy.name:
          cmp = a.symbol.compareTo(b.symbol);
        case SortBy.price:
          cmp = a.price.compareTo(b.price);
        case SortBy.change:
          cmp = a.change.compareTo(b.change);
        case SortBy.changePercent:
          cmp = a.changePercent.compareTo(b.changePercent);
        case SortBy.volume:
          cmp = a.volume.compareTo(b.volume);
      }
      return _sortOrder == SortOrder.asc ? cmp : -cmp;
    });

    _cachedStocks = list;
    _filtersDirty = false;
    return list;
  }

  void _init() {
    _allStocks = MockStockData.getStocks();
    _indices = MockStockData.getIndices();
    _startTicker();
  }

  void _startTicker() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(Duration(milliseconds: _selectedRefreshInterval.ms), (_) {
      if (!_isMarketOpen) return;
      _simulateTick();
    });
  }

  void _simulateTick() {
    final count = 5 + _random.nextInt(6);
    final updatedSymbols = <String>{};

    for (var i = 0; i < count && i < _allStocks.length; i++) {
      final idx = _random.nextInt(_allStocks.length);
      final stock = _allStocks[idx];

      final maxMove = stock.price * 0.003;
      final delta = (_random.nextDouble() * maxMove * 2) - maxMove;
      final newPrice = double.parse((stock.price + delta).toStringAsFixed(2));

      if (newPrice > 0) {
        stock.tick(newPrice);
        stock.volume += _random.nextInt(5000) - 2000;
        if (stock.volume < 0) stock.volume = _random.nextInt(100000);
        updatedSymbols.add(stock.symbol);
      }
    }

    for (final sym in updatedSymbols) {
      final candles = _candleCache[sym];
      if (candles != null) {
        final stock = getStock(sym);
        if (stock != null) {
          MockChartData.appendTick(candles, stock);
        }
      }
    }

    for (final index in _indices) {
      final maxMove = index.value * 0.001;
      final delta = (_random.nextDouble() * maxMove * 2) - maxMove;
      index.tick(double.parse((index.value + delta).toStringAsFixed(2)));
    }

    _filtersDirty = true;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _searchQuery = query;
      _filtersDirty = true;
      notifyListeners();
    });
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    _searchQuery = '';
    _filtersDirty = true;
    notifyListeners();
  }

  void setSector(String sector) {
    _selectedSector = sector;
    _filtersDirty = true;
    notifyListeners();
  }

  void setSort(SortBy by) {
    if (_sortBy == by) {
      _sortOrder = _sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc;
    } else {
      _sortBy = by;
      _sortOrder = SortOrder.asc;
    }
    _filtersDirty = true;
    notifyListeners();
  }

  void toggleMarket() {
    _isMarketOpen = !_isMarketOpen;
    notifyListeners();
  }

  void clearCandleCache(String symbol) {
    _candleCache.remove(symbol);
  }

  void setRefreshInterval(RefreshInterval interval) {
    _selectedRefreshInterval = interval;
    _startTicker();
    notifyListeners();
  }

  void setCurrency(CurrencyMode mode) {
    _currency = mode;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _tickTimer?.cancel();
        _tickTimer = null;
      case AppLifecycleState.resumed:
        if (_tickTimer == null && _isMarketOpen) {
          _startTicker();
        }
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _searchDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
