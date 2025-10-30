import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/cache_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// 設置頁面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final CacheService _cacheService = CacheService();
  
  bool _isTestingConnection = false;
  bool? _connectionStatus;
  Map<String, int>? _cacheSize;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    final size = await _cacheService.getCacheSize();
    setState(() {
      _cacheSize = size;
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = null;
    });

    final isConnected = await _supabaseService.testConnection();
    
    setState(() {
      _isTestingConnection = false;
      _connectionStatus = isConnected;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConnected ? 'Supabase 連接成功！' : 'Supabase 連接失敗',
          ),
          backgroundColor: isConnected ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _clearAllCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認清除快取'),
        content: const Text('確定要清除所有本地快取嗎？這將會刪除所有離線數據。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('確定', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cacheService.clearAllCache();
      await _loadCacheSize();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('快取已清除'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Supabase 連接狀態
        _buildSection(
          title: 'Supabase 連接',
          children: [
            ListTile(
              leading: Icon(
                _connectionStatus == null
                    ? Icons.cloud_outlined
                    : _connectionStatus!
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                color: _connectionStatus == null
                    ? AppColors.textSecondary
                    : _connectionStatus!
                        ? AppColors.success
                        : AppColors.error,
              ),
              title: const Text('連接狀態'),
              subtitle: Text(
                _connectionStatus == null
                    ? '未測試'
                    : _connectionStatus!
                        ? '已連接'
                        : '連接失敗',
              ),
              trailing: _isTestingConnection
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ElevatedButton(
                onPressed: _isTestingConnection ? null : _testConnection,
                child: const Text('測試連接'),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // 快取管理
        _buildSection(
          title: '快取管理',
          children: [
            if (_cacheSize != null) ...[
              ListTile(
                leading: const Icon(Icons.storage, color: AppColors.primary),
                title: const Text('股票列表快取'),
                trailing: Text(
                  '${_cacheSize!['stock_list']} 項',
                  style: AppTextStyles.bodyBold,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.history, color: AppColors.primary),
                title: const Text('歷史數據快取'),
                trailing: Text(
                  '${_cacheSize!['stock_history']} 項',
                  style: AppTextStyles.bodyBold,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.trending_up, color: AppColors.primary),
                title: const Text('機會快取'),
                trailing: Text(
                  '${_cacheSize!['opportunities']} 項',
                  style: AppTextStyles.bodyBold,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: OutlinedButton(
                onPressed: _clearAllCache,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('清除所有快取'),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // 關於
        _buildSection(
          title: '關於',
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.primary),
              title: const Text('應用名稱'),
              trailing: Text(
                AppConstants.appName,
                style: AppTextStyles.bodyBold,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.tag, color: AppColors.primary),
              title: const Text('版本'),
              trailing: Text(
                AppConstants.appVersion,
                style: AppTextStyles.bodyBold,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.code, color: AppColors.primary),
              title: const Text('技術棧'),
              subtitle: const Text('Flutter + Supabase'),
            ),
            ListTile(
              leading: const Icon(Icons.description, color: AppColors.primary),
              title: const Text('說明'),
              subtitle: const Text(
                '台灣股票技術分析 APP，整合 TWSE/TPEX 數據，提供 MFI、MA、VP 訊號等技術指標分析',
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // 數據來源說明
        _buildSection(
          title: '數據來源',
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                '本應用數據來自 Supabase 雲端資料庫，由 Python 爬蟲定時更新。\n\n'
                '數據來源：\n'
                '• 台灣證券交易所 (TWSE)\n'
                '• 證券櫃檯買賣中心 (TPEX)\n'
                '• FinMind API\n\n'
                '技術指標：\n'
                '• MFI (Money Flow Index)\n'
                '• MA (移動平均線)\n'
                '• VP (Value Position) 訊號',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(title, style: AppTextStyles.subtitle),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}
