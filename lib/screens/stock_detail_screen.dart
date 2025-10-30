import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

/// 單檔股票詳情頁面
class StockDetailScreen extends StatefulWidget {
  final String stockCode;
  final String stockName;

  const StockDetailScreen({
    super.key,
    required this.stockCode,
    required this.stockName,
  });

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _historyData = [];

  @override
  void initState() {
    super.initState();
    _loadStockHistory();
  }

  Future<void> _loadStockHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _supabaseService.getStockHistory(
        widget.stockCode,
        limit: 60,
      );
      
      setState(() {
        _historyData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '載入數據失敗: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.stockCode, style: const TextStyle(fontSize: 18)),
            Text(
              widget.stockName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStockHistory,
          ),
        ],
      ),
      body: _buildBody(),
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
              onPressed: _loadStockHistory,
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    if (_historyData.isEmpty) {
      return const Center(
        child: Text('暫無數據', style: AppTextStyles.body),
      );
    }

    final latestData = _historyData.first;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 最新數據卡片
          _buildLatestDataCard(latestData),
          
          const SizedBox(height: AppSpacing.md),
          
          // 技術指標卡片
          _buildTechnicalIndicatorsCard(latestData),
          
          const SizedBox(height: AppSpacing.md),
          
          // VP 訊號卡片 (如果有 VP 數據)
          if (latestData['buy_price'] != null)
            _buildVPSignalCard(latestData),
          
          const SizedBox(height: AppSpacing.md),
          
          // 歷史數據表格
          _buildHistoryTable(),
          
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildLatestDataCard(Map<String, dynamic> data) {
    final close = data['close'] as num?;
    final open = data['open'] as num?;
    final high = data['high'] as num?;
    final low = data['low'] as num?;
    final volume = data['volume'] as int?;
    final changePct = data['change_pct'] as num?;
    
    final isRising = close != null && open != null && close >= open;
    final changeColor = isRising ? AppColors.bullish : AppColors.bearish;

    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('最新報價', style: AppTextStyles.subtitle),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('收盤價', style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      Formatters.formatPrice(close?.toDouble()),
                      style: AppTextStyles.price.copyWith(
                        fontSize: 24,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
                if (changePct != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      Formatters.formatPercent(changePct.toDouble()),
                      style: AppTextStyles.subtitle.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDataItem('開盤', Formatters.formatPrice(open?.toDouble())),
                _buildDataItem('最高', Formatters.formatPrice(high?.toDouble())),
                _buildDataItem('最低', Formatters.formatPrice(low?.toDouble())),
                _buildDataItem('成交量', Formatters.formatVolume(volume)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalIndicatorsCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('技術指標', style: AppTextStyles.subtitle),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _buildIndicatorRow('MFI14', Formatters.formatMFI(data['mfi14']?.toDouble())),
            _buildIndicatorRow('MA5', Formatters.formatPrice(data['ma5']?.toDouble())),
            _buildIndicatorRow('MA10', Formatters.formatPrice(data['ma10']?.toDouble())),
            _buildIndicatorRow('MA20', Formatters.formatPrice(data['ma20']?.toDouble())),
            _buildIndicatorRow('MA60', Formatters.formatPrice(data['ma60']?.toDouble())),
            _buildIndicatorRow('MA200', Formatters.formatPrice(data['ma200']?.toDouble())),
          ],
        ),
      ),
    );
  }

  Widget _buildVPSignalCard(Map<String, dynamic> data) {
    final buyPrice = data['buy_price'] as num?;
    final stopPrice = data['stop_price'] as num?;
    final sellPrice = data['sell_price'] as num?;
    final ratio = data['profit_loss_ratio'] as num?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VP 交易訊號', style: AppTextStyles.subtitle),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _buildIndicatorRow('買入價', Formatters.formatPrice(buyPrice?.toDouble())),
            _buildIndicatorRow('停損價', Formatters.formatPrice(stopPrice?.toDouble())),
            _buildIndicatorRow('賣出價', Formatters.formatPrice(sellPrice?.toDouble())),
            _buildIndicatorRow(
              '賺賠比',
              Formatters.formatRatio(ratio?.toDouble()),
              valueColor: ratio != null && ratio > 3.0 ? AppColors.success : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTable() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('歷史數據 (最近 ${_historyData.length} 天)', style: AppTextStyles.subtitle),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('日期', style: AppTextStyles.caption)),
                  DataColumn(label: Text('收盤', style: AppTextStyles.caption)),
                  DataColumn(label: Text('漲跌%', style: AppTextStyles.caption)),
                  DataColumn(label: Text('MFI', style: AppTextStyles.caption)),
                ],
                rows: _historyData.take(20).map((data) {
                  final date = data['date'] as String?;
                  final close = data['close'] as num?;
                  final changePct = data['change_pct'] as num?;
                  final mfi = data['mfi14'] as num?;
                  
                  final isRising = changePct != null && changePct >= 0;
                  final changeColor = isRising ? AppColors.bullish : AppColors.bearish;

                  return DataRow(
                    cells: [
                      DataCell(Text(
                        date != null ? Formatters.formatDateShort(DateTime.parse(date)) : '--',
                        style: AppTextStyles.caption,
                      )),
                      DataCell(Text(
                        Formatters.formatPrice(close?.toDouble()),
                        style: AppTextStyles.priceSmall,
                      )),
                      DataCell(Text(
                        Formatters.formatPercent(changePct?.toDouble()),
                        style: AppTextStyles.caption.copyWith(color: changeColor),
                      )),
                      DataCell(Text(
                        Formatters.formatMFI(mfi?.toDouble()),
                        style: AppTextStyles.caption,
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.bodyBold),
      ],
    );
  }

  Widget _buildIndicatorRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(
            value,
            style: AppTextStyles.bodyBold.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
