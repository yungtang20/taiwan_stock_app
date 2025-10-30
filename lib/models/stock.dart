/// 股票模型
class Stock {
  final String code;
  final String name;
  final String market;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Stock({
    required this.code,
    required this.name,
    required this.market,
    this.createdAt,
    this.updatedAt,
  });

  /// 從 JSON 創建 Stock 對象
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      code: json['code'] as String,
      name: json['name'] as String,
      market: json['market'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'market': market,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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

  @override
  String toString() {
    return 'Stock(code: $code, name: $name, market: $market)';
  }
}
