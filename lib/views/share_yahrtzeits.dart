import 'package:flutter/material.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit.dart';
import '../services/yahrtzeits_manager.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon_decorative.dart';

class ShareYahrtzeitsPage extends StatefulWidget {
  const ShareYahrtzeitsPage({super.key});

  @override
  State<ShareYahrtzeitsPage> createState() => _ShareYahrtzeitsPageState();
}

class _ShareYahrtzeitsPageState extends State<ShareYahrtzeitsPage> {
  final YahrtzeitsManager _manager = YahrtzeitsManager();
  final ExportService _exportService = ExportService();
  final TextEditingController _searchController = TextEditingController();
  List<Yahrtzeit> _allYahrtzeits = [];
  List<Yahrtzeit> _filteredYahrtzeits = [];
  Set<String> _selectedIds = {};
  bool _isLoading = true;
  bool _isExporting = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadYahrtzeits();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredYahrtzeits = List.from(_allYahrtzeits);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredYahrtzeits = _allYahrtzeits.where((y) {
        final englishName = y.englishName?.toLowerCase() ?? '';
        final hebrewName = y.hebrewName?.toLowerCase() ?? '';
        final group = y.group?.toLowerCase() ?? '';
        return englishName.contains(query) ||
            hebrewName.contains(query) ||
            group.contains(query);
      }).toList();
    }
  }

  Future<void> _loadYahrtzeits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final yahrtzeits = await _manager.getAllYahrtzeits();
      setState(() {
        _allYahrtzeits = yahrtzeits;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading yahrtzeits: $e'),
          ),
        );
      }
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds = _allYahrtzeits.map((y) => y.id).toSet();
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedIds.clear();
    });
  }

  Future<void> _shareSelected() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('please_select_yahrtzeits_to_share')),
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final selectedYahrtzeits =
          _allYahrtzeits.where((y) => _selectedIds.contains(y.id)).toList();
      
      // Determine filename based on selection
      String? fileName;
      if (selectedYahrtzeits.length == 1) {
        // Single yahrtzeit - use english name
        fileName = selectedYahrtzeits.first.englishName;
      } else {
        // Multiple - check if all same group
        final groups = selectedYahrtzeits
            .map((y) => y.group)
            .where((g) => g != null && g.isNotEmpty)
            .toSet();
        if (groups.length == 1) {
          fileName = groups.first;
        }
        // Otherwise fileName is null, will default to "all"
      }
      
      await _exportService.exportYahrtzeits(selectedYahrtzeits, fileName: fileName);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('yahrtzeits_shared_successfully')),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing yahrtzeits: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppIconDecorative(),
        title: Text(
          AppLocalizations.of(context)!.translate('share_yahrtzeits'),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          if (_selectedIds.isNotEmpty)
            TextButton(
              onPressed: _deselectAll,
              child: Text(
                AppLocalizations.of(context)!.translate('deselect_all'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (_selectedIds.length < _allYahrtzeits.length)
            TextButton(
              onPressed: _selectAll,
              child: Text(
                AppLocalizations.of(context)!.translate('select_all'),
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Container(
        color: AppTheme.backgroundColor,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              )
            : _allYahrtzeits.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('you_have_not_added_any_yahrtzeits_yet.'),
                      style: TextStyle(fontSize: 18, color: AppTheme.textTertiary),
                    ),
                  )
                : Column(
                    children: [
                      // Search field
                      Container(
                        color: AppTheme.backgroundColor,
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.translate('search'),
                            hintStyle: TextStyle(color: AppTheme.textTertiary),
                            prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.cardBorderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.cardBorderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.selectedColor, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      // List content
                      Expanded(
                        child: _filteredYahrtzeits.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(context)!.translate('no_results_found'),
                                  style: TextStyle(fontSize: 16, color: AppTheme.textTertiary),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredYahrtzeits.length,
                                itemBuilder: (context, index) {
                                  final yahrtzeit = _filteredYahrtzeits[index];
                                  final isSelected = _selectedIds.contains(yahrtzeit.id);

                                  return _buildYahrtzeitSelectionTile(yahrtzeit, isSelected);
                                },
                              ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(16),
                        child: SafeArea(
                          top: false,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isExporting || _selectedIds.isEmpty
                                      ? null
                                      : _shareSelected,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                disabledBackgroundColor: AppTheme.cardBorderColor,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isExporting
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!
                                          .translate('share_selected'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildYahrtzeitSelectionTile(Yahrtzeit yahrtzeit, bool isSelected) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.selectedColor : AppTheme.cardBorderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected ? AppTheme.primaryColorWithOpacity(0.1) : Colors.white,
      child: InkWell(
        onTap: () => _toggleSelection(yahrtzeit.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelection(yahrtzeit.id),
                activeColor: AppTheme.selectedColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // English name
                    Text(
                      yahrtzeit.englishName ?? '',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textCardTitle,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    // Hebrew name
                    if (yahrtzeit.hebrewName != null && yahrtzeit.hebrewName!.isNotEmpty) ...[
                      SizedBox(height: 3),
                      Text(
                        yahrtzeit.hebrewName!,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                    // Group
                    if (yahrtzeit.group != null && yahrtzeit.group!.isNotEmpty) ...[
                      SizedBox(height: 3),
                      Text(
                        yahrtzeit.group!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
