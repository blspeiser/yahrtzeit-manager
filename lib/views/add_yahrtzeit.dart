import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/yahrtzeit.dart';
import '../services/yahrtzeits_manager.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon_decorative.dart';
import 'package:kosher_dart/kosher_dart.dart';
import '../localizations/app_localizations.dart';

class AddYahrtzeitPage extends StatefulWidget {
  final Yahrtzeit? yahrtzeit;
  final bool isEditing;

  AddYahrtzeitPage({
    this.yahrtzeit,
    this.isEditing = false,
  });

  @override
  _AddYahrtzeitPageState createState() => _AddYahrtzeitPageState();
}

class _AddYahrtzeitPageState extends State<AddYahrtzeitPage> {
  final _formKey = GlobalKey<FormState>();
  final _englishNameController = TextEditingController();
  final _hebrewNameController = TextEditingController();
  final _groupController = TextEditingController();
  int? _selectedDay;
  int? _selectedMonth;
  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<String> _availableGroups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
    if (widget.isEditing && widget.yahrtzeit != null) {
      _englishNameController.text = widget.yahrtzeit!.englishName ?? '';
      _hebrewNameController.text = widget.yahrtzeit!.hebrewName ?? '';
      _selectedDay = widget.yahrtzeit!.day;
      _selectedMonth = widget.yahrtzeit!.month;
      _groupController.text = widget.yahrtzeit!.group ?? '';
    }
  }

  List<DropdownMenuItem<int?>> _buildDayItems(String jewishLanguage, AppLocalizations localizations) {
    final items = <DropdownMenuItem<int?>>[];
    HebrewDateFormatter? hebrewFormatter;
    if (jewishLanguage == 'he') {
      hebrewFormatter = HebrewDateFormatter()
        ..hebrewFormat = true
        ..useGershGershayim = true;
    }

    // Add null option for "Not set"
    items.add(DropdownMenuItem<int?>(
      value: null,
      child: Text(localizations.translate('not_set')),
    ));

    for (int day = 1; day <= 30; day++) {
      String displayText;
      if (jewishLanguage == 'he' && hebrewFormatter != null) {
        displayText = hebrewFormatter.formatHebrewNumber(day);
      } else {
        displayText = day.toString();
      }
      items.add(DropdownMenuItem<int?>(
        value: day,
        child: Text(displayText),
      ));
    }
    return items;
  }

  List<DropdownMenuItem<int?>> _buildMonthItems(String jewishLanguage, AppLocalizations localizations) {
    final items = <DropdownMenuItem<int?>>[];
    HebrewDateFormatter hebrewFormatter = HebrewDateFormatter();
    TextDirection textDirection =
        (jewishLanguage == 'he') ? TextDirection.rtl : TextDirection.ltr;
    TextAlign textAlign =
        (jewishLanguage == 'he') ? TextAlign.right : TextAlign.left;
    
    // Add null option for "Not set"
    items.add(DropdownMenuItem<int?>(
      value: null,
      child: Text(localizations.translate('not_set'),
          textDirection: textDirection, textAlign: textAlign),
    ));
    
    for (int month = 0; month < 12; month++) {
      String displayText = (jewishLanguage == 'he')
          ? hebrewFormatter.hebrewMonths[month]
          : hebrewFormatter.transliteratedMonths[month];
      items.add(DropdownMenuItem<int?>(
        value: month +
            1, //Months in JewishDate are 1-indexed, months in HebrewDateFormatter are 0-indexed
        child: Text(displayText,
            textDirection: textDirection, textAlign: textAlign),
      ));
    }
    // Special handling for Adar I (month 13) && Adar II (month 12)
    String suffix = (jewishLanguage == 'he') ? '\'' : '';
    items.add(DropdownMenuItem<int?>(
      value:
          14, //Months in JewishDate are 1-indexed, months in HebrewDateFormatter are 0-indexed
      child: Text(
          ((jewishLanguage == 'he')
                  ? hebrewFormatter.hebrewMonths[13]
                  : hebrewFormatter.transliteratedMonths[13]) +
              suffix,
          textDirection: textDirection,
          textAlign: textAlign),
    ));
    items.add(DropdownMenuItem<int?>(
        value:
            13, //Months in JewishDate are 1-indexed, months in HebrewDateFormatter are 0-indexed
        child: Text(
            ((jewishLanguage == 'he')
                    ? hebrewFormatter.hebrewMonths[12]
                    : hebrewFormatter.transliteratedMonths[12]) +
                suffix,
            textDirection: textDirection,
            textAlign: textAlign)));
    return items;
  }

  Future<void> _loadGroups() async {
    final groups = await manager.getAllGroups();
    setState(() {
      _availableGroups = groups;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final localizations = AppLocalizations.of(context)!;
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      try {
        final newYahrtzeit = Yahrtzeit(
          englishName: _englishNameController.text.trim().isEmpty
              ? null
              : _englishNameController.text.trim(),
          hebrewName: _hebrewNameController.text.trim().isEmpty
              ? null
              : _hebrewNameController.text.trim(),
          day: _selectedDay,
          month: _selectedMonth,
          group: _groupController.text.trim().isEmpty
              ? null
              : _groupController.text.trim(),
          id: widget.isEditing && widget.yahrtzeit != null
              ? widget.yahrtzeit!.id
              : null, // Preserve ID when editing
        );

        if (widget.isEditing && widget.yahrtzeit != null) {
          // Update existing yahrtzeit - manager handles file updates
          await manager.updateYahrtzeit(
            widget.yahrtzeit!,
            newYahrtzeit,
            settingsProvider.years,
            settingsProvider.syncSettings,
            notificationsEnabled: settingsProvider.notifications,
            daysBefore: settingsProvider.days,
          );
        } else {
          // Add new yahrtzeit - use manager to handle all persistence
          await manager.addYahrtzeit(newYahrtzeit, settingsProvider.years,
              settingsProvider.syncSettings,
              notificationsEnabled: settingsProvider.notifications,
              daysBefore: settingsProvider.days);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.translate('data_saved')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.primaryColor,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(localizations.translate('error')),
              content: Text('${localizations.translate('error')}: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(localizations.translate('ok')),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final jewishLanguage = settingsProvider.jewishLanguage;
        return Scaffold(
          appBar: AppBar(
            leading: AppIconDecorative(),
            title: Text(
              widget.isEditing
                  ? localizations.translate('edit_yahrtzeit')
                  : localizations.translate('add_yahrtzeit'),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
          ),
          backgroundColor: AppTheme.backgroundColor,
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: 400), // Extra padding at bottom for keyboard + dropdown
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _englishNameController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: localizations.translate('english_name'),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppTheme.cardBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppTheme.cardBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations
                              .translate('please_enter_english_name');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _hebrewNameController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: localizations.translate('hebrew_name'),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppTheme.cardBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppTheme.cardBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      // Hebrew name is optional
                      validator: null,
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<int?>(
                      style: TextStyle(color: Colors.black),
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: localizations.translate('day'),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppTheme.cardBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppTheme.cardBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      value: _selectedDay,
                      items: _buildDayItems(jewishLanguage, localizations),
                      onChanged: (value) {
                        setState(() {
                          _selectedDay = value;
                        });
                      },
                      // Day is optional
                      validator: null,
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<int?>(
                      style: TextStyle(color: Colors.black),
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: localizations.translate('month'),
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppTheme.cardBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppTheme.cardBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      value: _selectedMonth,
                      items: _buildMonthItems(jewishLanguage, localizations),
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value;
                        });
                      },
                      // Month is optional
                      validator: null,
                    ),
                    SizedBox(height: 20),
                    Autocomplete<String>(
                      key: ValueKey(_groupController.text),
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _availableGroups;
                        }
                        return _availableGroups.where((group) => group
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        setState(() {
                          _groupController.text = selection;
                        });
                      },
                      initialValue:
                          TextEditingValue(text: _groupController.text),
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        // Initialize controller with current value
                        if (textEditingController.text !=
                            _groupController.text) {
                          textEditingController.text = _groupController.text;
                        }
                        // Update _groupController when user types
                        textEditingController.addListener(() {
                          if (_groupController.text !=
                              textEditingController.text) {
                            _groupController.text = textEditingController.text;
                          }
                        });
                        // Scroll to field when it gains focus to make room for dropdown
                        focusNode.addListener(() {
                          if (focusNode.hasFocus) {
                            // Wait for keyboard to appear, then scroll
                            Future.delayed(Duration(milliseconds: 500), () {
                              if (mounted && focusNode.hasFocus) {
                                Scrollable.ensureVisible(
                                  context,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  alignment:
                                      0.2, // Position field near top to leave room below
                                );
                              }
                            });
                          }
                        });
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          style: TextStyle(color: Colors.black),
                          onFieldSubmitted: (String value) {
                            _groupController.text = value;
                            onFieldSubmitted();
                          },
                          decoration: InputDecoration(
                            labelText: localizations.translate('group_name'),
                            labelStyle:
                                TextStyle(color: AppTheme.textSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: AppTheme.cardBorderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: AppTheme.cardBorderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppTheme.primaryColor, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        localizations
                            .translate(widget.isEditing ? 'update' : 'save'),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
