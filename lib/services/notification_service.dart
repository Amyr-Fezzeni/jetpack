// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:jetpack/models/notification/notification.dart';
import 'package:jetpack/services/util/logic_service.dart';

import 'util/language.dart';

class NotificationService {
  static late AndroidNotificationChannel channel;
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static String? token = " ";

  static Future<bool> sendPushNotifications({
    required String title,
    required String body,
    required String? token,
    required String type,
    required String userId,
    required String role,
  }) async {
    saveNotification(Notif(
        id: generateId(),
        notificationType: type,
        title: title,
        body: body,
        to: userId,
        seen: false,
        createdAt: DateTime.now()));

    if (token == null) return false;
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to": token,
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "type": type,
        "id": userId,
        "title": title,
        "body": body,
        "role": role,
        "click_action": 'FLUTTER_NOTIFICATION_CLICK',
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAFCyePtM:APA91bESdwcwN-ZS8N6Q-Jp_Xt1fVHAaTanuFzDSJcCDoi5rDNloGxJ8PnjXLC2TFkk6cJivGd2HtQ9_GUfKfXCBpqszGLuhTa14TSOEvIQf9Rq_uC592XBm7CTwlHRdt_AqBEBAz5Ai' // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      log('test ok push FCM');
      return true;
    } else {
      // log('FCM error: ${response.body}');
      // on failure do sth
      return false;
    }
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  static void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // log('User granted provisional permission');
    } else {
      // log('User declined or has not accepted permission');
    }
  }

  static void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // log("fcm here");
      // log(message.toMap().toString());
      // Notif notif = Notif(
      //     createdAt: message.sentTime ?? DateTime.now(),
      //     body: message.data['body'] ?? '',
      //     title: message.data['title'] ?? '',
      //     id: generateId(),
      //     notificationType: message.data['type'].toString(),
      //     seen: false,
      //     to: message.data['id'].toString());
      // saveNotification(notif);
      // log(notif.toString());
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  static void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static Future<void> createNotification(
      {required String title, required String body, String? img}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        bigPicture: img, //'asset://assets/notification_map.png',
        notificationLayout: NotificationLayout.BigPicture,
      ),
    );
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage remoteMessage) async {
    // debugPrint('Background message ${remoteMessage.messageId}');
    createNotification(
        title: remoteMessage.notification!.title ?? "Tuxedo",
        body: remoteMessage.notification!.body ?? "",
        img: remoteMessage.notification?.android?.imageUrl);

    //pushNotif(remoteMessage);
  }

  static Future<Uint8List> getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  static StreamSubscription<RemoteMessage>? notifSub;
  static StreamSubscription<RemoteMessage>? notifSubOnOpenApp;

  static cancelNotifSub() {
    if (notifSub != null) {
      notifSub!.cancel();
    }
    if (notifSubOnOpenApp != null) notifSubOnOpenApp!.cancel();
  }

  static void initialize() async {
    // for ios and web
    FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onBackgroundMessage((remoteMessage) {
      return Future.value();
    });
    sub();
  }

  static void sub() {
    notifSub =
        FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      createNotification(
          title: remoteMessage.notification!.title ?? "Tuxedo",
          body: remoteMessage.notification!.body ?? "",
          img: remoteMessage.notification?.android?.imageUrl);
    });

    FirebaseMessaging.instance.getInitialMessage().then((remoteMessage) async {
      return null;
    });

    notifSubOnOpenApp = FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage remoteMessage) async {
      onclikNotifications(remoteMessage);
    });
  }

  static void onclikNotifications(remoteMessage) async {
    log("clicked ${remoteMessage.toMap().toString()}");
  }

  static Future<String> saveNotification(Notif notif) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notif.id)
          .set(notif.toMap())
          .whenComplete(() => log(notif.toString()));
    } on Exception catch (e) {
      return "${txt('An error has occurred')} $e";
    }
    return "true";
  }

  static Future<String> seenNotification(String notifId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notifId)
          .update({"seen": true});
    } on Exception catch (e) {
      return "${txt('An error has occurred')} $e";
    }
    return "true";
  }

  static Future<String> deleteNotification(String notifId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notifId)
          .delete();
    } on Exception catch (e) {
      return "${txt('An error has occurred')} $e";
    }
    return "true";
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllNotification(
      String id) {
    return FirebaseFirestore.instance
        .collection("notifications")
        .where("to", isEqualTo: id)
        .snapshots();
  }
}
