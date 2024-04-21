import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jetpack/models/delivery_paiment.dart';
import 'package:jetpack/models/runsheet.dart';
import 'package:jetpack/services/util/language.dart';

class RunsheetService{

    static CollectionReference<Map<String, dynamic>> runsheetCollection =
      FirebaseFirestore.instance.collection('runsheet');
    static CollectionReference<Map<String, dynamic>> deliveryPaimentCollection =
      FirebaseFirestore.instance.collection('deliveryPaiment');

  static Future<String> addRunsheet(RunSheet runsheet) async {
  
    try {
      await runsheetCollection.doc(runsheet.id).set(runsheet.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }

  static Future<String> addDeliveryPaiment(DeliveryPayment payment) async {
  
    try {
      await deliveryPaimentCollection.doc(payment.id).set(payment.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }

}