import 'package:flutter/material.dart';
import 'dart:io';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit_library.dart';
import '../services/import_service.dart';
import '../services/yahrtzeits_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon_decorative.dart';
import '../home_page.dart';

class ImportYahrtzeitsPage extends StatefulWidget {
  final String filePath;

  const ImportYahrtzeitsPage({Key? key, required this.filePath})
      : super(key: key);

  @override
  _ImportYahrtzeitsPageState createState() => _ImportYahrtzeitsPageState();
}

class _ImportYahrtzeitsPageState extends State<ImportYahrtzeitsPage> {
  final ImportService _importService = ImportService();
  final YahrtzeitsManager _manager = YahrtzeitsManager();
  YahrtzeitLibrary? _library;
  bool _isLoading = true;
  bool _isImporting = false;
  String? _selectedGroup;
  List<String> _availableGroups = [];
  String? _error;
  Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadFile();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await _manager.getAllGroups();
    setState(() {
      _availableGroups = groups;
    });
  }

  Future<void> _loadFile() async {
    try {
      final file = await _readFileForPreview(widget.filePath);
      if (file != null) {
        setState(() {
          _library = file;
          _selectedIds = file.yahrtzeits.map((y) => y.id).toSet(); // Select all by default
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to read file';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading file: $e';
        _isLoading = false;
      });
    }
  }

  Future<YahrtzeitLibrary?> _readFileForPreview(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final library = YahrtzeitLibrary.fromJsonString(jsonString);
      return library;
    } catch (e) {
      return null;
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
    if (_library != null) {
      setState(() {
        _selectedIds = _library!.yahrtzeits.map((y) => y.id).toSet();
      });
    }
  }

  void _deselectAll() {
    setState(() {
      _selectedIds.clear();
    });
  }

  Future<void> _import() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('please_select_yahrtzeits_to_import')),
        ),
      );
      return;
    }

    setState(() {
      _isImporting = true;
    });

    try {
      // Filter to only selected yahrtzeits
      final selectedYahrtzeits = _library!.yahrtzeits
          .where((y) => _selectedIds.contains(y.id))
          .toList();

      // Create a temporary library with only selected items
      final filteredLibrary = YahrtzeitLibrary(
        version: _library!.version,
        exportDate: _library!.exportDate,
        yahrtzeits: selectedYahrtzeits,
      );

      // Write to temp file and import
      final tempFile = File('${widget.filePath}.temp');
      await tempFile.writeAsString(filteredLibrary.toJsonString());

      final result = await _importService.importYahrtzeitsFromFile(
        tempFile.path,
        bulkGroupOverride: _selectedGroup,
      );

      // Clean up temp file
      try {
        await tempFile.delete();
      } catch (e) {
        // Ignore deletion errors
      }

      if (mounted) {
        final message = _buildImportMessage(result);
        
        // Navigate to HomePage and switch to Manage tab
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage(initialTab: 1)),
          (route) => false,
        ).then((_) {
          // Show success message after navigation completes
          // Use a slight delay to ensure the new context is ready
          Future.delayed(Duration(milliseconds: 300), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: Duration(seconds: 4),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            }
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _buildImportMessage(ImportResult result) {
    final parts = <String>[];
    if (result.successCount > 0) {
      parts.add(
          '${result.successCount} ${AppLocalizations.of(context)!.translate('imported_successfully')}');
    }
    if (result.duplicateCount > 0) {
      parts.add(
          '${result.duplicateCount} ${AppLocalizations.of(context)!.translate('duplicates_skipped')}');
    }
    if (result.failureCount > 0) {
      parts.add(
          '${result.failureCount} ${AppLocalizations.of(context)!.translate('failed')}');
    }
    return parts.isEmpty
        ? AppLocalizations.of(context)!.translate('import_complete')
        : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppIconDecorative(),
        title: Text(
          AppLocalizations.of(context)!.translate('import_yahrtzeits'),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Container(
        color: AppTheme.backgroundColor,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              )
            : _error != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            _error!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => HomePage()),
                              (route) => false,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                            child: Text(AppLocalizations.of(context)!
                                .translate('close')),
                          ),
                        ],
                      ),
                    ),
                  )
                : _library == null || _library!.yahrtzeits.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)!
                              .translate('no_yahrtzeits_found_in_file'),
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          // Group override section
                          Container(
                            padding: EdgeInsets.all(16),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .translate('group_override'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.translate(
                                      'group_override_description'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _selectedGroup,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .translate('select_group'),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppTheme.cardBorderColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppTheme.cardBorderColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppTheme.primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text(AppLocalizations.of(context)!
                                          .translate('use_original_groups')),
                                    ),
                                    ..._availableGroups.map((group) =>
                                        DropdownMenuItem<String>(
                                          value: group,
                                          child: Text(group),
                                        )),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGroup = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          // Selection info
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _library != null && 
                                          _selectedIds.length == _library!.yahrtzeits.length,
                                      onChanged: (value) {
                                        if (value == true) {
                                          _selectAll();
                                        } else {
                                          _deselectAll();
                                        }
                                      },
                                      activeColor: AppTheme.primaryColor,
                                    ),
                                    Text(
                                      '${_selectedIds.length} / ${_library!.yahrtzeits.length} ${AppLocalizations.of(context)!.translate('selected')}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Preview list
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.only(bottom: 80),
                              itemCount: _library!.yahrtzeits.length,
                              itemBuilder: (context, index) {
                                final yahrtzeit = _library!.yahrtzeits[index];
                                final displayGroup =
                                    _selectedGroup ?? yahrtzeit.group ?? '';
                                final isSelected = _selectedIds.contains(yahrtzeit.id);

                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  elevation: 1,
                                  color: Colors.white,
                                  child: CheckboxListTile(
                                    value: isSelected,
                                    onChanged: (_) => _toggleSelection(yahrtzeit.id),
                                    title: Text(
                                      yahrtzeit.englishName ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (yahrtzeit.hebrewName != null &&
                                            yahrtzeit.hebrewName!.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Text(
                                              yahrtzeit.hebrewName!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                        if (displayGroup.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Chip(
                                              label: Text(
                                                displayGroup,
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              backgroundColor: AppTheme.backgroundColor,
                                              labelStyle: TextStyle(
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    activeColor: AppTheme.primaryColor,
                                  ),
                                );
                              },
                            ),
                          ),
                          // Import button
                          Container(
                            padding: EdgeInsets.all(16),
                            color: Colors.white,
                            child: SafeArea(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _isImporting || _selectedIds.isEmpty
                                          ? null
                                          : _import,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppTheme.unselectedColor,
                                    disabledForegroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isImporting
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
                                              .translate('import'),
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
}
