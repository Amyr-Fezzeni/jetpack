import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crossplat_objectid/crossplat_objectid.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'language.dart';

String generateId() {
  ObjectId id1 = ObjectId();
  return id1.toHexString();
}

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

String generateBarCodeId() {
  final random = math.Random();
  final buffer = StringBuffer();

  for (int i = 0; i < 12; i++) {
    buffer.write(random.nextInt(10));
  }

  return buffer.toString();
}

String generateMD5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

String capitalize(String text) {
  return text.isEmpty
      ? text
      : "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
}

double min(List<double> lst) {
  if (lst.isEmpty) return 0;
  return lst.reduce((value, element) => value < element ? value : element);
}

double max(List<double> lst) {
  if (lst.isEmpty) return 0;
  return lst.reduce((value, element) => value > element ? value : element);
}

String getDate(DateTime? date, {bool day = true}) {
  return date == null
      ? ""
      : "${day ? "${date.day > 9 ? '' : '0'}${date.day}-" : ''}${date.month > 9 ? '' : '0'}${date.month}-${date.year}";
}

DateTime stringToDate(String date) {
  int year = int.parse(date.split('-').last);
  int month = int.parse(date.split('-')[1]);
  int day = int.parse(date.split('-').first);
  return DateTime(year, month, day);
}
DateTime stringToDateReversed(String date) {
  int year = int.parse(date.split('-').first);
  int month = int.parse(date.split('-')[1]);
  int day = int.parse(date.split('-').last);
  return DateTime(year, month, day);
}

String getSimpleDate(DateTime? date, {bool day = true}) {
  return date == null
      ? ""
      : "${day ? "${date.day > 9 ? '' : '0'}${date.day} " : ''}${getMonth(date.month)}";
}

String getTime(DateTime? date) {
  return date == null
      ? ""
      : "${date.hour > 9 ? '' : '0'}${date.hour}: ${date.minute > 9 ? '' : '0'}${date.minute}";
}

String getWeekDay(int weekDay) {
  switch (weekDay) {
    case 1:
      return txt("Monday");
    case 2:
      return txt("Tuesday");
    case 3:
      return txt("Wednesday");
    case 4:
      return txt("Thursday");
    case 5:
      return txt("Friday");
    case 6:
      return txt("Samedi");

    default:
      return txt("Dimanche");
  }
}

String getWeekDayShort(int weekDay) {
  switch (weekDay) {
    case 1:
      return txt("Mo");
    case 2:
      return txt("Tu");
    case 3:
      return txt("We");
    case 4:
      return txt("Th");
    case 5:
      return txt("Fr");
    case 6:
      return txt("Sa");

    default:
      return txt("Su");
  }
}

String getTimeHistoryFr(DateTime time) {
  return "${time.day > 9 ? '' : '0'}${time.day} ${getFullMonth(time.month)}, ${getTime(time)}";
}

String getMonth(int weekDay) {
  switch (weekDay) {
    case 1:
      return txt("JAN");
    case 2:
      return txt("FEB");
    case 3:
      return txt("MAR");
    case 4:
      return txt("APR");
    case 5:
      return txt("MAY");
    case 6:
      return txt("JUN");
    case 7:
      return txt("JUL");
    case 8:
      return txt("AOU");
    case 9:
      return txt("SEP");
    case 10:
      return txt("OCT");
    case 11:
      return txt("NOV");
    default:
      return txt("DEC");
  }
}

String getFullMonth(int weekDay) {
  switch (weekDay) {
    case 1:
      return txt("January");
    case 2:
      return txt("February");
    case 3:
      return txt("March");
    case 4:
      return txt("April");
    case 5:
      return txt("May");
    case 6:
      return txt("June");
    case 7:
      return txt("July");
    case 8:
      return txt("August");
    case 9:
      return txt("September");
    case 10:
      return txt("October");
    case 11:
      return txt("November");
    default:
      return txt("December");
  }
}

DateTime getFirstDayOfWeek(DateTime date) {
  DateTime week = DateTime(date.year, date.month, date.day, 10);
  switch (date.weekday) {
    case 1:
      week = date;
      break;
    case 2:
      date = date.subtract(const Duration(days: 1));
      week = date;
      break;
    case 3:
      date = date.subtract(const Duration(days: 2));
      week = date;
      break;
    case 4:
      date = date.subtract(const Duration(days: 3));
      week = date;
      break;
    case 5:
      date = date.subtract(const Duration(days: 4));
      week = date;
      break;
    case 6:
      date = date.subtract(const Duration(days: 5));
      week = date;
      break;
    default:
      date = date.subtract(const Duration(days: 6));
      week = date;
      break;
  }

  return week;
}
bool isSameWeekAsWednesday(DateTime date) {
  // Find the most recent Wednesday
  DateTime now = DateTime.now();
  int todayWeekday = now.weekday;
  int daysToLastWednesday = (todayWeekday - 3) % 7;
  DateTime lastWednesday = now.subtract(Duration(days: daysToLastWednesday));

  // Normalize to midnight
  lastWednesday = DateTime(lastWednesday.year, lastWednesday.month, lastWednesday.day);

  // Check if the given date is after the last Wednesday and before the next Wednesday
  DateTime nextWednesday = lastWednesday.add(const Duration(days: 7));
  return date.isAfter(lastWednesday) && date.isBefore(nextWednesday);
}

bool isSameWeekStartingMonday(DateTime date) {
  // Get the current date
  DateTime now = DateTime.now();
  // Normalize to midnight
  now = DateTime(now.year, now.month, now.day);
  
  // Calculate the most recent Monday
  DateTime mostRecentMonday = now.subtract(Duration(days: (now.weekday - 1) % 7));
  
  // Calculate the next Monday
  DateTime nextMonday = mostRecentMonday.add(const Duration(days: 7));
  
  // Check if the given date is after the most recent Monday and before the next Monday
  return date.isAfter(mostRecentMonday) && date.isBefore(nextMonday);
}



DateTime getLastDayOfWeek(DateTime date) {
  final d = date.add(const Duration(days: 7));
  DateTime week = DateTime(d.year, d.month, d.day, 9);
  return week;
}

List<DateTime> getWeek(DateTime date) {
  List<DateTime> week = [];
  switch (date.weekday) {
    case 1:
      date = date.subtract(const Duration(days: 2));
      week.addAll(
          List.generate(7, (index) => date.add(Duration(days: index + 1))));
      break;
    case 2:
      date = date.subtract(const Duration(days: 2));
      week.addAll(
          List.generate(7, (index) => date.add(Duration(days: index + 1))));
      break;
    case 3:
      date = date.subtract(const Duration(days: 3));
      week.addAll(
          List.generate(7, (index) => date.add(Duration(days: index + 1))));
      break;
    case 4:
      date = date.subtract(const Duration(days: 4));
      week.addAll(
          List.generate(7, (index) => date.add(Duration(days: index + 1))));
      break;
    case 5:
      date = date.subtract(const Duration(days: 5));
      week.addAll(
          List.generate(7, (index) => date.add(Duration(days: index + 1))));
      break;
    case 6:
      date = date.subtract(const Duration(days: 6));
      week.addAll(
          List.generate(7, (index) => date.add(Duration(days: index + 1))));
      break;
    default:
      date = date.subtract(const Duration(days: 7));
      week.addAll(
          List.generate(7, (index) => date.add(Duration(days: index + 1))));
      break;
  }

  return week;
}

Future<PlatformFile?> pickImage() async {
  final result = await FilePicker.platform
      .pickFiles(allowMultiple: false, type: FileType.image);
  log(result.toString());
  if (result == null) {
    log("user canceled upload file");
    return null;
  } else {
    return result.files.first;
  }
}

Future<String?> scanQrcode() async {
  try {
    log("here");
    final barcode = await BarcodeScanner.scan();
    log('1');
    log(barcode.toString());

    log('barcode?:${barcode.rawContent}');
    return barcode.rawContent;
  } on PlatformException catch (e) {
    if (e.code == BarcodeScanner.cameraAccessDenied) {
      log('The user did not grant the camera permission!');
      return null;
    } else {
      log('Unknown error: $e');
      return null;
    }
  } on FormatException {
    log('User returned using the "back"-button before scanning anything. Result');
    return null;
  } catch (e) {
    log(e.toString());
    return null;
  }
}

Future<bool> requestPermission() async {
  final result = await Permission.manageExternalStorage.request();
  log(result.toString());
  if (result.isGranted) return true;
  final req = await Permission.photos.request();
  log(req.toString());
  if (req.isGranted) return true;
  final req1 = await Permission.mediaLibrary.request();
  log(req1.toString());
  if (req1.isGranted) return true;
  return false;
}
