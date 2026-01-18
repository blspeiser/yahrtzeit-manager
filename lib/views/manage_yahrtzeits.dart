import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kosher_dart/kosher_dart.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit.dart';
import '../providers/settings_provider.dart';
import '../services/yahrtzeits_manager.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon_decorative.dart';
import 'add_yahrtzeit.dart';
import 'share_yahrtzeits.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ManageYahrtzeits extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const ManageYahrtzeits({Key? key, this.onDataChanged}) : super(key: key);

  @override
  _ManageYahrtzeitsState createState() => _ManageYahrtzeitsState();
}

class _ManageYahrtzeitsState extends State<ManageYahrtzeits> {
  List<Yahrtzeit> yahrtzeits = [];
  List<Yahrtzeit> filteredYahrtzeits = [];
  bool isLoading = true;
  String? selectedGroup;
  List<String> availableGroups = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final YahrtzeitsManager manager = YahrtzeitsManager();
  final ExportService _exportService = ExportService();

  @override
  void initState() {
    super.initState();
    fetchYahrtzeits();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await manager.getAllGroups();
    setState(() {
      availableGroups = groups;
      // Reset filter to show all if no group is selected
      if (selectedGroup == null) {
        filteredYahrtzeits = List.from(yahrtzeits);
      } else {
        // Reapply current filter
        _filterByGroup(selectedGroup);
      }
    });
  }

  void _filterByGroup(String? group) {
    // Safety check: if no data, reset filter
    if (yahrtzeits.isEmpty) {
      setState(() {
        selectedGroup = null;
        filteredYahrtzeits = [];
      });
      return;
    }

    setState(() {
      selectedGroup = group;
      if (group == null || group.isEmpty) {
        filteredYahrtzeits = List.from(yahrtzeits);
      } else {
        filteredYahrtzeits = yahrtzeits.where((yahrtzeit) {
          return yahrtzeit.group == group;
        }).toList();
      }
    });
  }

  Future<void> writeData(List<Map<String, dynamic>> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('yahrtzeit_data', json.encode(data));
  }

  Future<List<Yahrtzeit>> readData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('yahrtzeit_data');
    if (jsonString != null) {
      List<Map<String, dynamic>> jsonData =
          List<Map<String, dynamic>>.from(json.decode(jsonString));
      return jsonData.map((data) => Yahrtzeit.fromJson(data)).toList();
    } else {
      return [];
    }
  }

  Future<void> fetchYahrtzeits() async {
    try {
      // Use manager to ensure consistency with how data is saved
      final fetchedYahrtzeits = await manager.getAllYahrtzeits();

      final filteredYahrtzeits = _filterDuplicateYahrtzeits(fetchedYahrtzeits);

      setState(() {
        this.yahrtzeits = filteredYahrtzeits;
        // Reset filter when data loads - show all by default if we have data
        if (filteredYahrtzeits.isEmpty) {
          selectedGroup = null;
          this.filteredYahrtzeits = [];
        } else {
          // Only reset filter if we had a selectedGroup but no matching data
          if (selectedGroup != null && filteredYahrtzeits.isNotEmpty) {
            // Check if selectedGroup still exists in the data
            final hasMatchingGroup =
                filteredYahrtzeits.any((y) => y.group == selectedGroup);
            if (!hasMatchingGroup) {
              selectedGroup = null;
            }
          }
          this.filteredYahrtzeits = List.from(filteredYahrtzeits);
        }
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listKey.currentState != null) {
          for (var i = 0; i < yahrtzeits.length; i++) {
            _listKey.currentState?.insertItem(i);
          }
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        yahrtzeits = [];
        filteredYahrtzeits = [];
      });
    }
  }

  List<Yahrtzeit> _filterDuplicateYahrtzeits(List<Yahrtzeit> yahrtzeits) {
    final uniqueNames = <String>{};
    final filteredList = <Yahrtzeit>[];

    for (var i = 0; i < yahrtzeits.length; i++) {
      final yahrtzeit = yahrtzeits[i];
      try {
        // Show all yahrtzeits, including those without day/month (incomplete entries)
        // Filter duplicates by English name, but allow empty strings and null values
        final englishName = yahrtzeit.englishName?.trim();
        if (englishName != null && englishName.isNotEmpty) {
          // Has English name - check for duplicates
          if (uniqueNames.add(englishName)) {
            filteredList.add(yahrtzeit);
          }
        } else {
          // No English name or empty - still include it (English name is required but might be missing in old data)
          // Use ID as unique identifier for entries without English name
          final uniqueId = 'no_name_${yahrtzeit.id}';
          if (uniqueNames.add(uniqueId)) {
            filteredList.add(yahrtzeit);
          }
        }
      } catch (e) {
        // Skip invalid entries
      }
    }

    return filteredList;
  }

  Future<void> _editYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddYahrtzeitPage(
            yahrtzeit: yahrtzeit,
            isEditing: true,
          ),
        ),
      );

      if (result == true) {
        // Reload data and refresh UI
        await fetchYahrtzeits();
        _loadGroups();
        // Reapply filter if one is selected
        if (selectedGroup != null) {
          _filterByGroup(selectedGroup);
        }
        // Notify parent to refresh Upcoming tab
        if (widget.onDataChanged != null) {
          widget.onDataChanged!();
        }
      }
    } catch (e) {
      print('Error editing Yahrtzeit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('edit_failed')),
        ),
      );
    }
  }

  Future<void> _deleteYahrtzeitFromFile(Yahrtzeit yahrtzeit) async {
    try {
      // Use manager to delete - it handles everything consistently
      await manager.deleteYahrtzeit(yahrtzeit);
    } catch (e) {
      // Error handled by caller
    }
  }

  void _showDeleteConfirmation(Yahrtzeit yahrtzeit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('delete')),
          content: Text(
            '${AppLocalizations.of(context)!.translate('delete')} ${yahrtzeit.englishName ?? yahrtzeit.hebrewName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.translate('close')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteYahrtzeit(yahrtzeit);
              },
              child: Text(
                AppLocalizations.of(context)!.translate('delete'),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      await _deleteYahrtzeitFromFile(yahrtzeit);
      await fetchYahrtzeits();
      _loadGroups();
      // Reapply filter if one is selected
      if (selectedGroup != null) {
        _filterByGroup(selectedGroup);
      }
      // Notify parent to refresh Upcoming tab
      if (widget.onDataChanged != null) {
        widget.onDataChanged!();
      }
    } catch (e) {
      print('Error while deleting yahrtzeit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.translate('deletion_failed')),
        ),
      );
    }
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(AppLocalizations.of(context)!.translate('share_yahrtzeits')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.list),
                title:
                    Text(AppLocalizations.of(context)!.translate('share_all')),
                onTap: () {
                  Navigator.of(context).pop();
                  _shareAll();
                },
              ),
              ListTile(
                leading: Icon(Icons.filter_list),
                title: Text(
                    AppLocalizations.of(context)!.translate('share_by_group')),
                onTap: () {
                  Navigator.of(context).pop();
                  _showGroupSelectionDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.check_box),
                title: Text(AppLocalizations.of(context)!
                    .translate('select_individual')),
                onTap: () {
                  Navigator.of(context).pop();
                  _shareIndividual();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareAll() async {
    try {
      await _exportService.exportYahrtzeits(yahrtzeits, fileName: 'all');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('yahrtzeits_shared_successfully')),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
          ),
        );
      }
    }
  }

  void _showGroupSelectionDialog() {
    if (availableGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.translate('no_groups_available')),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('select_group')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableGroups.map((group) {
                return ListTile(
                  title: Text(group),
                  onTap: () {
                    Navigator.of(context).pop();
                    _shareByGroup(group);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareByGroup(String group) async {
    try {
      final groupYahrtzeits =
          yahrtzeits.where((y) => y.group == group).toList();

      if (groupYahrtzeits.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('no_yahrtzeits_in_group')),
          ),
        );
        return;
      }

      await _exportService.exportYahrtzeits(groupYahrtzeits, fileName: group);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('yahrtzeits_shared_successfully')),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
          ),
        );
      }
    }
  }

  void _shareIndividual() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareYahrtzeitsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final manager = YahrtzeitsManager();

    return Scaffold(
      appBar: AppBar(
        leading: AppIconDecorative(),
        title: Text(
          AppLocalizations.of(context)!.translate('manage_yahrzeits'),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'add') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddYahrtzeitPage(),
                  ),
                ).then((result) {
                  if (result == true) {
                    fetchYahrtzeits();
                    _loadGroups();
                    // Notify parent to refresh Upcoming tab
                    if (widget.onDataChanged != null) {
                      widget.onDataChanged!();
                    }
                  }
                });
              } else if (value == 'share') {
                _showShareDialog();
              } else if (value == 'sync') {
                final result = await manager.syncWithCalendar();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  fetchYahrtzeits();
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 20, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text(AppLocalizations.of(context)!
                        .translate('add_yahrtzeit')),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text(AppLocalizations.of(context)!.translate('share')),
                  ],
                ),
              ),
              if (settingsProvider.syncSettings)
                PopupMenuItem<String>(
                  value: 'sync',
                  child: Row(
                    children: [
                      Icon(Icons.sync, size: 20, color: AppTheme.primaryColor),
                      SizedBox(width: 12),
                      Text(AppLocalizations.of(context)!
                          .translate('sync_with_calendar')),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (availableGroups.isNotEmpty)
            Container(
              color: AppTheme.backgroundColor,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      label: AppLocalizations.of(context)!.translate('all'),
                      isSelected: selectedGroup == null,
                      onTap: () => _filterByGroup(null),
                    ),
                    SizedBox(width: 8),
                    ...availableGroups.map((group) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: _buildFilterChip(
                          context,
                          label: group,
                          isSelected: selectedGroup == group,
                          onTap: () => _filterByGroup(group),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: Builder(
                builder: (context) {
                  return isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor),
                          ),
                        )
                      : filteredYahrtzeits.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.translate(
                                    'you_have_not_added_any_yahrtzeits_yet'),
                                style: TextStyle(
                                    fontSize: 18, color: AppTheme.textTertiary),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredYahrtzeits.length,
                              itemBuilder: (context, index) {
                                return _buildYahrtzeitTile(
                                    filteredYahrtzeits[index]);
                              },
                            );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? AppTheme.primaryColor : AppTheme.cardBorderColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColorWithOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.inactiveTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildYahrtzeitTile(Yahrtzeit yahrtzeit) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final jewishLanguage = settingsProvider.jewishLanguage;

    // Build date display string
    String? dateDisplay;
    TextDirection textDirection =
        (jewishLanguage == 'he') ? TextDirection.rtl : TextDirection.ltr;
    TextAlign textAlign =
        (jewishLanguage == 'he') ? TextAlign.right : TextAlign.left;
    if (yahrtzeit.day != null && yahrtzeit.month != null) {
      var day = null, month = null;
      if (jewishLanguage == 'he') {
        // Hebrew format: Use HebrewDateFormatter methods
        final hebrewFormatter = HebrewDateFormatter()
          ..hebrewFormat = true
          ..useGershGershayim = true;

        day = hebrewFormatter.formatHebrewNumber(yahrtzeit.day!);
        month = hebrewFormatter.hebrewMonths[yahrtzeit.month! - 1];
        if (yahrtzeit.month! == JewishDate.ADAR_II || yahrtzeit.month! == 14) {
          //14 is technically Adar I instead of just Adar (there isn't a constant on JewishDate for Adar I, but HebrewDateFormatter has a month for it)
          month = month + '\'';
        }
      } //otherwise use English:
      if (day == null || month == null) {
        final hebrewFormatter = HebrewDateFormatter();
        day = yahrtzeit.day.toString();
        month = hebrewFormatter.transliteratedMonths[yahrtzeit.month! - 1];
      }
      dateDisplay = '$day $month';
    }
    // If date is not configured, dateDisplay remains null and won't be shown

    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.cardBorderColor, width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          _editYahrtzeit(yahrtzeit);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yahrtzeit.englishName ?? '',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textCardTitle,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 4),
                    Text(
                      yahrtzeit.hebrewName ?? '',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textCardTitle,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (dateDisplay != null) ...[
                      SizedBox(height: 6),
                      Text(
                        dateDisplay,
                        textDirection: textDirection,
                        textAlign: textAlign,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 4),
              PopupMenuButton<String>(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editYahrtzeit(yahrtzeit);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(yahrtzeit);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit,
                            size: 18, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.translate('edit')),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.translate('delete')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
