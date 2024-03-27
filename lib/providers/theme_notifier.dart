import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/app_settings/theme.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:jetpack/services/shared_data.dart';

class ThemeNotifier with ChangeNotifier {
  Color bgColor = lightBgColor;
  TextStyle text18 = textBlack;
  TextStyle title = titleblack;
  AppThemeModel appTheme = AppThemeModel.system;
  bool isDark = false;
  Color invertedColor = darkBgColor;
  Color navBarColor = lightnavBarColor;
  Color panelColor = lightPanelColor;
  Color primaryColor = pink;
  Color secondaryColor = red;

  void changeDarkMode(AppThemeModel value) async {
    isDark = value == AppThemeModel.system
        ? getSystemTheme()
        : value == AppThemeModel.dark;
    switch (isDark) {
      case true:
        bgColor = darkBgColor;
        panelColor = darkPanelColor;
        text18 = textWhite;
        title = titleWhite;
        invertedColor = lightBgColor;
        navBarColor = darknavBarColor;
        primaryColor = pink;
        secondaryColor = red;
        break;
      case false:
        bgColor = lightBgColor;
        panelColor = lightPanelColor;
        text18 = textBlack;
        title = titleblack;
        invertedColor = darkBgColor;
        navBarColor = lightnavBarColor;
        primaryColor = pink;
        secondaryColor = red;
        break;
      default:
        break;
    }
    appTheme = value;
    notifyListeners();
    DataPrefrences.setDarkMode(value);
    // log("app theme :${DataPrefrences.getDarkMode()}");
  }

  initTheme() {
    appTheme = getAppThemeFromString(DataPrefrences.getDarkMode());
    // log(appTheme.toString());
    isDark = appTheme == AppThemeModel.system
        ? getSystemTheme()
        : appTheme == AppThemeModel.dark;
    switch (isDark) {
      case true:
        bgColor = darkBgColor;
        panelColor = darkPanelColor;
        text18 = textWhite;
        title = titleWhite;
        invertedColor = lightBgColor;
        navBarColor = darknavBarColor;
        primaryColor = pink;
        secondaryColor = red;

        break;
      case false:
        bgColor = lightBgColor;
        panelColor = lightPanelColor;
        text18 = textBlack;
        title = titleblack;
        invertedColor = darkBgColor;
        navBarColor = lightnavBarColor;
        primaryColor = pink;
        secondaryColor = red;

        break;
      default:
        break;
    }
    startThemeListen();
  }

  startThemeListen() {
    // log(appTheme.toString());
    if (appTheme != AppThemeModel.system) return;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      // log(systemThemeChanged().toString());
      if (appTheme != AppThemeModel.system) timer.cancel();

      if (systemThemeChanged()) {
        isDark = !isDark;
        switch (isDark) {
          case true:
            bgColor = darkBgColor;
            panelColor = darkPanelColor;
            text18 = textWhite;
            title = titleWhite;
            invertedColor = lightBgColor;
            navBarColor = darknavBarColor;
            primaryColor = pink;
            secondaryColor = red;
            break;
          case false:
            bgColor = lightBgColor;
            panelColor = lightPanelColor;
            text18 = textBlack;
            title = titleblack;
            invertedColor = darkBgColor;
            navBarColor = lightnavBarColor;
            primaryColor = pink;
            secondaryColor = red;
            break;
          default:
            break;
        }
        log('Dark mode changed');
        notifyListeners();
      }
    });
  }

  bool systemThemeChanged() {
    if (MediaQuery.of(NavigationService.navigatorKey.currentContext!)
                    .platformBrightness ==
                Brightness.dark &&
            !isDark ||
        MediaQuery.of(NavigationService.navigatorKey.currentContext!)
                    .platformBrightness ==
                Brightness.light &&
            isDark) {
      return true;
    } else {
      return false;
    }
  }
}
