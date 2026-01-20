import 'package:flutter/material.dart';

/// A decorative app icon widget for use in AppBars.
/// This is non-interactive and serves purely for branding purposes.
/// Automatically shows a back button when navigation is available.
class AppIconDecorative extends StatelessWidget {
  final double size;
  
  const AppIconDecorative({
    super.key,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    
    if (canPop) {
      // Show only back button (no icon) for screens with navigation
      return IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      );
    } else {
      // Just show the icon for top-level screens
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      );
    }
  }
}
