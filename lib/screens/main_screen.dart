import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../database/models/monthlydata_chart.dart';
import '../database/models/summary.dart';
import '../database/transactions_crud.dart';
import 'home/monthly_bar_chart.dart';
import 'home/scrollable_accounts.dart';

class MainScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const MainScreen({
    Key? key,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _transactionCRUD = TransactionCRUD();
  double _totalBalance = 0.0;
  bool _isLoading = false;
  List<MonthlyData> _monthlyData = [];
  String _errorMessage = '';

  // Scroll controller for custom scroll behaviors
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Parallel execution of data fetching
      final results = await Future.wait([
        _transactionCRUD.getAllDataSummary(),
        _transactionCRUD.getMonthlyTransactions(),
      ]);

      if (!mounted) return;

      setState(() {
        _totalBalance = (results[0] as Summary).balance;
        _monthlyData = results[1] as List<MonthlyData>;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
      _showErrorSnackBar('Error refreshing: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: _refreshData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverSafeArea(
              sliver: SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    _buildThreeDotButton(),
                    _buildBalanceCard(),
                    const SizedBox(height: 8),
                    _buildAccountsSection(),
                    const SizedBox(height: 8),
                    _buildChartSection(),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildThreeDotButton() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          widget.scaffoldKey?.currentState?.openDrawer();
        },
      ),
    );}


    Widget _buildBalanceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Balance",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _totalBalance.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsSection() {
    return const ScrollableAccountsView();
  }

  Widget _buildChartSection() {
    return SizedBox(
      height: 280,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: MonthlyBarChart(
            monthlyData: _monthlyData,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }

}
