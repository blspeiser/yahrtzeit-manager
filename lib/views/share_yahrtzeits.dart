import 'package:flutter/material.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit.dart';
import '../services/yahrtzeits_manager.dart';
import '../services/export_service.dart';

class ShareYahrtzeitsPage extends StatefulWidget {
  const ShareYahrtzeitsPage({Key? key}) : super(key: key);

  @override
  _ShareYahrtzeitsPageState createState() => _ShareYahrtzeitsPageState();
}

class _ShareYahrtzeitsPageState extends State<ShareYahrtzeitsPage> {
  final YahrtzeitsManager _manager = YahrtzeitsManager();
  final ExportService _exportService = ExportService();
  List<Yahrtzeit> _allYahrtzeits = [];
  Set<String> _selectedIds = {};
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadYahrtzeits();
  }

  Future<void> _loadYahrtzeits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final yahrtzeits = await _manager.getAllYahrtzeits();
      setState(() {
        _allYahrtzeits = yahrtzeits;
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
        title: Text(
          AppLocalizations.of(context)!.translate('share_yahrtzeits'),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 50, 4, 129),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _allYahrtzeits.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('you_have_not_added_any_yahrtzeits_yet.'),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _allYahrtzeits.length,
                        itemBuilder: (context, index) {
                          final yahrtzeit = _allYahrtzeits[index];
                          final isSelected = _selectedIds.contains(yahrtzeit.id);

                          return CheckboxListTile(
                            title: Text(yahrtzeit.englishName ?? ''),
                            subtitle: Text(yahrtzeit.hebrewName ?? ''),
                            value: isSelected,
                            onChanged: (_) => _toggleSelection(yahrtzeit.id),
                            secondary: yahrtzeit.group != null
                                ? Chip(
                                    label: Text(yahrtzeit.group!),
                                    labelStyle: TextStyle(fontSize: 12),
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isExporting || _selectedIds.isEmpty
                                  ? null
                                  : _shareSelected,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 50, 4, 129),
                            padding: EdgeInsets.symmetric(vertical: 16),
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
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
