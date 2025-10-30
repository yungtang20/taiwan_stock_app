import 'package:flutter/material.dart';
import 'colors.dart';

/// 應用程式常數定義
class AppConstants {
  // 應用名稱
  static const String appName = '台灣股票分析';
  static const String appVersion = '1.0.0';
  
  // 快取有效期 (毫秒)
  static const int stockListCacheDuration = 24 * 60 * 60 * 1000; // 24 小時
  static const int stockHistoryCacheDuration = 60 * 60 * 1000;   // 1 小時
  static const int opportunitiesCacheDuration = 30 * 60 * 1000;  // 30 分鐘
  
  // 數據限制
  static const int defaultHistoryDays = 60;
  static const int maxHistoryDays = 200;
  
  // VP 訊號閾值
  static const double bullishRatioThreshold = 3.0;
  
  // MFI 閾值
  static const double mfiOverbought = 80.0;
  static const double mfiOversold = 20.0;
}

/// 文字樣式定義
class AppTextStyles {
  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static const body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );
  
  static const bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  
  static const hint = TextStyle(
    fontSize: 14,
    color: AppColors.textHint,
  );
  
  // 股票代碼樣式
  static const stockCode = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'monospace',
  );
  
  // 股票名稱樣式
  static const stockName = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  // 價格樣式
  static const price = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
  );
  
  // 小價格樣式
  static const priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'monospace',
  );
}

/// 間距定義
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

/// 圓角定義
class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
}
