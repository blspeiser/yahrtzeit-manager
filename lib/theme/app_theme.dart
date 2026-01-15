import 'package:flutter/material.dart';

class AppTheme {
  // Primary theme color (matches app icon background)
  static const Color primaryColor = Color(0xFFB4B4B4);
  
  // Selected/Active colors (darker for better contrast)
  static const Color selectedColor = Color(0xFF757575); // Colors.grey[600] - darker for selected tabs
  
  // Inactive/Unselected colors
  static const Color unselectedColor = Color(0xFFBDBDBD); // Colors.grey[400] - lighter for unselected
  static const Color inactiveTextColor = Color(0xFF757575); // Colors.grey[600]
  
  // Background colors
  static const Color backgroundColor = Color(0xFFFAFAFA); // Colors.grey[50]
  static const Color cardBorderColor = Color(0xFFE0E0E0); // Colors.grey[200]
  
  // Text colors
  static const Color textPrimary = Colors.black87;
  static const Color textCardTitle = Color(0xFF616161); // Colors.grey[700] - softer, less intense
  static const Color textSecondary = Color(0xFF757575); // Colors.grey[600]
  static const Color textTertiary = Colors.grey;
  
  // Other UI colors
  static const Color dividerColor = Color(0xFFE0E0E0); // Colors.grey[200]
  
  // Helper method for primary color with opacity
  static Color primaryColorWithOpacity(double opacity) {
    return primaryColor.withOpacity(opacity);
  }
}
