import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/installed_app_entity.dart';
import '../../domain/services/app_selection_service.dart';

class AppSelectionPage extends StatefulWidget {
  final List<String> initiallySelectedPackages;

  const AppSelectionPage({
    super.key,
    this.initiallySelectedPackages = const [],
  });

  @override
  State<AppSelectionPage> createState() => _AppSelectionPageState();
}

class _AppSelectionPageState extends State<AppSelectionPage> {
  final AppSelectionService _appSelectionService = AppSelectionService();

  final TextEditingController _searchController = TextEditingController();

  late Set<String> _selectedPackages;

  List<InstalledAppEntity> _apps = [];

  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _selectedPackages = widget.initiallySelectedPackages.toSet();

    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final apps = await _appSelectionService.getInstalledApps();

      if (!mounted) return;

      setState(() {
        _apps = apps
            .where((app) => app.packageName != 'com.wakelock.wakelock')
            .toList();

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  List<InstalledAppEntity> get _filteredApps {
    if (_searchQuery.trim().isEmpty) {
      return _apps;
    }

    return _apps.where((app) {
      return app.appName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _toggleSelection(String packageName) {
    setState(() {
      if (_selectedPackages.contains(packageName)) {
        _selectedPackages.remove(packageName);
      } else {
        _selectedPackages.add(packageName);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = _filteredApps;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Apps'),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedPackages.toList());
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search installed apps',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Available Apps',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_selectedPackages.length} selected',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(child: _buildContent(filteredApps)),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedPackages.toList());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Confirm Selection (${_selectedPackages.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<InstalledAppEntity> apps) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  _loadApps();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (apps.isEmpty) {
      return Center(
        child: Text(
          'No matching apps found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: apps.length,
      separatorBuilder: (_, __) =>
          const Divider(color: Colors.white12, height: 1),
      itemBuilder: (context, index) {
        final app = apps[index];
        final isSelected = _selectedPackages.contains(app.packageName);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            app.appName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            app.packageName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          trailing: Checkbox(
            value: isSelected,
            activeColor: AppColors.primary,
            checkColor: Colors.black,
            onChanged: (_) {
              _toggleSelection(app.packageName);
            },
          ),
          onTap: () {
            _toggleSelection(app.packageName);
          },
        );
      },
    );
  }
}
