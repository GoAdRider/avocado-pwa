import 'package:flutter/material.dart';

/// 아보카도 PWA 브랜드 컬러 팔레트
/// 세련된 그린 계열과 보완 색상으로 구성
class AppColors {
  AppColors._();

  // ===== Primary Colors (아보카도 그린 베이스) =====
  
  /// 메인 브랜드 컬러 - 아보카도 그린
  static const Color primary = Color(0xFF6B8E23);
  static const Color primaryLight = Color(0xFF8BA445);
  static const Color primaryDark = Color(0xFF556B1C);
  static const Color primaryExtraLight = Color(0xFFB8D162);
  
  // ===== Secondary Colors (보완 색상) =====
  
  /// 세컨더리 컬러 - 따뜻한 오렌지
  static const Color secondary = Color(0xFFE67E22);
  static const Color secondaryLight = Color(0xFFEB8B3A);
  static const Color secondaryDark = Color(0xFFD35400);
  
  // ===== Accent Colors (강조 색상) =====
  
  /// 블루 계열 (정보, 내보내기)
  static const Color accent = Color(0xFF3498DB);
  static const Color accentLight = Color(0xFF5DADE2);
  static const Color accentDark = Color(0xFF2980B9);
  
  /// 퍼플 계열 (즐겨찾기)
  static const Color purple = Color(0xFF9B59B6);
  static const Color purpleLight = Color(0xFFAB6FC7);
  static const Color purpleDark = Color(0xFF8E44AD);
  
  // ===== Status Colors (상태 색상) =====
  
  /// 성공 - 그린
  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFF58D68D);
  static const Color successDark = Color(0xFF229954);
  
  /// 경고 - 오렌지  
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFF7DC6F);
  static const Color warningDark = Color(0xFFE67E22);
  
  /// 에러 - 레드
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFEC7063);
  static const Color errorDark = Color(0xFFC0392B);
  
  /// 정보 - 블루
  static const Color info = Color(0xFF5DADE2);
  static const Color infoLight = Color(0xFF85C1E9);
  static const Color infoDark = Color(0xFF3498DB);
  
  // ===== Neutral Colors (중성 색상) =====
  
  /// 텍스트 색상
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF566573);
  static const Color textTertiary = Color(0xFF7B7D7D);
  static const Color textDisabled = Color(0xFFBDC3C7);
  
  /// 배경 색상
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color backgroundOverlay = Color(0xF0FFFFFF);
  
  /// 구분선 색상
  static const Color divider = Color(0xFFECF0F1);
  static const Color border = Color(0xFFD5DBDB);
  static const Color borderLight = Color(0xFFEAF2F8);
  
  // ===== Gradient Colors (그라데이션) =====
  
  /// 메인 그라데이션 (아보카도 그린)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// 세컨더리 그라데이션 (따뜻한 오렌지)
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary, secondaryDark],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// 액센트 그라데이션 (블루)
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent, accentDark],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// 카드 선택 그라데이션
  static const LinearGradient cardSelectedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x1A6B8E23), // primary with 10% opacity
      Color(0x0D6B8E23), // primary with 5% opacity
    ],
  );
  
  /// 글래스모피즘 그라데이션
  static const LinearGradient glassmorphismGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF), // white with 10% opacity
      Color(0x0DFFFFFF), // white with 5% opacity
    ],
  );
  
  // ===== Shadow Colors (그림자 색상) =====
  
  /// 카드 그림자
  static const Color shadowLight = Color(0x0F000000); // 6% opacity
  static const Color shadowMedium = Color(0x1A000000); // 10% opacity
  static const Color shadowDark = Color(0x29000000); // 16% opacity
  
  /// 선택된 카드 글로우 효과
  static const Color glowPrimary = Color(0x336B8E23); // primary with 20% opacity
  static const Color glowAccent = Color(0x333498DB); // accent with 20% opacity
  
  // ===== Alpha 변형 색상 =====
  
  /// Primary 색상의 투명도 변형
  static Color primaryAlpha(double opacity) => primary.withValues(alpha: opacity);
  static Color primaryLightAlpha(double opacity) => primaryLight.withValues(alpha: opacity);
  static Color primaryDarkAlpha(double opacity) => primaryDark.withValues(alpha: opacity);
  
  /// Secondary 색상의 투명도 변형
  static Color secondaryAlpha(double opacity) => secondary.withValues(alpha: opacity);
  static Color secondaryLightAlpha(double opacity) => secondaryLight.withValues(alpha: opacity);
  
  /// Accent 색상의 투명도 변형
  static Color accentAlpha(double opacity) => accent.withValues(alpha: opacity);
  static Color purpleAlpha(double opacity) => purple.withValues(alpha: opacity);
  
  // ===== 특수 효과 색상 =====
  
  /// 리플 효과 색상
  static Color get ripplePrimary => primaryAlpha(0.12);
  static Color get rippleSecondary => secondaryAlpha(0.12);
  static Color get rippleAccent => accentAlpha(0.12);
  
  /// 호버 효과 색상
  static Color get hoverPrimary => primaryAlpha(0.08);
  static Color get hoverSecondary => secondaryAlpha(0.08);
  static Color get hoverAccent => accentAlpha(0.08);
  
  /// 포커스 효과 색상
  static Color get focusPrimary => primaryAlpha(0.24);
  static Color get focusSecondary => secondaryAlpha(0.24);
  static Color get focusAccent => accentAlpha(0.24);
}

/// 버튼 스타일을 위한 색상 세트
class ButtonColors {
  ButtonColors._();
  
  /// Primary 버튼 색상
  static const MaterialColor primary = MaterialColor(
    0xFF6B8E23,
    <int, Color>{
      50: Color(0xFFF4F7ED),
      100: Color(0xFFE6EDD1), 
      200: Color(0xFFCDDBA3),
      300: Color(0xFFB4C975),
      400: Color(0xFF9BB747),
      500: Color(0xFF6B8E23), // 메인 컬러
      600: Color(0xFF5E7D1F),
      700: Color(0xFF516C1B),
      800: Color(0xFF445B17),
      900: Color(0xFF374A13),
    },
  );
  
  /// Secondary 버튼 색상
  static const MaterialColor secondary = MaterialColor(
    0xFFE67E22,
    <int, Color>{
      50: Color(0xFFFDF4E7),
      100: Color(0xFFFAE5C3),
      200: Color(0xFFF6D69F),
      300: Color(0xFFF1C77B),
      400: Color(0xFFEDB857),
      500: Color(0xFFE67E22), // 메인 컬러
      600: Color(0xFFCF711F),
      700: Color(0xFFB8641C),
      800: Color(0xFFA15719),
      900: Color(0xFF8A4A16),
    },
  );
}

/// 그림자 스타일 정의
class AppShadows {
  AppShadows._();
  
  /// 기본 카드 그림자
  static const List<BoxShadow> card = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
      color: AppColors.shadowLight,
    ),
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
      color: AppColors.shadowMedium,
    ),
  ];
  
  /// 선택된 카드 그림자
  static const List<BoxShadow> cardSelected = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
      color: AppColors.shadowMedium,
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
      color: AppColors.glowPrimary,
    ),
  ];
  
  /// 버튼 그림자
  static const List<BoxShadow> button = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
      color: AppColors.shadowLight,
    ),
  ];
  
  /// 부드러운 그림자
  static const List<BoxShadow> soft = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
      color: AppColors.shadowLight,
    ),
  ];
}