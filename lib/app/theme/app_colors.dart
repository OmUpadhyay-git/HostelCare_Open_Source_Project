import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Base palette - Light
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFF2F2F5);
  static const surfaceElevatedLight = Color(0xFFFFFFFF);
  static const onSurfaceLight = Color(0xFF1A1A1A);
  static const onSurfaceMutedLight = Color(0xFF6B6B6F);
  static const outlineLight = Color(0xFFDADADD);

  // Base palette - Dark
  static const surfaceDark = Color(0xFF121212);
  static const surfaceVariantDark = Color(0xFF1E1E1E);
  static const surfaceElevatedDark = Color(0xFF242424);
  static const onSurfaceDark = Color(0xFFEDEDED);
  static const onSurfaceMutedDark = Color(0xFFA0A0A5);
  static const outlineDark = Color(0xFF33333A);

  // Brand / Primary
  static const primary = Color(0xFF2F6FED);
  static const primaryContainerLight = Color(0xFFE4ECFD);
  static const primaryContainerDark = Color(0xFF16264A);
  static const onPrimary = Color(0xFFFFFFFF);

  // Status colors
  static const statusPending = Color(0xFFE0A100);
  static const statusAccepted = Color(0xFF2F6FED);
  static const statusAssigned = Color(0xFF5B5FEF);
  static const statusInProgress = Color(0xFF0E8A7D);
  static const statusResolved = Color(0xFF2E9E44);
  static const statusVerified = Color(0xFF1F7A34);
  static const statusClosed = Color(0xFF6B6B6F);
  static const statusNegative = Color(0xFFD64545);
  static const statusReopened = Color(0xFFE0672C);
  static const statusOnHold = Color(0xFF7A7F87);

  // Priority colors
  static const priorityLow = Color(0xFF6B6B6F);
  static const priorityMedium = Color(0xFF2F6FED);
  static const priorityHigh = Color(0xFFE0672C);
  static const priorityUrgent = Color(0xFFD64545);

  // Semantic colors
  static const success = Color(0xFF2E9E44);
  static const warning = Color(0xFFE0A100);
  static const error = Color(0xFFD64545);
  static const info = Color(0xFF2F6FED);
}
