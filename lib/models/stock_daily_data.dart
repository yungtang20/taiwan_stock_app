/// 每日股票數據模型
class StockDailyData {
  final String code;
  final DateTime date;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final int? volume;

  StockDailyData({
    required this.code,
    required this.date,
    this.open,
    this.high,
    this.low,
    this.close,
    this.volume,
  });

  /// 從 JSON 創建 StockDailyData 對象
  factory StockDailyData.fromJson(Map<String, dynamic> json) {
    return StockDailyData(
      code: json['code'] as String,
      date: DateTime.parse(json['date']),
      open: json['open'] != null ? (json['open'] as num).toDouble() : null,
      high: json['high'] != null ? (json['high'] as num).toDouble() : null,
      low: json['low'] != null ? (json['low'] as num).toDouble() : null,
      close: json['close'] != null ? (json['close'] as num).toDouble() : null,
      volume: json['volume'] as int?,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'date': date.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }

  /// 是否為上漲
  bool get isRising {
    if (open == null || close == null) return false;
    return close! >= open!;
  }

  /// 漲跌幅
  double? get changePercent {
    if (open == null || close == null || open == 0) return null;
    return ((close! - open!) / open!) * 100;
  }

  @override
  String toString() {
    return 'StockDailyData(code: $code, date: $date, close: $close)';
  }
}
