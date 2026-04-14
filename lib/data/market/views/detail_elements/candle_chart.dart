import 'dart:async';

import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';

import '../../models/chart_data.dart';

class CandleChart extends StatefulWidget {
  const CandleChart({super.key, required this.candles, required this.prevClose, this.currencySymbol = '₹', this.height = 300});

  final List<CandleData> candles;
  final double prevClose;
  final String currencySymbol;
  final double height;

  @override
  State<CandleChart> createState() => _CandleChartState();
}

class _CandleChartState extends State<CandleChart> {
  static const int _minCandles = 30;

  static const Duration _tickThrottle = Duration(seconds: 2);

  List<Candle> _packageCandles = [];
  Timer? _throttle;

  @override
  void initState() {
    super.initState();
    _packageCandles = _build(widget.candles, widget.prevClose);
  }

  @override
  void didUpdateWidget(CandleChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    final countChanged = widget.candles.length != oldWidget.candles.length;

    if (countChanged) {
      _throttle?.cancel();
      _throttle = null;
      setState(() => _packageCandles = _build(widget.candles, widget.prevClose));
    } else {
      _throttle ??= Timer(_tickThrottle, () {
        _throttle = null;
        if (mounted) {
          setState(() => _packageCandles = _build(widget.candles, widget.prevClose));
        }
      });
    }
  }

  @override
  void dispose() {
    _throttle?.cancel();
    super.dispose();
  }

  List<Candle> _build(List<CandleData> candles, double prevClose) {
    if (candles.isEmpty) return [];

    final fallback = prevClose.isFinite && prevClose > 0 ? prevClose : 1.0;

    double sanitize(double v) => (v.isFinite && v > 0) ? v : fallback;

    final raw = candles.map((c) {
      final o = sanitize(c.open);
      final cl = sanitize(c.close);
      var hi = sanitize(c.high);
      var lo = sanitize(c.low);

      if (hi <= lo) hi = lo + 0.01;

      return Candle(date: c.time, open: o.clamp(lo, hi), high: hi, low: lo, close: cl.clamp(lo, hi), volume: c.volume.toDouble());
    }).toList();

    if (raw.length < _minCandles) {
      final first = raw.first;
      final padBase = first.open.isFinite && first.open > 0 ? first.open : fallback;
      final padCount = _minCandles - raw.length;

      final padded = List<Candle>.generate(padCount, (i) {
        final lo = (padBase - 0.01).clamp(0.01, double.infinity);
        return Candle(
          date: first.date.subtract(Duration(minutes: (padCount - i) * 5)),
          open: padBase,
          high: padBase + 0.01,
          low: lo,
          close: padBase,
          volume: 0,
        );
      });

      raw.insertAll(0, padded);
    }

    return raw.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_packageCandles.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('Waiting for candle data...')),
      );
    }

    return SizedBox(
      height: widget.height,
      child: RepaintBoundary(
        child: Candlesticks(key: ValueKey(_packageCandles.length), candles: _packageCandles),
      ),
    );
  }
}
