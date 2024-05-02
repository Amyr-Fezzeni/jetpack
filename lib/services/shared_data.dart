import 'dart:developer';

import 'package:jetpack/models/app_settings/theme.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
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
  static Future<void> saveAccount(
      {required String email,
      required String password,
      required String accountName}) async {
    log("$accountName: ${getAccount(accountName: accountName)}");
    await addAccount(accountName: accountName);
    await _preferences.setStringList(accountName, [email, password]);
    log("$accountName: ${getAccount(accountName: accountName)}");
  }

  static List<String>? getAccount({required String accountName}) {
    return _preferences.getStringList(accountName);
  }

  static Future<void> removeAccount({required String accountName}) async {
    List<String> accounts = getAccounts();
    if (!accounts.contains(accountName)) return;
    accounts.remove(accountName);
    await _preferences.setStringList("accounts", accounts);
    await _preferences.setStringList(accountName, []);
  }

  static Future<void> addAccount({required String accountName}) async {
    List<String> accounts = getAccounts();
    if (accounts.contains(accountName)) return;
    log(accounts.toString());
    accounts.add(accountName);
    log(accounts.toString());
    await _preferences.setStringList("accounts", accounts);
  }

  static List<String> getAccounts() {
    return _preferences.getStringList('accounts') ?? [];
  }
}
