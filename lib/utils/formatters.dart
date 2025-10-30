import 'package:intl/intl.dart';

/// 格式化工具類
class Formatters {
  /// 格式化價格 (保留兩位小數)
  static String formatPrice(double? price) {
    if (price == null) return '--';
    return price.toStringAsFixed(2);
  }
  
  /// 格式化百分比 (保留兩位小數，帶正負號)
  static String formatPercent(double? percent) {
    if (percent == null) return '--';
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }
  
  /// 格式化成交量 (轉換為 K/M 單位)
  static String formatVolume(int? volume) {
    if (volume == null) return '--';
    
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(0)}K';
    }
    
    return volume.toString();
  }
  
  /// 格式化日期 (yyyy-MM-dd)
  static String formatDate(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// 格式化日期 (MM/dd)
  static String formatDateShort(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('MM/dd').format(date);
  }
  
  /// 格式化賺賠比
  static String formatRatio(double? ratio) {
    if (ratio == null) return '--';
    if (ratio.isInfinite) return '∞';
    return ratio.toStringAsFixed(2);
  }
  
  /// 格式化 MFI (保留兩位小數)
  static String formatMFI(double? mfi) {
    if (mfi == null) return '--';
    return mfi.toStringAsFixed(2);
  }
  
  /// 格式化大數字 (加入千分位逗號)
  static String formatNumber(num? number) {
    if (number == null) return '--';
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
