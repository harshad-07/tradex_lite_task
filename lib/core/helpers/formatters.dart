import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _priceFmt = NumberFormat('#,##0.00');
  static final _compactFmt = NumberFormat.compact();
  static final _percentFmt = NumberFormat('+0.00;-0.00');

  static String price(double v) => _priceFmt.format(v);
  static String compact(num v) => _compactFmt.format(v);
  static String percent(double v) => '${_percentFmt.format(v)}%';
  static String volume(num v) => _compactFmt.format(v);
}
