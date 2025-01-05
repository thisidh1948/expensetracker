import 'package:flutter/material.dart';
import '../models/backup_metadata.dart';
import 'package:intl/intl.dart';

import 'backup_service.dart';

class BackupManagerPage extends StatefulWidget {
  const BackupManagerPage({Key? key}) : super(key: key);

  @override
  _BackupManagerPageState createState() => _BackupManagerPageState();
}

class _BackupManagerPageState extends State<BackupManagerPage> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;
  String? _error;
  List<BackupMetadata> _backups = [];

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

Future<void> _loadBackups() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final backups = await _backupService.listBackups();
      if (mounted) {
        setState(() {
          _backups = backups;
          _isLoading = false;  // Reset loading state
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;  // Reset loading state
        });
        _showError('Failed to load backups: $e');
      }
    }
  }

 Future<void> _createBackup() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _backupService.createBackup();
      if (mounted) {
        setState(() {
          _isLoading = false;  // Reset loading state
        });
        await _loadBackups();  // Reload the backup list
        _showSuccess('Backup created successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;  // Reset loading state
        });
        _showError('Failed to create backup: $e');
      }
    }
  }


  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'DISMISS',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          textColor: Colors.white,
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Backup Manager'),
          actions: [
            if (!_isLoading)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadBackups,
                tooltip: 'Refresh',
              ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.withOpacity(0.1),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadBackups,
                    child: _backups.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      itemCount: _backups.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final backup = _backups[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.backup),
                            ),
                            title: Text(
                              DateFormat('MMM dd, yyyy HH:mm')
                                  .format(backup.createdAt),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Size: ${_formatFileSize(backup.sizeBytes)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.restore),
                              tooltip: 'Restore this backup',
                              onPressed: _isLoading
                                  ? null
                                  : () => _restoreBackup(backup),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
        floatingActionButton: !_isLoading
            ? FloatingActionButton.extended(
          onPressed: _createBackup,
          icon: const Icon(Icons.backup),
          label: const Text('Create Backup'),
        )
            : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.backup_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No backups found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create your first backup',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup(BackupMetadata backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Restore'),
        content: const Text(
          'This will replace all current data with the backup data. '
              'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('RESTORE'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _backupService.restoreBackup(backup.id);
      if (mounted) {
        _showSuccess('Backup restored successfully');
        // Optional: Navigate back or restart app
        // Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        _showError('Failed to restore backup: $e');
      }
    }
  }
}
