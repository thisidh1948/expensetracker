import 'package:flutter/material.dart';
import '../../database/loans_crud.dart';
import '../../database/models/loan.dart';
import 'add_loan_sheet.dart';
import 'loan_details_sheet.dart';
import 'loan_list_tile.dart';

class LoanBasePage extends StatefulWidget {
  final String personRole;
  final String title;

  const LoanBasePage({
    Key? key,
    required this.personRole,
    required this.title,
  }) : super(key: key);

  @override
  State<LoanBasePage> createState() => _LoanBasePageState();
}

class _LoanBasePageState extends State<LoanBasePage> {
  final LoansCRUD _loansCRUD = LoansCRUD();
  List<Loan> _loans = [];
  bool _isLoading = true;
  String? _selectedStatus;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() => _isLoading = true);
    try {
      final loans = await _loansCRUD.searchLoans(
        personRole: widget.personRole,
        searchTerm: _searchController.text,
        status: _selectedStatus,
      );
      setState(() => _loans = loans);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading loans: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addLoan() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddLoanSheet(personRole: widget.personRole),
    );

    if (result == true) {
      _loadLoans();
    }
  }

  Future<void> _editLoan(Loan loan) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddLoanSheet(personRole: widget.personRole, loan: loan),
    );

    if (result == true) {
      _loadLoans();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          //_buildSearchBar(),
          _buildTotalAmount(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _loans.isEmpty
                ? _buildEmptyState()
                : _buildLoansList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLoan,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (_) => _loadLoans(),
      ),
    );
  }

  Widget _buildTotalAmount() {
    return FutureBuilder<double>(
      future: _loansCRUD.getTotalAmount(
        personRole: widget.personRole,
        status: 'unpaid',
      ),
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Outstanding:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '₹${snapshot.data?.toStringAsFixed(2) ?? '0.00'}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${widget.title.toLowerCase()} found',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoansList() {
    return ListView.builder(
      itemCount: _loans.length,
      itemBuilder: (context, index) {
        final loan = _loans[index];
        return LoanListTile(
          loan: loan,
          onTap: () => _showLoanDetails(loan),
          onLongPress: () => _editLoan(loan),
        );
      },
    );
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              title: const Text('All'),
              value: null,
              groupValue: _selectedStatus,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            ),
            RadioListTile<String?>(
              title: const Text('Unpaid'),
              value: 'unpaid',
              groupValue: _selectedStatus,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            ),
            RadioListTile<String?>(
              title: const Text('Paid'),
              value: 'paid',
              groupValue: _selectedStatus,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            ),
          ],
        ),
      ),
    );

    if (result != _selectedStatus) {
      setState(() => _selectedStatus = result);
      _loadLoans();
    }
  }

  void _showLoanDetails(Loan loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => LoanDetailsSheet(
        loan: loan,
        onUpdate: _loadLoans,
      ),
    );
  }
}