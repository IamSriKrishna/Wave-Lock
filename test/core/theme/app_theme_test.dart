import 'package:flutter_test/flutter_test.dart';
import 'package:wakelock/core/theme/app_colors.dart';
import 'package:wakelock/core/theme/app_theme.dart';

void main() {
  test('selected palette updates shared app colors and Material theme', () {
    final previousPalette = AppColors.palette;
    addTearDown(() => AppColors.palette = previousPalette);

    AppColors.palette = AppColorPalette.ocean;

    expect(AppColors.primary, AppColorPalette.ocean.primary);
    expect(AppColors.background, AppColorPalette.ocean.background);
    expect(
      AppTheme.darkTheme.colorScheme.primary,
      AppColorPalette.ocean.primary,
    );
    expect(
      AppTheme.darkTheme.scaffoldBackgroundColor,
      AppColorPalette.ocean.background,
    );
  });

  test('unknown saved palette falls back to the default palette', () {
    expect(AppColorPalette.fromId('not-a-palette'), AppColorPalette.ember);
  });
}
