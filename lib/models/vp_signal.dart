/// VP 交易訊號模型
class VPSignal {
  final String code;
  final DateTime date;
  final double? buyPrice;
  final double? stopPrice;
  final double? sellPrice;
  final double? profitLossRatio;
  final String? signalType;

  VPSignal({
    required this.code,
    required this.date,
    this.buyPrice,
    this.stopPrice,
    this.sellPrice,
    this.profitLossRatio,
    this.signalType,
  });

  /// 從 JSON 創建 VPSignal 對象
  factory VPSignal.fromJson(Map<String, dynamic> json) {
    return VPSignal(
      code: json['code'] as String,
      date: DateTime.parse(json['date']),
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
      'date': date.toIso8601String(),
      'buy_price': buyPrice,
      'stop_price': stopPrice,
      'sell_price': sellPrice,
      'profit_loss_ratio': profitLossRatio,
      'signal_type': signalType,
    };
  }

  /// 是否為多頭訊號
  bool get isBullish => signalType == 'bullish';

  /// 是否為空頭訊號
  bool get isBearish => signalType == 'bearish';

  /// 是否為中性訊號
  bool get isNeutral => signalType == 'neutral';

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

  /// 潛在獲利空間
  double? get potentialProfit {
    if (buyPrice == null || sellPrice == null) return null;
    return sellPrice! - buyPrice!;
  }

  /// 潛在獲利百分比
  double? get potentialProfitPercent {
    if (buyPrice == null || sellPrice == null || buyPrice == 0) return null;
    return ((sellPrice! - buyPrice!) / buyPrice!) * 100;
  }

  /// 風險空間
  double? get riskAmount {
    if (buyPrice == null || stopPrice == null) return null;
    return buyPrice! - stopPrice!;
  }

  /// 風險百分比
  double? get riskPercent {
    if (buyPrice == null || stopPrice == null || buyPrice == 0) return null;
    return ((buyPrice! - stopPrice!) / buyPrice!) * 100;
  }

  @override
  String toString() {
    return 'VPSignal(code: $code, signalType: $signalType, ratio: $profitLossRatio)';
  }
}
