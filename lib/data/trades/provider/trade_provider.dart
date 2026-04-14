import 'package:flutter/foundation.dart';

import '../../../core/app_enums/app_enums.dart';
import '../models/trade_model.dart';
import '../repo/mock_trade_data.dart';

class TradeProvider extends ChangeNotifier {
  TradeProvider() {
    _trades = MockTradeData.getTrades();
  }

  List<TradeModel> _trades = [];
  TradeFilter _filter = TradeFilter.all;

  ///GETTERS
  TradeFilter get filter => _filter;

  List<TradeModel> get trades {
    if (_filter == TradeFilter.all) return _trades;

    final status = switch (_filter) {
      TradeFilter.executed => TradeStatus.executed,
      TradeFilter.pending => TradeStatus.pending,
      TradeFilter.cancelled => TradeStatus.cancelled,
      TradeFilter.rejected => TradeStatus.rejected,
      TradeFilter.all => null,
    };

    if (status == null) return _trades;
    return _trades.where((t) => t.status == status).toList();
  }

  ///SETTER
  void setFilter(TradeFilter f) {
    _filter = f;
    notifyListeners();
  }

  int countByStatus(TradeFilter f) {
    if (f == TradeFilter.all) return _trades.length;
    final status = switch (f) {
      TradeFilter.executed => TradeStatus.executed,
      TradeFilter.pending => TradeStatus.pending,
      TradeFilter.cancelled => TradeStatus.cancelled,
      TradeFilter.rejected => TradeStatus.rejected,
      TradeFilter.all => null,
    };
    if (status == null) return _trades.length;
    return _trades.where((t) => t.status == status).length;
  }
}
