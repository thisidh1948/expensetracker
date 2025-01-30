import 'package:expense_tracker/widgets/customIcons.dart';
import 'package:flutter/material.dart';
import '../../database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import '../../widgets/iconpicker_widget.dart';
import 'common_add_dialog.dart';
import 'common_delete_dialog.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({Key? key}) : super(key: key);

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  late Future<List<StructModel>> _accountsFuture;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() {
    setState(() {
      _accountsFuture = StructuresCRUD().getAllTableData('Accounts');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accounts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Search Button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
              // You can add search functionality here
            },
          ),
          // More Options Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'sort_name':
                  // Implement sort by name
                  break;
                case 'sort_date':
                  // Implement sort by date
                  break;
                case 'refresh':
                  _loadAccounts();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'sort_name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Name'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'sort_date',
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Date'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<StructModel>>(
        future: _accountsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAccounts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final accounts = snapshot.data ?? [];

          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconPickerWidget(
                    currentLabel: 'wallet',
                    onIconSelected: (String label) {},
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No accounts found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      CommonAddDialog.showStructureDialog(
                        context: context,
                        structureType: 'Accounts',
                      ).then((_) => _loadAccounts());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Account'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadAccounts();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                final Color accountColor = Color(
                  int.parse(
                      account.color?.replaceFirst('#', '0xFF') ?? 'FF000000'),
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      // Handle account selection/details view
                    },
                    onLongPress: () {
                      CommonAddDialog.showStructureDialog(
                        context: context,
                        structureType: 'Accounts',
                        existingData: account,
                      ).then((_) => _loadAccounts());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Account Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accountColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIcons.getIcon(account.icon, size:24),
                          ),
                          const SizedBox(width: 16),

                          // Account Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                // Add additional account details here if needed
                              ],
                            ),
                          ),

                          // Action Buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () =>
                                    CommonDeleteDialog.showDeleteDialog(
                                  context: context,
                                  structureType: 'Accounts',
                                  item: account,
                                  onDeleteSuccess: _loadAccounts,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          CommonAddDialog.showStructureDialog(
            context: context,
            structureType: 'Accounts',
          ).then((_) => _loadAccounts());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
