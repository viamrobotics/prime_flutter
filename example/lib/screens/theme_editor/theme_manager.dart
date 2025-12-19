import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  static const String _storageKey = 'prime_theme_data';
  static const String _currentThemeKey = 'prime_current_theme_name';

  // Map of Theme Name -> Theme Data
  final Map<String, PrimeColorScheme> _savedThemes = {'Light': PrimeColorScheme.light(), 'Dark': PrimeColorScheme.dark()};
  static const Set<String> _protectedThemes = {'Light', 'Dark'};

  String _currentThemeName = 'Light';
  PrimeColorScheme _currentScheme = PrimeColorScheme.light();

  PrimeColorScheme get currentScheme => _currentScheme;
  String get currentThemeName => _currentThemeName;
  List<String> get availableThemes => _savedThemes.keys.toList();
  bool isProtected(String name) => _protectedThemes.contains(name);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved themes
    final savedData = prefs.getString(_storageKey);
    if (savedData != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(savedData);
        decoded.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            _savedThemes[key] = _deserializeScheme(value);
          }
        });
      } catch (e) {
        debugPrint('Error loading themes: $e');
      }
    }

    // Load current choice
    final currentName = prefs.getString(_currentThemeKey);
    if (currentName != null && _savedThemes.containsKey(currentName)) {
      _currentThemeName = currentName;
      _currentScheme = _savedThemes[currentName]!;
    }

    notifyListeners();
  }

  void switchTheme(String name) {
    if (_savedThemes.containsKey(name)) {
      _currentThemeName = name;
      _currentScheme = _savedThemes[name]!;
      _saveCurrentSelection();
      notifyListeners();
    }
  }

  void updateColor(String propertyName, Color color) {
    _currentScheme = _copyWith(_currentScheme, propertyName, color);
    _savedThemes[_currentThemeName] = _currentScheme;
    notifyListeners();
  }

  Future<void> saveTheme(String newName) async {
    if (isProtected(newName)) {
      throw Exception('Cannot overwrite protected theme: $newName');
    }
    _savedThemes[newName] = _currentScheme;
    _currentThemeName = newName;
    await _persistAll();
    await _saveCurrentSelection();
    notifyListeners();
  }

  Future<void> deleteTheme(String name) async {
    if (isProtected(name)) {
      throw Exception('Cannot delete protected theme: $name');
    }
    if (!_savedThemes.containsKey(name)) return;

    _savedThemes.remove(name);

    // If we deleted the current theme, switch to a safe default
    if (_currentThemeName == name) {
      _currentThemeName = 'Light';
      _currentScheme = _savedThemes['Light']!;
      await _saveCurrentSelection();
    }

    await _persistAll();
    notifyListeners();
  }

  Future<void> _persistAll() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> encoded = {};
    _savedThemes.forEach((key, value) {
      encoded[key] = _serializeScheme(value);
    });
    await prefs.setString(_storageKey, jsonEncode(encoded));
  }

  Future<void> _saveCurrentSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentThemeKey, _currentThemeName);
  }

  // --- Serialization Helpers ---

  Map<String, dynamic> _serializeScheme(PrimeColorScheme s) {
    return {
      'surfaceBase': s.surfaceBase.toARGB32(),
      'surfaceOffset': s.surfaceOffset.toARGB32(),
      'surfaceHighlight': s.surfaceHighlight.toARGB32(),
      'textPrimary': s.textPrimary.toARGB32(),
      'textSecondary': s.textSecondary.toARGB32(),
      'textTertiary': s.textTertiary.toARGB32(),
      'textPlaceholder': s.textPlaceholder.toARGB32(),
      'iconPrimary': s.iconPrimary.toARGB32(),
      'iconSecondary': s.iconSecondary.toARGB32(),
      'iconDisabled': s.iconDisabled.toARGB32(),
      'actionPrimaryBg': s.actionPrimaryBg.toARGB32(),
      'actionPrimaryFg': s.actionPrimaryFg.toARGB32(),
      'actionNeutralBg': s.actionNeutralBg.toARGB32(),
      'borderSubtle': s.borderSubtle.toARGB32(),
      'inputText': s.inputText.toARGB32(),
      'inputFocus': s.inputFocus.toARGB32(),
      'statusDangerLight': s.statusDangerLight.toARGB32(),
      'statusDangerDark': s.statusDangerDark.toARGB32(),
      'statusInfoLight': s.statusInfoLight.toARGB32(),
      'statusInfoDark': s.statusInfoDark.toARGB32(),
      'statusSuccessLight': s.statusSuccessLight.toARGB32(),
      'statusSuccessDark': s.statusSuccessDark.toARGB32(),
      'statusWarningLight': s.statusWarningLight.toARGB32(),
      'statusWarningDark': s.statusWarningDark.toARGB32(),
    };
  }

  PrimeColorScheme _deserializeScheme(Map<String, dynamic> map) {
    Color c(String key, Color fallback) {
      if (map.containsKey(key)) {
        return Color(map[key] as int);
      }
      return fallback;
    }

    final defaults = PrimeColorScheme.light();

    return PrimeColorScheme(
      surfaceBase: c('surfaceBase', defaults.surfaceBase),
      surfaceOffset: c('surfaceOffset', defaults.surfaceOffset),
      surfaceHighlight: c('surfaceHighlight', defaults.surfaceHighlight),
      textPrimary: c('textPrimary', defaults.textPrimary),
      textSecondary: c('textSecondary', defaults.textSecondary),
      textTertiary: c('textTertiary', defaults.textTertiary),
      textPlaceholder: c('textPlaceholder', defaults.textPlaceholder),
      iconPrimary: c('iconPrimary', defaults.iconPrimary),
      iconSecondary: c('iconSecondary', defaults.iconSecondary),
      iconDisabled: c('iconDisabled', defaults.iconDisabled),
      actionPrimaryBg: c('actionPrimaryBg', defaults.actionPrimaryBg),
      actionPrimaryFg: c('actionPrimaryFg', defaults.actionPrimaryFg),
      actionNeutralBg: c('actionNeutralBg', defaults.actionNeutralBg),
      borderSubtle: c('borderSubtle', defaults.borderSubtle),
      inputText: c('inputText', defaults.inputText),
      inputFocus: c('inputFocus', defaults.inputFocus),
      statusDangerLight: c('statusDangerLight', defaults.statusDangerLight),
      statusDangerDark: c('statusDangerDark', defaults.statusDangerDark),
      statusInfoLight: c('statusInfoLight', defaults.statusInfoLight),
      statusInfoDark: c('statusInfoDark', defaults.statusInfoDark),
      statusSuccessLight: c('statusSuccessLight', defaults.statusSuccessLight),
      statusSuccessDark: c('statusSuccessDark', defaults.statusSuccessDark),
      statusWarningLight: c('statusWarningLight', defaults.statusWarningLight),
      statusWarningDark: c('statusWarningDark', defaults.statusWarningDark),
    );
  }

  PrimeColorScheme _copyWith(PrimeColorScheme s, String name, Color color) {
    final map = _serializeScheme(s);
    map[name] = color.toARGB32();
    return _deserializeScheme(map);
  }
}
