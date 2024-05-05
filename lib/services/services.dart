import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jetpack/models/relaunch_colis.dart';
import 'package:jetpack/services/util/language.dart';

class RelaunchColisService {
  static CollectionReference<Map<String, dynamic>> colisCollection =
      FirebaseFirestore.instance.collection('relaunch');

  static Future<String> requestRelaunch(RelaunchColis colis) async {
    try {
      await colisCollection.doc(colis.id).set(colis.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }

  static Future<List<RelaunchColis>> getRequests(
      {required String ageencyId}) async {
    try {
      final docs =
          await colisCollection.where('agencyId', isEqualTo: ageencyId).get();
      return docs.docs.map((e) => RelaunchColis.fromMap(e.data())).toList();
    } on Exception {
      return [];
    }
  }
}
