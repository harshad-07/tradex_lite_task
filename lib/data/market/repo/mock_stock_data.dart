import '../models/index_model.dart';
import '../models/stock_model.dart';

abstract final class MockStockData {
  static List<IndexModel> getIndices() => [
    IndexModel(name: 'NIFTY 50', shortName: 'NIFTY', value: 24680.50, change: 132.40, changePercent: 0.54),
    IndexModel(name: 'SENSEX', shortName: 'SENSEX', value: 81245.30, change: 410.75, changePercent: 0.51),
    IndexModel(name: 'BANK NIFTY', shortName: 'BANKNIFTY', value: 53120.80, change: -185.60, changePercent: -0.35),
    IndexModel(name: 'NIFTY IT', shortName: 'NIFTYIT', value: 36450.20, change: 275.90, changePercent: 0.76),
  ];

  static List<StockModel> getStocks() => [
    _stock('TCS', 'Tata Consultancy Services', 'IT', 4125.60, 4098.00, 1842500, 1507200),
    _stock('INFY', 'Infosys', 'IT', 1580.35, 1565.20, 3254800, 656800),
    _stock('HCLTECH', 'HCL Technologies', 'IT', 1642.80, 1628.50, 1456200, 445700),
    _stock('WIPRO', 'Wipro', 'IT', 468.90, 462.15, 2876400, 244900),
    _stock('TECHM', 'Tech Mahindra', 'IT', 1385.40, 1372.60, 1245600, 135400),
    _stock('LTIM', 'LTIMindtree', 'IT', 5240.75, 5198.00, 456800, 155200),
    _stock('RELIANCE', 'Reliance Industries', 'Energy', 2945.30, 2918.50, 4567800, 1992500),
    _stock('HDFCBANK', 'HDFC Bank', 'Banking', 1685.20, 1672.40, 5234600, 1285600),
    _stock('ICICIBANK', 'ICICI Bank', 'Banking', 1245.80, 1232.60, 4876500, 876500),
    _stock('SBIN', 'State Bank of India', 'Banking', 825.40, 818.60, 6543200, 736800),
    _stock('KOTAKBANK', 'Kotak Mahindra Bank', 'Banking', 1842.50, 1825.80, 1876500, 365800),
    _stock('AXISBANK', 'Axis Bank', 'Banking', 1156.30, 1142.80, 3245600, 357200),
    _stock('INDUSINDBK', 'IndusInd Bank', 'Banking', 1478.60, 1465.20, 1234500, 112600),
    _stock('BAJFINANCE', 'Bajaj Finance', 'Finance', 6845.20, 6782.50, 876500, 424200),
    _stock('BAJFINSV', 'Bajaj Finserv', 'Finance', 1625.40, 1612.30, 654300, 259600),
    _stock('HDFCLIFE', 'HDFC Life Insurance', 'Insurance', 642.80, 636.50, 1876500, 138200),
    _stock('SBILIFE', 'SBI Life Insurance', 'Insurance', 1545.60, 1530.80, 987600, 154800),
    _stock('TATAMOTORS', 'Tata Motors', 'Auto', 985.40, 976.20, 4567800, 365200),
    _stock('MARUTI', 'Maruti Suzuki', 'Auto', 12450.30, 12380.00, 567800, 390800),
    _stock('M&M', 'Mahindra & Mahindra', 'Auto', 2685.70, 2662.40, 1876500, 333800),
    _stock('BAJAJ-AUTO', 'Bajaj Auto', 'Auto', 9245.80, 9178.50, 345600, 259700),
    _stock('EICHERMOT', 'Eicher Motors', 'Auto', 4562.30, 4528.60, 456700, 126200),
    _stock('HEROMOTOCO', 'Hero MotoCorp', 'Auto', 4825.60, 4792.40, 567800, 96500),
    _stock('SUNPHARMA', 'Sun Pharma', 'Pharma', 1685.40, 1668.20, 1876500, 404200),
    _stock('DRREDDY', 'Dr Reddys Labs', 'Pharma', 5842.60, 5798.40, 456700, 97400),
    _stock('CIPLA', 'Cipla', 'Pharma', 1465.80, 1452.30, 987600, 118200),
    _stock('DIVISLAB', 'Divis Laboratories', 'Pharma', 3856.40, 3824.60, 345600, 102400),
    _stock('APOLLOHOSP', 'Apollo Hospitals', 'Healthcare', 6245.30, 6198.50, 234500, 89700),
    _stock('HINDUNILVR', 'Hindustan Unilever', 'FMCG', 2485.60, 2462.80, 1245600, 583600),
    _stock('ITC', 'ITC', 'FMCG', 465.20, 461.40, 8765400, 581700),
    _stock('NESTLEIND', 'Nestle India', 'FMCG', 2542.80, 2518.60, 234500, 245100),
    _stock('BRITANNIA', 'Britannia Industries', 'FMCG', 5245.30, 5198.60, 345600, 126400),
    _stock('TATACONSUM', 'Tata Consumer', 'FMCG', 1085.40, 1072.60, 1456200, 105200),
    _stock('TATASTEEL', 'Tata Steel', 'Metals', 152.40, 150.80, 12345600, 188700),
    _stock('JSWSTEEL', 'JSW Steel', 'Metals', 892.60, 884.20, 2345600, 221500),
    _stock('HINDALCO', 'Hindalco Industries', 'Metals', 625.80, 618.40, 3456700, 140200),
    _stock('COALINDIA', 'Coal India', 'Metals', 438.60, 434.80, 4567800, 270600),
    _stock('ULTRACEMCO', 'UltraTech Cement', 'Cement', 10845.20, 10762.40, 234500, 313100),
    _stock('SHREECEM', 'Shree Cement', 'Cement', 26480.60, 26285.40, 45600, 95500),
    _stock('ADANIENT', 'Adani Enterprises', 'Conglomerate', 2845.30, 2822.60, 1876500, 324200),
    _stock('ADANIPORTS', 'Adani Ports', 'Infrastructure', 1285.60, 1274.20, 2345600, 278200),
    _stock('ONGC', 'Oil & Natural Gas Corp', 'Oil & Gas', 268.40, 265.80, 6789000, 337400),
    _stock('BPCL', 'Bharat Petroleum', 'Oil & Gas', 612.30, 606.80, 2345600, 133100),
    _stock('IOC', 'Indian Oil Corporation', 'Oil & Gas', 165.80, 164.20, 5678900, 234100),
    _stock('NTPC', 'NTPC', 'Power', 365.40, 362.20, 4567800, 354200),
    _stock('POWERGRID', 'Power Grid Corp', 'Power', 312.60, 309.80, 3456700, 290900),
    _stock('TATAPOWER', 'Tata Power', 'Power', 425.80, 422.40, 5678900, 136000),
    _stock('BHARTIARTL', 'Bharti Airtel', 'Telecom', 1625.40, 1608.60, 2345600, 975600),
    _stock('TITAN', 'Titan Company', 'Consumer', 3425.60, 3398.40, 876500, 304200),
    _stock('ASIANPAINT', 'Asian Paints', 'Consumer', 2845.30, 2822.60, 987600, 273000),
    _stock('LT', 'Larsen & Toubro', 'Capital Goods', 3542.80, 3512.40, 1234500, 486500),
  ];

  static StockModel _stock(String symbol, String name, String sector, double price, double prevClose, int volume, double marketCapCr) {
    final change = price - prevClose;
    final changePercent = (change / prevClose) * 100;
    final open = prevClose + (change * 0.3);
    final high = price + (price * 0.008);
    final low = prevClose - (prevClose * 0.005);

    return StockModel(
      symbol: symbol,
      name: name,
      sector: sector,
      price: price,
      change: change,
      changePercent: changePercent,
      open: double.parse(open.toStringAsFixed(2)),
      high: double.parse(high.toStringAsFixed(2)),
      low: double.parse(low.toStringAsFixed(2)),
      prevClose: prevClose,
      volume: volume,
      marketCap: marketCapCr,
    );
  }
}
