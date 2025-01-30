import 'package:expense_tracker/widgets/customIcons.dart';
import 'package:flutter/material.dart';

import '../../database/models/dbtransaction.dart';
import '../../database/models/template_model.dart';
import '../../database/templates_crud.dart';
import 'add_transaction_page.dart';
import 'create_templatepage.dart';

class TemplatesPage extends StatefulWidget {
  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  late Templates_crud _templatesCrud;
  List<Template> _templates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _templatesCrud = Templates_crud();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final templates = await _templatesCrud.getAllTemplates();
      if (!mounted) return;
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading templates: $e';
        _isLoading = false;
      });
    }
  }

  void _showAddTemplate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTemplatePage(),
      ),
    );

    if (result == true) {
      _loadTemplates(); // Refresh the list when a new template is added
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Template added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Templates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showAddTemplate,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.add, size: 40, color: Colors.black),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error!),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadTemplates,
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTemplates,
                          child: // lib/screens/addtransaction/templatespage.dart

                              GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _templates.length,
                            itemBuilder: (context, index) {
                              final template = _templates[index];
                              Color templateColor = template.color != null
                                  ? Color(int.parse(
                                      template.color!.replaceAll('#', '0x')))
                                  : Colors.grey;

                              return GestureDetector(
                                onTap: () async {
                                  // Handle template selection
                                  final DbTransaction transaction = template.toDbTransaction();
                                  print("2525625");
                                  print(transaction.toString());
                                  // Navigate to AddTransactionPage with the transaction
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddTransactionPage(
                                        transaction: transaction,
                                      ),
                                    ),
                                  );

                                  // If transaction was added/updated, pop the TemplatesPage
                                  if (result == true) {
                                    Navigator.pop(context);
                                  }
                                },
                                onLongPress: () {
                                  _showTemplateOptions(template);
                                },
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: templateColor.withOpacity(0.2),
                                          border: Border.all(
                                            color: templateColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: CustomIcons.getIcon(
                                            template.icon,
                                            size: 62,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      template.tName,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplateOptions(Template template) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Template'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTemplatePage(),
                  ),
                );
                if (result == true) {
                  _loadTemplates();
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title:
                  Text('Delete Template', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(template);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Template template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Template'),
        content: Text('Are you sure you want to delete this template?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              try {
                await _templatesCrud.deleteTemplate(template.tName);
                Navigator.pop(context);
                _loadTemplates();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Template deleted successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting template: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
