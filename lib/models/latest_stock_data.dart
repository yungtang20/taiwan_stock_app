/// 最新股票數據模型 (整合所有資訊)
class LatestStockData {
  final String code;
  final String name;
  final String market;
  final DateTime? date;
  final double? close;
  final int? volume;
  final double? ma20;
  final double? ma200;
  final double? mfi14;
  final double? changePct;
  final double? change14d;
  final double? buyPrice;
  final double? stopPrice;
  final double? sellPrice;
  final double? profitLossRatio;
  final String? signalType;

  LatestStockData({
    required this.code,
    required this.name,
    required this.market,
    this.date,
    this.close,
    this.volume,
    this.ma20,
    this.ma200,
    this.mfi14,
    this.changePct,
    this.change14d,
    this.buyPrice,
    this.stopPrice,
    this.sellPrice,
    this.profitLossRatio,
    this.signalType,
  });

  /// 從 JSON 創建 LatestStockData 對象
  factory LatestStockData.fromJson(Map<String, dynamic> json) {
    return LatestStockData(
      code: json['code'] as String,
      name: json['name'] as String,
      market: json['market'] as String,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      close: json['close'] != null ? (json['close'] as num).toDouble() : null,
      volume: json['volume'] as int?,
      ma20: json['ma20'] != null ? (json['ma20'] as num).toDouble() : null,
      ma200: json['ma200'] != null ? (json['ma200'] as num).toDouble() : null,
      mfi14: json['mfi14'] != null ? (json['mfi14'] as num).toDouble() : null,
      changePct: json['change_pct'] != null ? (json['change_pct'] as num).toDouble() : null,
      change14d: json['change_14d'] != null ? (json['change_14d'] as num).toDouble() : null,
      buyPrice: json['buy_price'] != null ? (json['buy_price'] as num).toDouble() : null,
      stopPrice: json['stop_price'] != null ? (json['stop_price'] as num).toDouble() : null,
      sellPrice: json['sell_price'] != null ? (json['sell_price'] as num).toDouble() : null,
      profitLossRatio: json['profit_loss_ratio'] != null 
          ? (json['profit_loss_ratio'] as num).toDouble() 
          : null,
      signalType: json['signal_type'] as String?,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'market': market,
      'date': date?.toIso8601String(),
      'close': close,
      'volume': volume,
      'ma20': ma20,
      'ma200': ma200,
      'mfi14': mfi14,
      'change_pct': changePct,
      'change_14d': change14d,
      'buy_price': buyPrice,
      'stop_price': stopPrice,
      'sell_price': sellPrice,
      'profit_loss_ratio': profitLossRatio,
      'signal_type': signalType,
    };
  }

  /// 市場名稱
  String get marketName {
    switch (market) {
      case 'twse':
        return '上市';
      case 'tpex':
        return '上櫃';
      default:
        return market;
    }
  }

  /// 是否上漲
  bool get isRising => changePct != null && changePct! > 0;

  /// 是否下跌
  bool get isFalling => changePct != null && changePct! < 0;

  /// MFI 狀態
  String get mfiStatus {
    if (mfi14 == null) return '未知';
    if (mfi14! > 80) return '超買';
    if (mfi14! < 20) return '超賣';
    return '正常';
  }

  /// 訊號類型名稱
  String get signalTypeName {
    switch (signalType) {
      case 'bullish':
        return '多頭';
      case 'bearish':
        return '空頭';
      case 'neutral':
        return '中性';
      default:
        return '未知';
    }
  }

  /// 是否為多頭訊號
  bool get isBullish => signalType == 'bullish';

  /// 是否為空頭訊號
  bool get isBearish => signalType == 'bearish';

  @override
  String toString() {
    return 'LatestStockData(code: $code, name: $name, close: $close, changePct: $changePct)';
  }
}
