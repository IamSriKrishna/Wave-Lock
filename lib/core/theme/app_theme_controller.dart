import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';

import '../database/app_database.dart';
import '../database/database_stores.dart';
import 'app_colors.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController(this._appDatabase);

  static const _settingsKey = 'app_color_palette';

  final AppDatabase _appDatabase;
  AppColorPalette _palette = AppColorPalette.ember;

  AppColorPalette get palette => _palette;

  Future<void> load() async {
    final database = await _appDatabase.database;
    final record = await DatabaseStores.settings
        .record(_settingsKey)
        .get(database);
    final paletteId = record?['value'];
    if (paletteId is! String) return;

    _palette = AppColorPalette.fromId(paletteId);
    AppColors.palette = _palette;
    notifyListeners();
  }

  Future<void> selectPalette(AppColorPalette palette) async {
    final previousPalette = _palette;
    _palette = palette;
    AppColors.palette = palette;
    notifyListeners();

    try {
      final database = await _appDatabase.database;
      await DatabaseStores.settings.record(_settingsKey).put(database, {
        'value': palette.id,
      });
    } catch (_) {
      if (_palette == palette) {
        _palette = previousPalette;
        AppColors.palette = previousPalette;
        notifyListeners();
      }
      rethrow;
    }
  }
}
