import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jetpack/models/colis.dart';
// import 'package:jetpack/models/enum_classes.dart';
// import 'package:jetpack/services/notification_service.dart';
// import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/services/util/language.dart';

class ColisService {
  static CollectionReference<Map<String, dynamic>> colisCollection =
      FirebaseFirestore.instance.collection('colis');

  static Future<String> addColis(Colis colis) async {
    try {
      await colisCollection.doc(colis.id).set(colis.toMap());
      // NotificationService.sendPushNotifications(
      //     title: "Colis",
      //     body: "You have new colis waiting for you\nId: ${colis.id}",
      //     token: await UserService.getUserFcmFromId(colis.deliveryId),
      //     type: 'colis',
      //     userId: colis.deliveryId,
      //     role: Role.delivery.name);
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }

  static Future<List<Colis>> getColis(List<String> colis) async {
    try {
      if (colis.length > 9) {
        final docs = await colisCollection.get();
        return docs.docs
            .where((element) => colis.contains(element.id))
            .map((e) => Colis.fromMap(e.data()))
            .toList();
      } else {
        final docs = await colisCollection.where('id', whereIn: colis).get();
        return docs.docs.map((e) => Colis.fromMap(e.data())).toList();
      }
    } on Exception {
      return [];
    }
  }
}
