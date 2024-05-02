import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jetpack/models/runsheet.dart';
import 'package:jetpack/services/util/language.dart';

class RunsheetService{

    static CollectionReference<Map<String, dynamic>> runsheetCollection =
      FirebaseFirestore.instance.collection('runsheet');
  

  static Future<String> addRunsheet(RunSheet runsheet) async {
  
    try {
      await runsheetCollection.doc(runsheet.id).set(runsheet.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }
  

}