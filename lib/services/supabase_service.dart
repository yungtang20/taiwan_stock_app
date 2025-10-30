import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stock.dart';
import '../models/stock_daily_data.dart';
import '../models/technical_indicator.dart';
import '../models/vp_signal.dart';
import '../models/latest_stock_data.dart';

/// Supabase 數據服務層
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ==================== 股票清單 ====================

  /// 取得所有股票列表
  Future<List<Stock>> getStockList() async {
    try {
      final response = await _client
          .from('stocks')
          .select()
          .order('code', ascending: true);
      
      return (response as List)
          .map((json) => Stock.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching stock list: $e');
      rethrow;
    }
  }

  /// 搜尋股票
  Future<List<LatestStockData>> searchStocks(String query) async {
    try {
      final response = await _client
          .rpc('search_stocks', params: {'search_term': query});
      
      return (response as List)
          .map((json) => LatestStockData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching stocks: $e');
      // 如果 RPC 函數不存在，使用備用查詢
      return await _searchStocksFallback(query);
    }
  }

  /// 備用搜尋方法 (不使用 RPC 函數)
  Future<List<LatestStockData>> _searchStocksFallback(String query) async {
    try {
      final response = await _client
          .from('latest_stock_data')
          .select()
          .or('code.ilike.%$query%,name.ilike.%$query%')
          .limit(50);
      
      return (response as List)
          .map((json) => LatestStockData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error in fallback search: $e');
      return [];
    }
  }

  // ==================== 最新數據 ====================

  /// 取得最新股票數據
  Future<List<LatestStockData>> getLatestStockData({
    int? limit,
    String? orderBy,
    bool ascending = false,
  }) async {
    try {
      var query = _client.from('latest_stock_data').select();
      
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query;
      
      return (response as List)
          .map((json) => LatestStockData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching latest stock data: $e');
      rethrow;
    }
  }

  /// 取得單檔最新數據
  Future<LatestStockData?> getLatestStockDataByCode(String code) async {
    try {
      final response = await _client
          .from('latest_stock_data')
          .select()
          .eq('code', code)
          .maybeSingle();
      
      if (response == null) return null;
      return LatestStockData.fromJson(response);
    } catch (e) {
      print('Error fetching latest data for $code: $e');
      return null;
    }
  }

  // ==================== 歷史數據 ====================

  /// 取得單檔股票歷史數據
  Future<List<Map<String, dynamic>>> getStockHistory(
    String code, {
    int limit = 60,
  }) async {
    try {
      final response = await _client
          .rpc('get_stock_history', params: {
            'stock_code': code,
            'days_limit': limit,
          });
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching stock history: $e');
      // 如果 RPC 函數不存在，使用備用查詢
      return await _getStockHistoryFallback(code, limit);
    }
  }

  /// 備用歷史數據查詢
  Future<List<Map<String, dynamic>>> _getStockHistoryFallback(
    String code,
    int limit,
  ) async {
    try {
      final dailyData = await _client
          .from('stock_daily_data')
          .select()
          .eq('code', code)
          .order('date', ascending: false)
          .limit(limit);
      
      final indicators = await _client
          .from('technical_indicators')
          .select()
          .eq('code', code)
          .order('date', ascending: false)
          .limit(limit);
      
      // 合併數據
      final result = <Map<String, dynamic>>[];
      for (var daily in dailyData) {
        final indicator = indicators.firstWhere(
          (ind) => ind['date'] == daily['date'],
          orElse: () => <String, dynamic>{},
        );
        
        result.add({
          ...daily,
          ...indicator,
        });
      }
      
      return result;
    } catch (e) {
      print('Error in fallback history query: $e');
      return [];
    }
  }

  /// 取得每日數據
  Future<List<StockDailyData>> getDailyData(
    String code, {
    int limit = 60,
  }) async {
    try {
      final response = await _client
          .from('stock_daily_data')
          .select()
          .eq('code', code)
          .order('date', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((json) => StockDailyData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching daily data: $e');
      return [];
    }
  }

  /// 取得技術指標
  Future<List<TechnicalIndicator>> getTechnicalIndicators(
    String code, {
    int limit = 60,
  }) async {
    try {
      final response = await _client
          .from('technical_indicators')
          .select()
          .eq('code', code)
          .order('date', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((json) => TechnicalIndicator.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching technical indicators: $e');
      return [];
    }
  }

  /// 取得 VP 訊號
  Future<List<VPSignal>> getVPSignals(
    String code, {
    int limit = 60,
  }) async {
    try {
      final response = await _client
          .from('vp_signals')
          .select()
          .eq('code', code)
          .order('date', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((json) => VPSignal.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching VP signals: $e');
      return [];
    }
  }

  // ==================== 多頭/空頭機會 ====================

  /// 取得多頭機會
  Future<List<LatestStockData>> getBullishOpportunities() async {
    try {
      final response = await _client
          .from('bullish_opportunities')
          .select();
      
      return (response as List)
          .map((json) => LatestStockData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching bullish opportunities: $e');
      // 備用查詢
      return await _getBullishOpportunitiesFallback();
    }
  }

  Future<List<LatestStockData>> _getBullishOpportunitiesFallback() async {
    try {
      final response = await _client
          .from('latest_stock_data')
          .select()
          .eq('signal_type', 'bullish')
          .gt('profit_loss_ratio', 3.0)
          .not('mfi14', 'is', null)
          .order('profit_loss_ratio', ascending: false);
      
      return (response as List)
          .map((json) => LatestStockData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error in fallback bullish query: $e');
      return [];
    }
  }

  /// 取得空頭機會
  Future<List<LatestStockData>> getBearishOpportunities() async {
    try {
      final response = await _client
          .from('bearish_opportunities')
          .select();
      
      return (response as List)
          .map((json) => LatestStockData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching bearish opportunities: $e');
      // 備用查詢
      return await _getBearishOpportunitiesFallback();
    }
  }

  Future<List<LatestStockData>> _getBearishOpportunitiesFallback() async {
    try {
      final response = await _client
          .from('latest_stock_data')
          .select()
          .eq('signal_type', 'bearish')
          .not('mfi14', 'is', null)
          .order('profit_loss_ratio', ascending: false);
      
      return (response as List)
          .map((json) => LatestStockData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error in fallback bearish query: $e');
      return [];
    }
  }

  // ==================== 篩選功能 ====================

  /// 篩選股票 (按 MFI 範圍)
  Future<List<LatestStockData>> filterByMFI(
    double minMFI,
    double maxMFI,
  ) async {
    try {
      final response = await _client
          .from('latest_stock_data')
          .select()
          .gte('mfi14', minMFI)
          .lte('mfi14', maxMFI)
          .order('mfi14', ascending: false);
      
      return (response as List)
          .map((json) => LatestStockData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error filtering by MFI: $e');
      return [];
    }
  }

  /// 篩選股票 (按價格範圍)
  Future<List<LatestStockData>> filterByPrice(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      final response = await _client
          .from('latest_stock_data')
          .select()
          .gte('close', minPrice)
          .lte('close', maxPrice)
          .order('close', ascending: false);
      
      return (response as List)
          .map((json) => LatestStockData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error filtering by price: $e');
      return [];
    }
  }

  /// 多條件篩選
  Future<List<LatestStockData>> filterStocks({
    double? minMFI,
    double? maxMFI,
    double? minPrice,
    double? maxPrice,
    String? signalType,
  }) async {
    try {
      var query = _client.from('latest_stock_data').select();
      
      if (minMFI != null) {
        query = query.gte('mfi14', minMFI);
      }
      if (maxMFI != null) {
        query = query.lte('mfi14', maxMFI);
      }
      if (minPrice != null) {
        query = query.gte('close', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('close', maxPrice);
      }
      if (signalType != null) {
        query = query.eq('signal_type', signalType);
      }
      
      final response = await query.order('profit_loss_ratio', ascending: false);
      
      return (response as List)
          .map((json) => LatestStockData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error filtering stocks: $e');
      return [];
    }
  }

  // ==================== 連接測試 ====================

  /// 測試 Supabase 連接
  Future<bool> testConnection() async {
    try {
      await _client.from('stocks').select().limit(1);
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
