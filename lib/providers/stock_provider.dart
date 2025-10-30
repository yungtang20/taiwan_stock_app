import 'package:flutter/foundation.dart';
import '../models/latest_stock_data.dart';
import '../services/supabase_service.dart';
import '../services/cache_service.dart';

/// 股票狀態管理 Provider
class StockProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final CacheService _cacheService = CacheService();

  // 狀態
  bool _isLoading = false;
  String? _error;
  List<LatestStockData> _stockList = [];
  List<LatestStockData> _filteredStockList = [];
  String _searchQuery = '';

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<LatestStockData> get stockList => _stockList;
  List<LatestStockData> get filteredStockList => _filteredStockList;
  String get searchQuery => _searchQuery;

  /// 載入股票列表
  Future<void> loadStockList({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 如果不是強制刷新，先嘗試從快取讀取
      if (!forceRefresh) {
        final cachedData = await _cacheService.getCachedStockList();
        if (cachedData != null && cachedData.isNotEmpty) {
          _stockList = cachedData
              .map((json) => LatestStockData.fromJson(json))
              .toList();
          _filteredStockList = _stockList;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // 從 Supabase 載入
      final data = await _supabaseService.getLatestStockData();
      _stockList = data;
      _filteredStockList = data;

      // 快取數據
      await _cacheService.cacheStockList(
        data.map((stock) => stock.toJson()).toList(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '載入股票列表失敗: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 搜尋股票
  void searchStocks(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredStockList = _stockList;
    } else {
      _filteredStockList = _stockList.where((stock) {
        final codeMatch = stock.code.toLowerCase().contains(query.toLowerCase());
        final nameMatch = stock.name.toLowerCase().contains(query.toLowerCase());
        return codeMatch || nameMatch;
      }).toList();
    }

    notifyListeners();
  }

  /// 清除搜尋
  void clearSearch() {
    _searchQuery = '';
    _filteredStockList = _stockList;
    notifyListeners();
  }

  /// 按欄位排序
  void sortStocks(String field, {bool ascending = false}) {
    _filteredStockList.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (field) {
        case 'code':
          aValue = a.code;
          bValue = b.code;
          break;
        case 'name':
          aValue = a.name;
          bValue = b.name;
          break;
        case 'close':
          aValue = a.close ?? 0;
          bValue = b.close ?? 0;
          break;
        case 'changePct':
          aValue = a.changePct ?? 0;
          bValue = b.changePct ?? 0;
          break;
        case 'mfi14':
          aValue = a.mfi14 ?? 0;
          bValue = b.mfi14 ?? 0;
          break;
        case 'profitLossRatio':
          aValue = a.profitLossRatio ?? 0;
          bValue = b.profitLossRatio ?? 0;
          break;
        default:
          aValue = a.code;
          bValue = b.code;
      }

      if (ascending) {
        return Comparable.compare(aValue, bValue);
      } else {
        return Comparable.compare(bValue, aValue);
      }
    });

    notifyListeners();
  }

  /// 篩選多頭機會
  void filterBullish() {
    _filteredStockList = _stockList.where((stock) {
      return stock.isBullish && 
             stock.profitLossRatio != null && 
             stock.profitLossRatio! > 3.0;
    }).toList();
    
    // 按賺賠比排序
    _filteredStockList.sort((a, b) {
      final aRatio = a.profitLossRatio ?? 0;
      final bRatio = b.profitLossRatio ?? 0;
      return bRatio.compareTo(aRatio);
    });

    notifyListeners();
  }

  /// 篩選空頭機會
  void filterBearish() {
    _filteredStockList = _stockList.where((stock) {
      return stock.isBearish;
    }).toList();
    
    // 按賺賠比排序
    _filteredStockList.sort((a, b) {
      final aRatio = a.profitLossRatio ?? 0;
      final bRatio = b.profitLossRatio ?? 0;
      return bRatio.compareTo(aRatio);
    });

    notifyListeners();
  }

  /// 重置篩選
  void resetFilter() {
    _filteredStockList = _stockList;
    _searchQuery = '';
    notifyListeners();
  }

  /// 清除錯誤
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
