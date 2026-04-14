import 'dart:math';

import '../models/chart_data.dart';
import '../models/stock_model.dart';

abstract final class MockChartData {
  static final _random = Random();

  static const int maxCandles = 80;

  static List<CandleData> generateIntraday(StockModel stock) {
    final now = DateTime.now();
    final marketOpen = DateTime(now.year, now.month, now.day, 9, 15);
    final marketClose = DateTime(now.year, now.month, now.day, 15, 30);
    final endTime = now.isBefore(marketClose) ? now : marketClose;

    final totalMinutes = endTime.difference(marketOpen).inMinutes;
    if (totalMinutes <= 0) {
      final p = stock.prevClose;
      final tiny = p * 0.001;
      return List.generate(5, (i) {
        final offset = (_random.nextDouble() - 0.5) * tiny;
        final o = _round(p + offset);
        final c = _round(p + offset * 0.8);
        return CandleData(
          time: marketOpen.add(Duration(minutes: i * 5)),
          open: o,
          high: _round(max(o, c) + tiny.abs()),
          low: _round(min(o, c) - tiny.abs()),
          close: c,
          volume: 1000 + _random.nextInt(5000),
        );
      });
    }

    final candleCount = (totalMinutes / 5).ceil().clamp(1, maxCandles);
    final candles = <CandleData>[];

    final drift = (stock.price - stock.open) / candleCount;
    final volatility = stock.price * 0.0015;
    double current = stock.open;

    for (var i = 0; i < candleCount; i++) {
      final candleTime = marketOpen.add(Duration(minutes: i * 5));
      final open = current;

      double high = open;
      double low = open;
      double close = open;

      for (var t = 0; t < 4; t++) {
        final noise = (_random.nextDouble() - 0.48) * volatility;
        close += drift / 4 + noise;
        if (close > high) high = close;
        if (close < low) low = close;
      }

      high = high.clamp(stock.low, stock.high * 1.002);
      low = low.clamp(stock.low * 0.998, stock.high);
      if (low > high) low = high;
      if (high == low) high = low + 0.01; // prevent zero-range
      close = close.clamp(low, high);

      candles.add(CandleData(time: candleTime, open: _round(open), high: _round(high), low: _round(low), close: _round(close), volume: _random.nextInt(50000) + 5000));

      current = close;
    }

    if (candles.isNotEmpty) {
      final last = candles.last;
      candles[candles.length - 1] = CandleData(time: last.time, open: last.open, high: max(last.high, stock.price), low: min(last.low, stock.price), close: stock.price, volume: last.volume);
    }

    return candles;
  }

  static bool appendTick(List<CandleData> candles, StockModel stock) {
    if (candles.isEmpty) return false;

    final now = DateTime.now();
    final last = candles.last;
    final elapsed = now.difference(last.time).inMinutes;

    if (elapsed >= 5) {
      final basePrice = stock.price.isFinite && stock.price > 0 ? stock.price : last.close;
      final spread = (basePrice * 0.0005).clamp(0.01, double.infinity);
      final newLow = (basePrice - spread).clamp(0.01, double.infinity);
      candles.add(CandleData(time: now, open: last.close, high: basePrice + spread, low: newLow, close: basePrice, volume: _random.nextInt(20000) + 2000));
      if (candles.length > maxCandles) {
        candles.removeAt(0);
      }
    } else {
      candles[candles.length - 1] = CandleData(
        time: last.time,
        open: last.open,
        high: max(last.high, stock.price),
        low: min(last.low, stock.price),
        close: stock.price,
        volume: last.volume + _random.nextInt(500),
      );
    }
    return true;
  }

  static double _round(double v, {double fallback = 0.01}) {
    if (!v.isFinite) return fallback;
    final rounded = double.parse(v.toStringAsFixed(2));
    return rounded > 0 ? rounded : fallback;
  }
}
