import 'package:flutter/material.dart';
import '../localizations/app_localizations.dart';
import '../theme/app_theme.dart';

/// Global navigator key, attached to the root [MaterialApp]. It lets
/// service-layer code (which has no [BuildContext] of its own) show a
/// permission rationale dialog before triggering an OS permission prompt.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Shows an informative dialog explaining *why* a permission is needed, before
/// the OS permission prompt appears. This is a Google Play requirement and good
/// UX: the user understands the request in context instead of seeing a bare
/// system prompt.
///
/// Strings are resolved from [AppLocalizations] via the root navigator context,
/// so the dialog is localized and inherits the current text direction.
///
/// Returns `true` if the user chose to continue (i.e. allow the OS prompt to be
/// shown), or `false` if they declined or no UI context was available yet (for
/// example when the request originates at app startup before the widget tree
/// exists).
Future<bool> showPermissionRationaleDialog({
  required String titleKey,
  required String messageKey,
  required IconData icon,
}) async {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return false;

  final localizations = AppLocalizations.of(context);

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(icon, color: AppTheme.primaryColor, size: 32),
      title: Text(localizations?.translate(titleKey) ?? titleKey),
      content: Text(localizations?.translate(messageKey) ?? messageKey),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(localizations?.translate('not_now') ?? 'Not now'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child:
              Text(localizations?.translate('continue_action') ?? 'Continue'),
        ),
      ],
    ),
  );
  return result ?? false;
}
