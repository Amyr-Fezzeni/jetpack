import 'package:jetpack/models/app_settings/theme.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataPrefrences {
  static late SharedPreferences _preferences;
  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future<void> setLogin(String value) async =>
      await _preferences.setString("login", value);

  static String getLogin() => _preferences.getString('login') ?? "";

  static Future<void> setPassword(String value) async =>
      await _preferences.setString("password", value);

  static String getPassword() => _preferences.getString('password') ?? "";

  static Future<void> setDarkMode(AppThemeModel value) async =>
      await _preferences.setString("darkMode", value.name);

  static String getDarkMode() => _preferences.getString('darkMode') ?? "dark";

  static Future<void> setNotification(bool value) async =>
      await _preferences.setBool("notification", value);

  static bool getNotification() => _preferences.getBool('notification') ?? true;

  static Future<void> setDefaultLanguage(String code) async =>
      await _preferences.setString("language", code);

  static LanguageModel getDefaultLanguage() =>
      {
        'english': LanguageModel.english,
        'french': LanguageModel.french
      }[_preferences.getString('language') ?? "french"] ??
      LanguageModel.french;

  static Future<void> setPrivecy(bool value) async =>
      await _preferences.setBool("privecy", value);

  static bool getPrivecy() => _preferences.getBool('privecy') ?? false;

  static Future<void> setTerms(bool value) async =>
      await _preferences.setBool("terms", value);

  static bool getTerms() => _preferences.getBool('terms') ?? false;
}
