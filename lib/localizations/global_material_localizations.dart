import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HebrewMaterialLocalizations extends DefaultMaterialLocalizations {
  const HebrewMaterialLocalizations();

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _HebrewMaterialLocalizationsDelegate();

  @override
  String get moreButtonTooltip => 'עוד';

  // ... ניתן להוסיף כאן תרגומים נוספים ...

  static const _localizedValues = {
    'he': HebrewMaterialLocalizations(),
  };

  @override
  String get aboutListTileTitleRaw => r'אודות $applicationName';
}

class _HebrewMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _HebrewMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'he';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return SynchronousFuture<MaterialLocalizations>(
        HebrewMaterialLocalizations());
  }

  @override
  bool shouldReload(_HebrewMaterialLocalizationsDelegate old) => false;
}
