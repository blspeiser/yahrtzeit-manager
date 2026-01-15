import 'package:flutter/material.dart';

/// A decorative app icon widget for use in AppBars.
/// This is non-interactive and serves purely for branding purposes.
/// Automatically shows a back button when navigation is available.
class AppIconDecorative extends StatelessWidget {
  final double size;
  
  const AppIconDecorative({
    Key? key,
    this.size = 28.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    
    if (canPop) {
      // Show back button and icon side by side
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 8.0),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    } else {
      // Just show the icon
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
