class IndexModel {
  final String name;
  final String shortName;
  double value;
  double change;
  double changePercent;

  IndexModel({required this.name, required this.shortName, required this.value, required this.change, required this.changePercent});

  bool get isUp => change > 0;

  void tick(double newValue) {
    final prev = value - change;
    value = newValue;
    change = value - prev;
    changePercent = (change / prev) * 100;
  }
}
