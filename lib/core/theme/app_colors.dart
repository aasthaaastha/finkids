import 'package:flutter/material.dart';

/// All app colors in one place.
/// Feature colors match the architecture diagram so the team always speaks
/// the same visual language.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFFEEEDFE);

  // Feature: Home
  static const Color home = Color(0xFF3B6D11);
  static const Color homeLight = Color(0xFFEAF3DE);

  // Feature: Learn
  static const Color learn = Color(0xFF534AB7);
  static const Color learnLight = Color(0xFFEEEDFE);

  // Feature: Expenses
  static const Color expenses = Color(0xFF854F0B);
  static const Color expensesLight = Color(0xFFFAEEDA);

  // Feature: Location
  static const Color location = Color(0xFF993C1D);
  static const Color locationLight = Color(0xFFFAECE7);

  // Neutrals
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
}
