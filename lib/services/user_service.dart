import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:jetpack/providers/notification_provider.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/providers/user_provider.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:jetpack/services/notification_service.dart';
import 'util/language.dart';

class UserService {
  static CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection('users');

  static Future<String> addUser(UserModel user) async {
    if (await checkExistingUser(user.email)) {
      return txt('email already exist');
    }
    try {
      await userCollection.doc(user.id).set(user.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }

  static Future<String> uploadImage(File file,
      {required String folder, required String type}) async {
    try {
      String path =
          "media/${NavigationService.navigatorKey.currentContext!.userId}/$folder/${generateId()}.$type";
      log(path);
      final ref = FirebaseStorage.instance.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final urlImage = await snapshot.ref.getDownloadURL();
      return urlImage;
    } on Exception catch (e) {
      debugPrint('Error upload document: $e');
      return '';
    }
  }

  static Future<bool> uploadUserImage(String imagePath) async {
    try {
      await userCollection
          .doc(NavigationService.navigatorKey.currentContext!
              .read<UserProvider>()
              .currentUser!
              .id)
          .update({"photo": imagePath});
      return true;
    } on Exception {
      return false;
    }
  }

  static Future<bool> checkExistingUser(String email) async {
    final snapshot =
        await userCollection.where('email', isEqualTo: email).limit(1).get();
    if (snapshot.docs.isNotEmpty) return true;
    return false;
  }

  static Future<UserModel?> getUser(String email, String password) async {
    log("locking");
    final snapshot = await userCollection
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();
    log("completed");
    if (snapshot.docs.isNotEmpty) {
      UserModel user = UserModel.fromMap(snapshot.docs.first.data());
      return user;
    } else {
      return null;
    }
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    final snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    if (snapshot.docs.isNotEmpty) {
      UserModel user = UserModel.fromMap(snapshot.docs.first.data());
      return user;
    } else {
      return null;
    }
  }

  static Future<UserModel?> getUserById(String id) async {
    final snapshot = await userCollection.where('id', isEqualTo: id).get();
    if (snapshot.docs.isNotEmpty) {
      UserModel user = UserModel.fromMap(snapshot.docs.first.data());
      return user;
    } else {
      return null;
    }
  }

  static Future<bool> changePassword(String userId, String pass) async {
    try {
      await userCollection.doc(userId).update({"password": pass});
      return true;
    } on Exception {
      return false;
    }
  }

  static Future<bool> checkExistingPhone(String phone) async {
    final snapshot = await userCollection
        .where('phoneNumber', isEqualTo: phone)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) return true;
    return false;
  }

  static Future<bool> changePhoneNumber(UserModel user, String phone) async {
    try {
      await userCollection.doc(user.id).update({"phoneNumber": phone});
      return true;
    } on Exception {
      return false;
    }
  }

  static Future<bool> saveFcm(String userId) async {
    if (!NavigationService.navigatorKey.currentContext!
        .read<NotificationProvider>()
        .isNotificationActive) return false;
    try {
      String? token = await NotificationService.getToken();
      if (token == null) return false;
      await userCollection.doc(userId).update({'fcm': token});
      return true;
    } on Exception {
      return false;
    }
  }

  static Future<void> connectStatus(bool value) async {
    try {
      await userCollection
          .doc(NavigationService.navigatorKey.currentContext!.userId)
          .update({'isConnected': value});
    } on Exception {
      return;
    }
  }

  static Future<bool> removeFcm(String userId) async {
    try {
      await userCollection.doc(userId).update({'fcm': null});
      return true;
    } on Exception {
      return false;
    }
  }

  static Future<String?> getUserFcmFromId(String id) async {
    final snapshot = await userCollection.where('id', isEqualTo: id).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['fcm'];
    } else {
      return null;
    }
  }

  static bool timeDiffrence(DateTime start, DateTime end) {
    if (start.hour <= end.hour ||
        (start.hour == end.hour && start.minute < end.minute)) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> setNotificationSetting(bool value) async {
    await userCollection
        .doc(NavigationService.navigatorKey.currentContext!.userId)
        .update({
      'notificationStatus': value,
      'fcm': value ? await NotificationService.getToken() : null
    });
  }
}
