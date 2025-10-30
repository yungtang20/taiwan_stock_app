/// 技術指標模型
class TechnicalIndicator {
  final String code;
  final DateTime date;
  final double? ma5;
  final double? ma10;
  final double? ma20;
  final double? ma60;
  final double? ma200;
  final double? mfi14;
  final double? changePct;
  final double? change14d;

  TechnicalIndicator({
    required this.code,
    required this.date,
    this.ma5,
    this.ma10,
    this.ma20,
    this.ma60,
    this.ma200,
    this.mfi14,
    this.changePct,
    this.change14d,
  });

  /// 從 JSON 創建 TechnicalIndicator 對象
  factory TechnicalIndicator.fromJson(Map<String, dynamic> json) {
    return TechnicalIndicator(
      code: json['code'] as String,
      date: DateTime.parse(json['date']),
      ma5: json['ma5'] != null ? (json['ma5'] as num).toDouble() : null,
      ma10: json['ma10'] != null ? (json['ma10'] as num).toDouble() : null,
      ma20: json['ma20'] != null ? (json['ma20'] as num).toDouble() : null,
      ma60: json['ma60'] != null ? (json['ma60'] as num).toDouble() : null,
      ma200: json['ma200'] != null ? (json['ma200'] as num).toDouble() : null,
      mfi14: json['mfi14'] != null ? (json['mfi14'] as num).toDouble() : null,
      changePct: json['change_pct'] != null ? (json['change_pct'] as num).toDouble() : null,
      change14d: json['change_14d'] != null ? (json['change_14d'] as num).toDouble() : null,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'date': date.toIso8601String(),
      'ma5': ma5,
      'ma10': ma10,
      'ma20': ma20,
      'ma60': ma60,
      'ma200': ma200,
      'mfi14': mfi14,
      'change_pct': changePct,
      'change_14d': change14d,
    };
  }

  /// MFI 狀態
  String get mfiStatus {
    if (mfi14 == null) return '未知';
    if (mfi14! > 80) return '超買';
    if (mfi14! < 20) return '超賣';
    return '正常';
  }

  /// 是否超買
  bool get isOverbought => mfi14 != null && mfi14! > 80;

  /// 是否超賣
  bool get isOversold => mfi14 != null && mfi14! < 20;

  @override
  String toString() {
    return 'TechnicalIndicator(code: $code, date: $date, mfi14: $mfi14)';
  }
}
