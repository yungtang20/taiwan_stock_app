import 'package:flutter/material.dart';

/// 應用程式顏色定義
class AppColors {
  // 主色調
  static const primary = Color(0xFF1976D2);
  static const secondary = Color(0xFF424242);
  
  // 漲跌顏色 (台灣股市習慣：紅漲綠跌)
  static const bullish = Color(0xFFF44336);  // 紅色 (多頭/上漲)
  static const bearish = Color(0xFF4CAF50);  // 綠色 (空頭/下跌)
  
  // 背景顏色
  static const background = Color(0xFFF5F5F5);
  static const cardBackground = Color(0xFFFFFFFF);
  
  // 文字顏色
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFF9E9E9E);
  
  // 圖表顏色
  static const ma5 = Color(0xFFFF9800);      // 橘色
  static const ma10 = Color(0xFF9C27B0);     // 紫色
  static const ma20 = Color(0xFF2196F3);     // 藍色
  static const ma60 = Color(0xFF4CAF50);     // 綠色
  static const ma200 = Color(0xFFF44336);    // 紅色
  
  // 狀態顏色
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);
  
  // 邊框顏色
  static const border = Color(0xFFE0E0E0);
  static const divider = Color(0xFFBDBDBD);
}
