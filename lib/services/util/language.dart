// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:provider/provider.dart';
import '../../constants/languages.dart';
import '../../providers/user_provider.dart';
import 'navigation_service.dart';

enum LanguageModel { french, english, arabe }

String txt(String key) {
  // log(DataPrefrences.getAccountType());

  LanguageModel language = NavigationService.navigatorKey.currentContext!
      .read<UserProvider>()
      .currentLanguage;
  addKey(key);
  return language == LanguageModel.english
      ? english[key] ?? key
      : frensh[key] ?? key;
}

void addKey(String key) {
  File file = File(
      '/Users/letaff/flutter projects/jetpack/lib/constants/language.json');
  Map<String, dynamic> data =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  if (!data.containsKey(key)) {
    data.addAll({key: key});
    file.writeAsStringSync(jsonEncode(data));
    log('$key saved');
  }
}

Widget Txt(String text,
    {Color? color,
    double? size,
    bool center = false,
    TextStyle? style,
    String extra = '',
    int? maxLines,
    bool translate = true,
    bool bold = false}) {
  return Text(
    (translate ? txt(text) : text) + extra,
    style: style ??
        NavigationService.navigatorKey.currentContext!.text.copyWith(
            color: color,
            fontSize: size,
            fontWeight: bold ? FontWeight.bold : null),
    maxLines: maxLines,
    overflow: maxLines != null ? TextOverflow.ellipsis : null,
    textAlign: center ? TextAlign.center : null,
  );
}
