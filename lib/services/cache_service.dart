import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';

/// 本地快取服務層
class CacheService {
  static const String _stockListBox = 'stock_list';
  static const String _stockHistoryBox = 'stock_history';
  static const String _opportunitiesBox = 'opportunities';

  /// 初始化 Hive
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  // ==================== 股票列表快取 ====================

  /// 快取股票列表
  Future<void> cacheStockList(List<Map<String, dynamic>> data) async {
    try {
      final box = await Hive.openBox(_stockListBox);
      await box.put('data', data);
      await box.put('timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching stock list: $e');
    }
  }

  /// 取得快取的股票列表
  Future<List<Map<String, dynamic>>?> getCachedStockList() async {
    try {
      final box = await Hive.openBox(_stockListBox);
      final timestamp = box.get('timestamp') as int?;
      
      if (timestamp == null) return null;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - timestamp;
      
      // 檢查是否過期 (24 小時)
      if (diff > AppConstants.stockListCacheDuration) {
        return null;
      }
      
      final data = box.get('data');
      if (data == null) return null;
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getting cached stock list: $e');
      return null;
    }
  }

  /// 清除股票列表快取
  Future<void> clearStockListCache() async {
    try {
      final box = await Hive.openBox(_stockListBox);
      await box.clear();
    } catch (e) {
      print('Error clearing stock list cache: $e');
    }
  }

  // ==================== 股票歷史數據快取 ====================

  /// 快取股票歷史數據
  Future<void> cacheStockHistory(
    String code,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final box = await Hive.openBox(_stockHistoryBox);
      await box.put('${code}_data', data);
      await box.put('${code}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching stock history: $e');
    }
  }

  /// 取得快取的股票歷史數據
  Future<List<Map<String, dynamic>>?> getCachedStockHistory(String code) async {
    try {
      final box = await Hive.openBox(_stockHistoryBox);
      final timestamp = box.get('${code}_timestamp') as int?;
      
      if (timestamp == null) return null;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - timestamp;
      
      // 檢查是否過期 (1 小時)
      if (diff > AppConstants.stockHistoryCacheDuration) {
        return null;
      }
      
      final data = box.get('${code}_data');
      if (data == null) return null;
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getting cached stock history: $e');
      return null;
    }
  }

  /// 清除單檔股票歷史快取
  Future<void> clearStockHistoryCache(String code) async {
    try {
      final box = await Hive.openBox(_stockHistoryBox);
      await box.delete('${code}_data');
      await box.delete('${code}_timestamp');
    } catch (e) {
      print('Error clearing stock history cache: $e');
    }
  }

  /// 清除所有歷史數據快取
  Future<void> clearAllStockHistoryCache() async {
    try {
      final box = await Hive.openBox(_stockHistoryBox);
      await box.clear();
    } catch (e) {
      print('Error clearing all stock history cache: $e');
    }
  }

  // ==================== 多頭/空頭機會快取 ====================

  /// 快取多頭機會
  Future<void> cacheBullishOpportunities(
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final box = await Hive.openBox(_opportunitiesBox);
      await box.put('bullish_data', data);
      await box.put('bullish_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching bullish opportunities: $e');
    }
  }

  /// 取得快取的多頭機會
  Future<List<Map<String, dynamic>>?> getCachedBullishOpportunities() async {
    try {
      final box = await Hive.openBox(_opportunitiesBox);
      final timestamp = box.get('bullish_timestamp') as int?;
      
      if (timestamp == null) return null;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - timestamp;
      
      // 檢查是否過期 (30 分鐘)
      if (diff > AppConstants.opportunitiesCacheDuration) {
        return null;
      }
      
      final data = box.get('bullish_data');
      if (data == null) return null;
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getting cached bullish opportunities: $e');
      return null;
    }
  }

  /// 快取空頭機會
  Future<void> cacheBearishOpportunities(
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final box = await Hive.openBox(_opportunitiesBox);
      await box.put('bearish_data', data);
      await box.put('bearish_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching bearish opportunities: $e');
    }
  }

  /// 取得快取的空頭機會
  Future<List<Map<String, dynamic>>?> getCachedBearishOpportunities() async {
    try {
      final box = await Hive.openBox(_opportunitiesBox);
      final timestamp = box.get('bearish_timestamp') as int?;
      
      if (timestamp == null) return null;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - timestamp;
      
      // 檢查是否過期 (30 分鐘)
      if (diff > AppConstants.opportunitiesCacheDuration) {
        return null;
      }
      
      final data = box.get('bearish_data');
      if (data == null) return null;
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getting cached bearish opportunities: $e');
      return null;
    }
  }

  /// 清除機會快取
  Future<void> clearOpportunitiesCache() async {
    try {
      final box = await Hive.openBox(_opportunitiesBox);
      await box.clear();
    } catch (e) {
      print('Error clearing opportunities cache: $e');
    }
  }

  // ==================== 清除所有快取 ====================

  /// 清除所有快取
  Future<void> clearAllCache() async {
    await clearStockListCache();
    await clearAllStockHistoryCache();
    await clearOpportunitiesCache();
  }

  /// 取得快取大小 (估算)
  Future<Map<String, int>> getCacheSize() async {
    try {
      final stockListBox = await Hive.openBox(_stockListBox);
      final stockHistoryBox = await Hive.openBox(_stockHistoryBox);
      final opportunitiesBox = await Hive.openBox(_opportunitiesBox);
      
      return {
        'stock_list': stockListBox.length,
        'stock_history': stockHistoryBox.length,
        'opportunities': opportunitiesBox.length,
      };
    } catch (e) {
      print('Error getting cache size: $e');
      return {
        'stock_list': 0,
        'stock_history': 0,
        'opportunities': 0,
      };
    }
  }
}
