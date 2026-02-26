import 'package:flutter/material.dart';

/// Central theme constants for Hayd Kalender
class AppTheme {
  // Primary palette
  static const Color rose       = Color(0xFFE8436A);
  static const Color roseSoft   = Color(0xFFF472A0);
  static const Color roseLight  = Color(0xFFFDE8EF);
  static const Color rosePale   = Color(0xFFFFF0F5);
  static const Color plum       = Color(0xFF8B3A62);
  static const Color plumLight  = Color(0xFFC97FA8);
  static const Color lavender   = Color(0xFFC4A8D4);
  static const Color lavLight   = Color(0xFFF0E8F8);

  // Status colors
  static const Color mint       = Color(0xFF5CBFA0);
  static const Color mintLight  = Color(0xFFE0F5EF);
  static const Color gold       = Color(0xFFD4A853);
  static const Color goldLight  = Color(0xFFFDF3DC);

  // Neutrals
  static const Color ivory      = Color(0xFFFDFAF6);
  static const Color warmGray   = Color(0xFF7A6B72);
  static const Color darkPlum   = Color(0xFF3D1F30);

  // Calendar day colors
  static const Color haydDay     = rose;
  static const Color istihadaDay = gold;
  static const Color tuhrDay     = mint;
  static const Color pendingDay  = lavender;

  // Typography
  static const String displayFont = 'PlayfairDisplay';
  static const String bodyFont    = 'Lato';
}
