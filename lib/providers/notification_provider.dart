import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/models/notification/notification.dart';
import 'package:jetpack/models/relaunch_colis.dart';
import 'package:jetpack/models/report.dart';
import 'package:jetpack/services/notification_service.dart';
import 'package:jetpack/services/shared_data.dart';
import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/navigation_service.dart';

class NotificationProvider with ChangeNotifier {
  Stream<QuerySnapshot<Map<String, dynamic>>>? notificationStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? reportStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? relaunchStream;
  List<Notif> notifications = [];
  List<Report> reports = [];
  List<RelaunchColis> relaunches = [];
  bool isNotificationActive = true;

  getNotificationStatus() {
    isNotificationActive = DataPrefrences.getNotification();
  }

  changeNoticationStatus(bool value) {
    DataPrefrences.setNotification(value);
    getNotificationStatus();
    if (value) {
      UserService.saveFcm(
          NavigationService.navigatorKey.currentContext!.userId);
    } else {
      UserService.removeFcm(
          NavigationService.navigatorKey.currentContext!.userId);
    }
  }

  startNotificationsListen() {
    startReportListen();
    startrelaunchListen();
    if (notificationStream != null) return;
    notificationStream = FirebaseFirestore.instance
        .collection("notifications")
        .where('to',
            isEqualTo: NavigationService.navigatorKey.currentContext!.userId)
        .snapshots();
    notificationStream?.listen((event) {}).onData((data) {
      notifications =
          List<Notif>.from(data.docs.map((e) => Notif.fromMap(e.data())));
      notifyListeners();
    });
  }

  updateNotificationStatus(bool value) async {
    UserService.setNotificationSetting(value);
    if (value) {
      NotificationService.listenFCM();
    } else {
      NotificationService.cancelNotifSub();
    }
  }

  removeNotificationStream() async {
    removeRelaunchStream();
    removeReportStream();
    if (notificationStream == null) return;
    notificationStream?.listen((event) {}).cancel();
    notificationStream = null;
  }

  sendNotification(
      {required String userFrom,
      required String userTo,
      required String message}) async {}

//
  startReportListen() {
    if (reportStream != null) return;
    reportStream = FirebaseFirestore.instance
        .collection("reports")
        .where('agencyId',
            isEqualTo: NavigationService.navigatorKey.currentContext!
                .userprovider.currentUser!.agency?['id'])
        .snapshots();
    reportStream?.listen((event) {}).onData((data) {
      log('reports: ${data.docs.length}');
      reports =
          List<Report>.from(data.docs.map((e) => Report.fromMap(e.data())));
      notifyListeners();
    });
  }

  removeReportStream() async {
    if (reportStream == null) return;
    reportStream?.listen((event) {}).cancel();
    reportStream = null;
  }

  startrelaunchListen() {
    if (relaunchStream != null) return;
    relaunchStream = FirebaseFirestore.instance
        .collection("relaunch")
        .where('status', isEqualTo: ReportStatus.review.name)
        .where('agencyId',
            isEqualTo: NavigationService.navigatorKey.currentContext!
                .userprovider.currentUser!.agency?['id'])
        .snapshots();
    relaunchStream?.listen((event) {}).onData((data) {
      log('RelaunchColis: ${data.docs.length}');
      for (var c in data.docs) {
        log(c.data().toString());
      }
      relaunches = List<RelaunchColis>.from(
          data.docs.map((e) => RelaunchColis.fromMap(e.data())));
      log(relaunches.length.toString());
      notifyListeners();
    });
  }

  removeRelaunchStream() async {
    if (relaunchStream == null) return;
    relaunchStream?.listen((event) {}).cancel();
    relaunchStream = null;
  }
}
