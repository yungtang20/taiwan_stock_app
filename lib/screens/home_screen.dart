import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../widgets/stock_list_item.dart';
import '../widgets/search_bar_widget.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import 'stock_detail_screen.dart';
import 'bullish_screen.dart';
import 'bearish_screen.dart';
import 'filter_screen.dart';
import 'settings_screen.dart';

/// 首頁 - 股票列表
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 載入股票列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadStockList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<StockProvider>().loadStockList(forceRefresh: true);
              },
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // 切換頁面時重置篩選
          if (index == 0) {
            context.read<StockProvider>().resetFilter();
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '股票列表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: '多頭掃描',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_down),
            label: '空頭掃描',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: '篩選',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設置',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return AppConstants.appName;
      case 1:
        return '多頭掃描';
      case 2:
        return '空頭掃描';
      case 3:
        return '技術指標篩選';
      case 4:
        return '設置';
      default:
        return AppConstants.appName;
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const _StockListPage();
      case 1:
        return const BullishScreen();
      case 2:
        return const BearishScreen();
      case 3:
        return const FilterScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const _StockListPage();
    }
  }
}

/// 股票列表頁面
class _StockListPage extends StatelessWidget {
  const _StockListPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索欄
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SearchBarWidget(
            onSearch: (query) {
              context.read<StockProvider>().searchStocks(query);
            },
            onClear: () {
              context.read<StockProvider>().clearSearch();
            },
          ),
        ),
        
        // 排序按鈕
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SortButton(
                  label: '代碼',
                  onPressed: () {
                    context.read<StockProvider>().sortStocks('code', ascending: true);
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                _SortButton(
                  label: '漲幅',
                  onPressed: () {
                    context.read<StockProvider>().sortStocks('changePct');
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                _SortButton(
                  label: 'MFI',
                  onPressed: () {
                    context.read<StockProvider>().sortStocks('mfi14');
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                _SortButton(
                  label: '賺賠比',
                  onPressed: () {
                    context.read<StockProvider>().sortStocks('profitLossRatio');
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 股票列表
        Expanded(
          child: Consumer<StockProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        provider.error!,
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () {
                          provider.clearError();
                          provider.loadStockList(forceRefresh: true);
                        },
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                );
              }

              if (provider.filteredStockList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '沒有找到符合的股票',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await provider.loadStockList(forceRefresh: true);
                },
                child: ListView.builder(
                  itemCount: provider.filteredStockList.length,
                  itemBuilder: (context, index) {
                    final stock = provider.filteredStockList[index];
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
            },
          ),
        ),
      ],
    );
  }
}

/// 排序按鈕
class _SortButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SortButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        side: const BorderSide(color: AppColors.primary),
      ),
      child: Text(label),
    );
  }
}
