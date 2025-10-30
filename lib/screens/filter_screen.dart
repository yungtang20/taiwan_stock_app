import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/latest_stock_data.dart';
import '../widgets/stock_list_item.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import 'stock_detail_screen.dart';

/// 技術指標篩選頁面
class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  bool _isLoading = false;
  String? _error;
  List<LatestStockData> _filteredStocks = [];
  
  // 篩選條件
  RangeValues _mfiRange = const RangeValues(0, 100);
  RangeValues _priceRange = const RangeValues(0, 1000);
  String? _selectedSignalType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 篩選條件區域
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('篩選條件', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.md),
                
                // MFI 範圍篩選
                _buildFilterSection(
                  title: 'MFI 範圍',
                  child: Column(
                    children: [
                      RangeSlider(
                        values: _mfiRange,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        labels: RangeLabels(
                          _mfiRange.start.round().toString(),
                          _mfiRange.end.round().toString(),
                        ),
                        onChanged: (values) {
                          setState(() {
                            _mfiRange = values;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '最小: ${_mfiRange.start.round()}',
                            style: AppTextStyles.caption,
                          ),
                          Text(
                            '最大: ${_mfiRange.end.round()}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // 價格範圍篩選
                _buildFilterSection(
                  title: '價格範圍',
                  child: Column(
                    children: [
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 1000,
                        divisions: 100,
                        labels: RangeLabels(
                          _priceRange.start.round().toString(),
                          _priceRange.end.round().toString(),
                        ),
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '最小: ${_priceRange.start.round()}',
                            style: AppTextStyles.caption,
                          ),
                          Text(
                            '最大: ${_priceRange.end.round()}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // 訊號類型篩選
                _buildFilterSection(
                  title: '訊號類型',
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        label: const Text('全部'),
                        selected: _selectedSignalType == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSignalType = null;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('多頭'),
                        selected: _selectedSignalType == 'bullish',
                        selectedColor: AppColors.bullish.withOpacity(0.3),
                        onSelected: (selected) {
                          setState(() {
                            _selectedSignalType = selected ? 'bullish' : null;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('空頭'),
                        selected: _selectedSignalType == 'bearish',
                        selectedColor: AppColors.bearish.withOpacity(0.3),
                        onSelected: (selected) {
                          setState(() {
                            _selectedSignalType = selected ? 'bearish' : null;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('中性'),
                        selected: _selectedSignalType == 'neutral',
                        onSelected: (selected) {
                          setState(() {
                            _selectedSignalType = selected ? 'neutral' : null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // 篩選按鈕
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilter,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        ),
                        child: const Text('套用篩選'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilter,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        ),
                        child: const Text('重置'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const Divider(height: 1),
        
        // 篩選結果區域
        Expanded(
          flex: 3,
          child: _buildResultsArea(),
        ),
      ],
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildResultsArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: AppTextStyles.body, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _applyFilter,
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    if (_filteredStocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '請設定篩選條件並點擊「套用篩選」',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            '找到 ${_filteredStocks.length} 檔符合條件的股票',
            style: AppTextStyles.subtitle,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredStocks.length,
            itemBuilder: (context, index) {
              final stock = _filteredStocks[index];
              return StockListItem(
                stock: stock,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockDetailScreen(
                        stockCode: stock.code,
                        stockName: stock.name,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _applyFilter() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _supabaseService.filterStocks(
        minMFI: _mfiRange.start,
        maxMFI: _mfiRange.end,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        signalType: _selectedSignalType,
      );
      
      setState(() {
        _filteredStocks = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '篩選失敗: $e';
        _isLoading = false;
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _mfiRange = const RangeValues(0, 100);
      _priceRange = const RangeValues(0, 1000);
      _selectedSignalType = null;
      _filteredStocks = [];
      _error = null;
    });
  }
}
