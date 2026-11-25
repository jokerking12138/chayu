import 'package:flutter/material.dart';

/// 茶愉 · 视觉基底：米纸、墨色、岩苔绿与焙火金。
abstract final class TeaPalette {
  static const cream = Color(0xFFF6F1E7);
  static const creamDeep = Color(0xFFEDE4D3);
  static const paper = Color(0xFFFCFAF4);
  static const ink = Color(0xFF26251F);
  static const inkSoft = Color(0xFF6C6859);
  static const inkMuted = Color(0xFF9C9686);
  static const moss = Color(0xFF41594A);
  static const mossDeep = Color(0xFF2A3C31);
  static const gold = Color(0xFFBE9C5F);
  static const line = Color(0xFFE3DAC9);
  static const clay = Color(0xFFA5563C);
}

const List<String> kSerif = <String>[
  'Songti SC',
  'STSong',
  'Noto Serif CJK SC',
  'Source Han Serif SC',
  'Noto Serif',
  'serif',
];

const TextStyle kEyebrow = TextStyle(
  fontSize: 10.5,
  height: 1.4,
  letterSpacing: 2.6,
  fontWeight: FontWeight.w600,
  color: TeaPalette.inkMuted,
);

ThemeData buildTeaTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: TeaPalette.moss,
    brightness: Brightness.light,
  );
  final scheme = base.copyWith(
    primary: TeaPalette.mossDeep,
    onPrimary: TeaPalette.paper,
    primaryContainer: const Color(0xFFDDE5DA),
    onPrimaryContainer: TeaPalette.mossDeep,
    secondary: TeaPalette.gold,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFF1E7D3),
    onSecondaryContainer: const Color(0xFF6B5527),
    tertiary: TeaPalette.clay,
    surface: TeaPalette.cream,
    onSurface: TeaPalette.ink,
    onSurfaceVariant: TeaPalette.inkSoft,
    surfaceContainerLowest: TeaPalette.paper,
    surfaceContainerLow: const Color(0xFFFAF6EC),
    surfaceContainer: TeaPalette.cream,
    surfaceContainerHigh: TeaPalette.creamDeep,
    surfaceContainerHighest: const Color(0xFFE6DCC8),
    outline: const Color(0xFFBDB4A2),
    outlineVariant: TeaPalette.line,
    error: TeaPalette.clay,
  );

  final textTheme = ThemeData.light().textTheme.apply(
        bodyColor: TeaPalette.ink,
        displayColor: TeaPalette.ink,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: TeaPalette.cream,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: TeaPalette.ink,
    ),
    cardTheme: CardThemeData(
      color: TeaPalette.paper,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: TeaPalette.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: TeaPalette.mossDeep,
        foregroundColor: TeaPalette.paper,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        textStyle: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: TeaPalette.mossDeep,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: TeaPalette.line),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: TeaPalette.mossDeep,
        minimumSize: const Size(0, 44),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        shape: const StadiumBorder(),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: TeaPalette.inkSoft,
        minimumSize: const Size(44, 44),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: TeaPalette.paper,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 70,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorColor: TeaPalette.moss.withValues(alpha: 0.12),
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 10.5,
          letterSpacing: 1.4,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? TeaPalette.mossDeep : TeaPalette.inkMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 21,
          color: selected ? TeaPalette.mossDeep : TeaPalette.inkMuted,
        );
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: TeaPalette.line,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: TeaPalette.mossDeep,
      contentTextStyle: const TextStyle(color: TeaPalette.paper, fontSize: 13.5),
      behavior: SnackBarBehavior.floating,
      insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: TeaPalette.moss,
      linearTrackColor: TeaPalette.creamDeep,
    ),
  );
}
