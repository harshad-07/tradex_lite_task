class StockModel {
  final String symbol;
  final String name;
  final String sector;
  double price;
  double change;
  double changePercent;
  double open;
  double high;
  double low;
  double prevClose;
  int volume;
  double marketCap;

  StockModel({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.prevClose,
    required this.volume,
    required this.marketCap,
  });

  bool get isUp => change > 0;
  bool get isDown => change < 0;
  bool get isNeutral => change == 0;

  void tick(double newPrice) {
    price = newPrice;
    change = price - prevClose;
    changePercent = (change / prevClose) * 100;
    if (price > high) high = price;
    if (price < low) low = price;
  }
}
