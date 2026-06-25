import 'package:flutter/material.dart';

/// JD Logistics — Hybrid Premium Ocean Claymorphism Color System
///
/// Light:
/// Clean white logistics platform with sky-blue route edges.
///
/// Dark:
/// Neumorphic ocean logistics dashboard inspired by premium enterprise
/// control towers. No black, no purple, no glassmorphism.
class AppColors {
  AppColors._();

  // ── Helper methods ─────────────────────────────────────────────────────────
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color text(BuildContext context) =>
      isDark(context) ? textWhite : textDark;

  static Color subtext(BuildContext context) =>
      isDark(context) ? darkSubtext : textDarkSecondary;

  static Color background(BuildContext context) =>
      isDark(context) ? darkBg1 : lightBg1;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color card(BuildContext context) =>
      isDark(context) ? darkCard : lightCard;

  static Color elevatedCard(BuildContext context) =>
      isDark(context) ? darkElevated : lightElevated;

  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color clayShadowColor(BuildContext context) =>
      isDark(context) ? clayShadowDark : clayShadowLight;

  static Color clayHighlightColor(BuildContext context) =>
      isDark(context) ? clayHighlightDark : clayHighlightLight;

  static Color clayBorderColor(BuildContext context) =>
      isDark(context) ? clayBorderDark : clayBorderLight;

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0B5FFF);
  static const Color primaryDark = Color(0xFF003EAA);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color deepBlue = Color(0xFF174A7C);
  static const Color skyAccent = Color(0xFF5EA2FF);
  static const Color white = Colors.white;

  static const Color saffron = Color(0xFFFB923C);
  static const Color saffronLight = Color(0xFFFFB454);
  static const Color saffronDark = Color(0xFFFB923C);
  static const Color darkSaffron = saffronDark;

  // ── Hybrid Ocean Dark Identity ─────────────────────────────────────────────
  static const Color oceanBg = Color(0xFF101B2D);
  static const Color oceanSurface = Color(0xFF16263A);
  static const Color oceanCard = Color(0xFF1B2A41);
  static const Color oceanElevated = Color(0xFF263A59);
  static const Color oceanHighlight = Color(0xFF2A3D59);
  static const Color oceanBorder = Color(0xFF3E5C7E);
  static const Color oceanShadow = Color(0xFF09111C);

  static const Color oceanBlue = Color(0xFF60A5FA);
  static const Color routeBlue = Color(0xFF5EA2FF);
  static const Color shipmentDot = Color(0xFF7CC4FF);
  static const Color oceanCyan = Color(0xFF38BDF8);
  static const Color portOrange = Color(0xFFFB923C);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF2563EB);

  // ── Light Mode Surfaces ────────────────────────────────────────────────────
  static const Color lightBg1 = Color(0xFFFFFFFF);
  static const Color lightBg2 = Color(0xFFF8FBFF);
  static const Color lightBg3 = Color(0xFFF4FAFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFFCFDFF);

  // ── Light Mode Borders / Route Lines ───────────────────────────────────────
  static const Color skyBorder = Color(0xFFD7ECFF);
  static const Color lightBorder = skyBorder;
  static const Color lightBorderSoft = Color(0xFFE7F1FF);
  static const Color routeLine = Color(0xFFB7D9FF);
  static const Color skyEdge = Color(0xFFA9D4FF);

  // Legacy aliases
  static const Color skyBlue = skyBorder;
  static const Color mapBlue = routeLine;
  static const Color softBlue = lightBg3;
  static const Color lightBlue = Color(0xFFEAF6FF);

  // ── Dark Mode Surfaces — Hybrid Premium Ocean ──────────────────────────────
  static const Color darkBg1 = oceanBg;
  static const Color darkBg2 = oceanSurface;
  static const Color darkBg3 = oceanCard;
  static const Color darkSurface = oceanSurface;
  static const Color darkCard = oceanCard;
  static const Color darkElevated = oceanElevated;
  static const Color darkBorder = oceanBorder;
  static const Color darkShadow = oceanShadow;

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textDark = Color(0xFF0F172A);
  static const Color textDarkSecondary = Color(0xFF64748B);
  static const Color textDarkHint = Color(0xFF94A3B8);
  static const Color textGrey = Color(0xFF64748B);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textWhite70 = Color(0xFFC7D7EA);
  static const Color textWhite50 = Color(0xFF90A4B8);
  static const Color darkSubtext = Color(0xFFC7D7EA);
  static const Color darkMuted = Color(0xFF90A4B8);
  static const Color darkAccentBlue = oceanBlue;

  // ── Claymorphism Shadow System ─────────────────────────────────────────────
  static const Color clayShadowLight = Color(0xFFB8C8D8);
  static const Color clayHighlightLight = Color(0xFFFFFFFF);
  static const Color clayBorderLight = skyBorder;

  static const Color clayShadowDark = oceanShadow;
  static const Color clayHighlightDark = oceanHighlight;
  static const Color clayBorderDark = oceanBorder;

  static const Color clayShadow = clayShadowLight;
  static const Color clayHighlight = clayHighlightLight;

  // ── Glass-named backward compatibility ─────────────────────────────────────
  // Kept only because existing screens import these names.
  // Do not use BackdropFilter / blur with these colors.
  static const Color glassDark = oceanCard;
  static const Color glassLight = Color(0xFFFFFFFF);
  static const Color glassBorder = oceanBorder;
  static const Color glassLightBorder = skyBorder;

  // ── Logistics Node Colors ──────────────────────────────────────────────────
  static const Color warehouseNode = Color(0xFF22C55E);
  static const Color airportNode = oceanBlue;
  static const Color portNode = portOrange;
  static const Color routeNode = shipmentDot;

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF0B5FFF),
    Color(0xFF60A5FA),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFB923C),
    Color(0xFFFFB454),
  ];

  static const List<Color> successGradient = [
    Color(0xFF22C55E),
    Color(0xFF16A34A),
  ];

  static const List<Color> heroGradient = [
    Color(0xFF0B5FFF),
    Color(0xFF174A7C),
    Color(0xFF60A5FA),
  ];

  static const List<Color> lightGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8FBFF),
    Color(0xFFF4FAFF),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF101B2D),
    Color(0xFF16263A),
    Color(0xFF1B2A41),
  ];

  static const List<Color> routeGradient = [
    Color(0xFF0B5FFF),
    Color(0xFF5EA2FF),
    Color(0xFFB7D9FF),
  ];

  static const List<Color> oceanGradient = [
    Color(0xFF101B2D),
    Color(0xFF16263A),
    Color(0xFF263A59),
  ];

  static const List<Color> skyGradient = [
    Color(0xFF0B5FFF),
    Color(0xFF60A5FA),
    Color(0xFFEAF6FF),
  ];

  // ── Role colors ────────────────────────────────────────────────────────────
  static const Color customerColor = primary;
  static const Color driverColor = saffron;
  static const Color warehouseColor = success;
  static const Color adminColor = oceanBlue;
  static const Color businessColor = oceanCyan;
  static const Color enterpriseColor = oceanElevated;
  static const Color partnerColor = Color(0xFF059669);

  // ── Logistics mode colors ──────────────────────────────────────────────────
  static const Color roadColor = portOrange;
  static const Color airColor = oceanBlue;
  static const Color oceanColor = oceanCyan;
  static const Color railColor = Color(0xFF818CF8);

  // ── Shipment status colors ─────────────────────────────────────────────────
  static const Color statusBooked = Color(0xFF64748B);
  static const Color statusPickedUp = Color(0xFF60A5FA);
  static const Color statusInTransit = Color(0xFFFB923C);
  static const Color statusCustoms = Color(0xFF818CF8);
  static const Color statusDelivered = Color(0xFF22C55E);
  static const Color statusDelayed = Color(0xFFEF4444);
  static const Color statusReturned = Color(0xFFF59E0B);

  static Color shipmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return statusBooked;
      case 'picked up':
        return statusPickedUp;
      case 'in transit':
        return statusInTransit;
      case 'customs':
      case 'customs check':
      case 'customs clearance':
        return statusCustoms;
      case 'delivered':
        return statusDelivered;
      case 'delayed':
        return statusDelayed;
      case 'returned':
        return statusReturned;
      default:
        return statusBooked;
    }
  }

  // ── Subtle tint only, not neon glow ─────────────────────────────────────────
  static const Color blueGlow = Color(0x2260A5FA);
  static const Color saffronGlow = Color(0x22FB923C);
  static const Color greenGlow = Color(0x2222C55E);
  static const Color purpleGlow = blueGlow;
  static const Color orangeGlow = saffronGlow;

  // ── Backward-compat aliases ────────────────────────────────────────────────
  static const Color accent = saffron;
  static const Color secondary = saffron;
  static const Color lightPurple = lightBlue;
  static const Color primaryDarkLegacy = primaryDark;
}