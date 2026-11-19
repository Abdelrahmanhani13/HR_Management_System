/// Single source of truth for processed brand assets.
///
/// Illustration pixel sizes are recorded here so the intrinsic aspect ratio is
/// known synchronously (no layout jump, no stretching, no fixed square boxes).
/// The originals in `assets/illustrations` etc. are kept untouched.
class AppAssets {
  AppAssets._();

  static const String _il = 'assets/processed/illustrations';
  static const String _bg = 'assets/processed/backgrounds';
  static const String _logo = 'assets/processed/logo';

  static const String logo = '$_logo/pioneers_logo.png'; // 2143 x 674
  static const double logoAspect = 2143 / 674;
  static const String emblem = '$_logo/pioneers_emblem.png'; // 648 x 640
  static const double emblemAspect = 648 / 640;

  static const String heroDarkWaves = '$_bg/hero_dark_waves.png'; // 728 x 488
  static const String headerLightArcs = '$_bg/header_light_arcs.png'; // 724 x 500
  static const String sectionDotsArc = '$_bg/section_dots_arc.png'; // 664 x 488
  static const String sectionDiagonalBars =
      '$_bg/section_diagonal_bars.png'; // 652 x 488
  static const String loginBrandScene = '$_bg/login_brand_scene.png'; // 1107 x 771
  static const double loginBrandSceneAspect = 1107 / 771;
}

/// Illustrations that already carry their own embedded message.
enum AppIllustration {
  emptyEmployees('assets/processed/illustrations/empty_employees.png', 903, 648),
  emptyAttendance(
    'assets/processed/illustrations/empty_attendance.png',
    1002,
    786,
  ),
  emptySearch('assets/processed/illustrations/empty_search.png', 726, 678),
  error('assets/processed/illustrations/error_generic.png', 759, 543),
  success('assets/processed/illustrations/success_generic.png', 651, 543),
  successAttendance(
    'assets/processed/illustrations/success_attendance.png',
    864,
    642,
  );

  const AppIllustration(this.path, this.pixelWidth, this.pixelHeight);

  final String path;
  final int pixelWidth;
  final int pixelHeight;

  double get aspectRatio => pixelWidth / pixelHeight;

  /// `success_attendance` has no embedded text, unlike the other five.
  bool get hasEmbeddedMessage => this != AppIllustration.successAttendance;
}
