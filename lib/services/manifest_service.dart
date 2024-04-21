import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jetpack/models/manifest.dart';
import 'package:jetpack/services/util/language.dart';

class ManifestService {
  static CollectionReference<Map<String, dynamic>> manifestCollection =
      FirebaseFirestore.instance.collection('manifest');

  static Future<String> createMagnifest(Manifest manifest) async {
    try {
      await manifestCollection.doc(manifest.id).set(manifest.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }
}
