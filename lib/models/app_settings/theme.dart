import 'package:flutter/material.dart';
import 'package:jetpack/services/util/navigation_service.dart';

enum AppThemeModel { system, dark, light }

bool getSystemTheme() {
  final brightness =
      MediaQuery.of(NavigationService.navigatorKey.currentContext!)
          .platformBrightness;
  return brightness == Brightness.dark;
}

getAppThemeFromString(String value) =>
    {'light': AppThemeModel.light, 'dark': AppThemeModel.dark}[value] ??
    AppThemeModel.system;

String getThemeTitle(AppThemeModel theme) =>
    {
      'dark': "Dark mode",
      'light': "Light mode",
      'system': "Use system settings",
    }[theme.name] ??
    '';
