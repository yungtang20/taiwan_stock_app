import 'package:flutter/material.dart';
import '../models/latest_stock_data.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

/// 股票列表項組件
class StockListItem extends StatelessWidget {
  final LatestStockData stock;
  final VoidCallback onTap;

  const StockListItem({
    super.key,
    required this.stock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRising = stock.isRising;
    final changeColor = isRising ? AppColors.bullish : AppColors.bearish;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // 左側：股票代碼和名稱
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.code,
                      style: AppTextStyles.stockCode,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      stock.name,
                      style: AppTextStyles.stockName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      stock.marketName,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 中間：技術指標
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (stock.mfi14 != null) ...[
                      Text(
                        'MFI',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        Formatters.formatMFI(stock.mfi14),
                        style: AppTextStyles.bodyBold.copyWith(
                          color: _getMFIColor(stock.mfi14),
                        ),
                      ),
                    ] else
                      const Text('--', style: AppTextStyles.caption),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    if (stock.profitLossRatio != null) ...[
                      Text(
                        '賺賠比',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        Formatters.formatRatio(stock.profitLossRatio),
                        style: AppTextStyles.bodyBold.copyWith(
                          color: _getRatioColor(stock.profitLossRatio),
                        ),
                      ),
                    ] else
                      const Text('--', style: AppTextStyles.caption),
                  ],
                ),
              ),
              
              // 右側：價格和漲跌幅
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.formatPrice(stock.close),
                      style: AppTextStyles.price.copyWith(
                        color: changeColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: changeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        Formatters.formatPercent(stock.changePct),
                        style: AppTextStyles.bodyBold.copyWith(
                          color: changeColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (stock.signalType != null)
                      _buildSignalBadge(stock.signalType!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 取得 MFI 顏色
  Color _getMFIColor(double? mfi) {
    if (mfi == null) return AppColors.textSecondary;
    if (mfi > 80) return AppColors.error;
    if (mfi < 20) return AppColors.success;
    return AppColors.textPrimary;
  }

  /// 取得賺賠比顏色
  Color _getRatioColor(double? ratio) {
    if (ratio == null) return AppColors.textSecondary;
    if (ratio > 3.0) return AppColors.success;
    if (ratio > 1.5) return AppColors.warning;
    return AppColors.textSecondary;
  }

  /// 建立訊號徽章
  Widget _buildSignalBadge(String signalType) {
    Color color;
    String text;
    
    switch (signalType) {
      case 'bullish':
        color = AppColors.bullish;
        text = '多';
        break;
      case 'bearish':
        color = AppColors.bearish;
        text = '空';
        break;
      default:
        color = AppColors.textSecondary;
        text = '中';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
