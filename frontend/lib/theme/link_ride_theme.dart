import 'package:flutter/material.dart';

/// Central design system for the Link Ride mobile application.
///
/// The purpose of this file is to keep the existing Link Ride identity while
/// providing a more modern and consistent visual language across the app.
class LinkRideColors {
  LinkRideColors._();

  // ───────────────── BRAND ─────────────────

  static const Color primaryBlue = Color(0xFF003F73);
  static const Color primaryBlueDark = Color(0xFF002D53);
  static const Color primaryBlueLight = Color(0xFF2C6C98);

  static const Color linkGreen = Color(0xFF4A9B45);
  static const Color linkGreenDark = Color(0xFF347A31);
  static const Color linkGreenLight = Color(0xFF72B76D);

  // ───────────────── SURFACES ─────────────────

  static const Color background = Color(0xFFF5F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF8FAFC);

  static const Color softBlue = Color(0xFFEAF3F8);
  static const Color softBlueStrong = Color(0xFFDDECF5);

  static const Color softGreen = Color(0xFFEDF7EC);
  static const Color softGreenStrong = Color(0xFFDCEEDB);

  // ───────────────── TEXT ─────────────────

  static const Color textPrimary = Color(0xFF10243A);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textMuted = Color(0xFF98A2B3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ───────────────── BORDERS ─────────────────

  static const Color border = Color(0xFFE4EAF0);
  static const Color borderStrong = Color(0xFFD4DEE7);

  // ───────────────── FEEDBACK ─────────────────

  static const Color success = Color(0xFF3F9142);
  static const Color successSoft = Color(0xFFEDF7EC);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFF7E6);

  static const Color danger = Color(0xFFD64545);
  static const Color dangerSoft = Color(0xFFFDECEC);

  static const Color info = Color(0xFF2C6C98);
  static const Color infoSoft = Color(0xFFEAF3F8);
}

/// Shared spacing scale.
///
/// Using the same spacing increments throughout the application helps make
/// screens feel deliberate and visually consistent.
class LinkRideSpacing {
  LinkRideSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

/// Shared corner-radius values.
class LinkRideRadius {
  LinkRideRadius._();

  static const double small = 12;
  static const double medium = 16;
  static const double large = 20;
  static const double extraLarge = 24;
  static const double pill = 999;
}

/// Shared shadows.
///
/// Shadows are intentionally subtle so the application retains a clean,
/// modern Material 3 appearance.
class LinkRideShadows {
  LinkRideShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: LinkRideColors.primaryBlue.withValues(alpha: 0.08),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get floating => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 30,
          offset: const Offset(0, 14),
        ),
      ];
}

/// Reusable gradients for selected high-emphasis surfaces.
class LinkRideGradients {
  LinkRideGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      LinkRideColors.primaryBlue,
      Color(0xFF145C8D),
    ],
  );

  static const LinearGradient primarySoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF4F9FC),
      Color(0xFFEAF3F8),
    ],
  );

  static const LinearGradient successSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF5FBF4),
      Color(0xFFEAF6E9),
    ],
  );
}

/// Shared decoration helpers.
///
/// These are optional convenience methods. Screens can use them directly
/// instead of repeating the same BoxDecoration configuration.
class LinkRideDecorations {
  LinkRideDecorations._();

  static BoxDecoration card({
    Color color = LinkRideColors.surface,
    double radius = LinkRideRadius.large,
    bool showBorder = true,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(
              color: LinkRideColors.border,
            )
          : null,
      boxShadow: showShadow ? LinkRideShadows.soft : null,
    );
  }

  static BoxDecoration softCard({
    Color color = LinkRideColors.surfaceSoft,
    double radius = LinkRideRadius.large,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: LinkRideColors.border,
      ),
    );
  }

  static BoxDecoration blueCard({
    double radius = LinkRideRadius.extraLarge,
  }) {
    return BoxDecoration(
      gradient: LinkRideGradients.primary,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: LinkRideShadows.elevated,
    );
  }

  static BoxDecoration iconContainer({
    Color backgroundColor = LinkRideColors.softBlue,
    double radius = LinkRideRadius.medium,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

/// Global Link Ride Material theme.
class LinkRideTheme {
  LinkRideTheme._();

  static ThemeData get light {
    final ColorScheme colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: LinkRideColors.primaryBlue,
      onPrimary: Colors.white,
      secondary: LinkRideColors.linkGreen,
      onSecondary: Colors.white,
      error: LinkRideColors.danger,
      onError: Colors.white,
      surface: LinkRideColors.surface,
      onSurface: LinkRideColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: LinkRideColors.background,

      canvasColor: LinkRideColors.background,

      dividerColor: LinkRideColors.border,

      splashFactory: InkRipple.splashFactory,

      // ───────────────── TYPOGRAPHY ─────────────────

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
          color: LinkRideColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: LinkRideColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: LinkRideColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          color: LinkRideColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          color: LinkRideColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: LinkRideColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: LinkRideColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: LinkRideColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: LinkRideColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.45,
          color: LinkRideColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: LinkRideColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: LinkRideColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        labelMedium: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),

      // ───────────────── APP BAR ─────────────────

      appBarTheme: const AppBarTheme(
        backgroundColor: LinkRideColors.background,
        foregroundColor: LinkRideColors.primaryBlue,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: LinkRideColors.primaryBlue,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(
          color: LinkRideColors.primaryBlue,
          size: 23,
        ),
      ),

      // ───────────────── INPUTS ─────────────────

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LinkRideColors.surfaceSoft,

        hintStyle: const TextStyle(
          color: LinkRideColors.textMuted,
          fontSize: 14,
        ),

        labelStyle: const TextStyle(
          color: LinkRideColors.textSecondary,
          fontSize: 14,
        ),

        floatingLabelStyle: const TextStyle(
          color: LinkRideColors.primaryBlue,
          fontWeight: FontWeight.w700,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),

        prefixIconColor: LinkRideColors.textSecondary,
        suffixIconColor: LinkRideColors.textSecondary,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            LinkRideRadius.medium,
          ),
          borderSide: const BorderSide(
            color: LinkRideColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            LinkRideRadius.medium,
          ),
          borderSide: const BorderSide(
            color: LinkRideColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            LinkRideRadius.medium,
          ),
          borderSide: const BorderSide(
            color: LinkRideColors.primaryBlue,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            LinkRideRadius.medium,
          ),
          borderSide: const BorderSide(
            color: LinkRideColors.danger,
            width: 1.2,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            LinkRideRadius.medium,
          ),
          borderSide: const BorderSide(
            color: LinkRideColors.danger,
            width: 1.5,
          ),
        ),

        errorStyle: const TextStyle(
          color: LinkRideColors.danger,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ───────────────── FILLED BUTTON ─────────────────

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: LinkRideColors.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              LinkRideColors.primaryBlue.withValues(alpha: 0.35),
          disabledForegroundColor:
              Colors.white.withValues(alpha: 0.85),
          minimumSize: const Size(
            0,
            54,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              LinkRideRadius.medium,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
          elevation: 0,
        ),
      ),

      // ───────────────── ELEVATED BUTTON ─────────────────

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LinkRideColors.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              LinkRideColors.primaryBlue.withValues(alpha: 0.35),
          disabledForegroundColor:
              Colors.white.withValues(alpha: 0.85),
          minimumSize: const Size(
            0,
            54,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              LinkRideRadius.medium,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ───────────────── OUTLINED BUTTON ─────────────────

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LinkRideColors.primaryBlue,
          minimumSize: const Size(
            0,
            52,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          side: const BorderSide(
            color: LinkRideColors.borderStrong,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              LinkRideRadius.medium,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ───────────────── TEXT BUTTON ─────────────────

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LinkRideColors.primaryBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ───────────────── CARDS ─────────────────

      cardTheme: CardThemeData(
        color: LinkRideColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            LinkRideRadius.large,
          ),
          side: const BorderSide(
            color: LinkRideColors.border,
          ),
        ),
      ),

      // ───────────────── NAVIGATION BAR ─────────────────

      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: LinkRideColors.surface,
        elevation: 0,
        indicatorColor: LinkRideColors.softBlue,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
            final bool selected =
                states.contains(WidgetState.selected);

            return TextStyle(
              fontSize: 11.5,
              fontWeight:
                  selected ? FontWeight.w800 : FontWeight.w600,
              color: selected
                  ? LinkRideColors.primaryBlue
                  : LinkRideColors.textSecondary,
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) {
            final bool selected =
                states.contains(WidgetState.selected);

            return IconThemeData(
              size: 23,
              color: selected
                  ? LinkRideColors.primaryBlue
                  : LinkRideColors.textSecondary,
            );
          },
        ),
      ),

      // ───────────────── CHIPS ─────────────────

      chipTheme: ChipThemeData(
        backgroundColor: LinkRideColors.surfaceSoft,
        selectedColor: LinkRideColors.softBlue,
        disabledColor: LinkRideColors.surfaceSoft,
        side: const BorderSide(
          color: LinkRideColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            LinkRideRadius.pill,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        labelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: LinkRideColors.textPrimary,
        ),
      ),

      // ───────────────── DIALOGS ─────────────────

      dialogTheme: DialogThemeData(
        backgroundColor: LinkRideColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            LinkRideRadius.extraLarge,
          ),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: LinkRideColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          height: 1.45,
          color: LinkRideColors.textSecondary,
        ),
      ),

      // ───────────────── SNACKBARS ─────────────────

      snackBarTheme: SnackBarThemeData(
        backgroundColor: LinkRideColors.textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            LinkRideRadius.medium,
          ),
        ),
        insetPadding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          18,
        ),
      ),

      // ───────────────── PROGRESS ─────────────────

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: LinkRideColors.primaryBlue,
        linearTrackColor: LinkRideColors.softBlue,
      ),

      // ───────────────── SWITCHES ─────────────────

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }

            return LinkRideColors.textMuted;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return LinkRideColors.linkGreen;
            }

            return LinkRideColors.borderStrong;
          },
        ),
        trackOutlineColor:
            const WidgetStatePropertyAll<Color>(
          Colors.transparent,
        ),
      ),

      // ───────────────── CHECKBOXES ─────────────────

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return LinkRideColors.primaryBlue;
            }

            return null;
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: const BorderSide(
          color: LinkRideColors.borderStrong,
          width: 1.3,
        ),
      ),

      // ───────────────── RADIO ─────────────────

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return LinkRideColors.primaryBlue;
            }

            return LinkRideColors.textSecondary;
          },
        ),
      ),

      // ───────────────── DIVIDERS ─────────────────

      dividerTheme: const DividerThemeData(
        color: LinkRideColors.border,
        thickness: 1,
        space: 1,
      ),

      // ───────────────── ICONS ─────────────────

      iconTheme: const IconThemeData(
        color: LinkRideColors.primaryBlue,
        size: 22,
      ),
    );
  }
}