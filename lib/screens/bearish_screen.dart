import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/latest_stock_data.dart';
import '../widgets/stock_list_item.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import 'stock_detail_screen.dart';

/// 空頭掃描頁面
class BearishScreen extends StatefulWidget {
  const BearishScreen({super.key});

  @override
  State<BearishScreen> createState() => _BearishScreenState();
}

class _BearishScreenState extends State<BearishScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  String? _error;
  List<LatestStockData> _opportunities = [];

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _supabaseService.getBearishOpportunities();
      setState(() {
        _opportunities = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '載入空頭機會失敗: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 說明卡片
        Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bearish.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.bearish, width: 2),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.trending_down,
                color: AppColors.bearish,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '空頭機會掃描',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.bearish,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '空頭訊號股票',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 股票列表
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  Widget _buildBody() {
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
              onPressed: _loadOpportunities,
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    if (_opportunities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '目前沒有符合條件的空頭機會',
              style: AppTextStyles.body,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOpportunities,
      child: ListView.builder(
        itemCount: _opportunities.length,
        itemBuilder: (context, index) {
          final stock = _opportunities[index];
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
    );
  }
}
