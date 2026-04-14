class CandleData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  const CandleData({required this.time, required this.open, required this.high, required this.low, required this.close, this.volume = 0});

  bool get isBullish => close >= open;
}
