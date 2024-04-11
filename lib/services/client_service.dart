import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jetpack/models/client.dart';
import 'package:jetpack/services/util/language.dart';

class ClientService{

    static CollectionReference<Map<String, dynamic>> clientCollection =
      FirebaseFirestore.instance.collection('client');

  static Future<String> addClient(Client client) async {
  
    try {
      await clientCollection.doc(client.id).set(client.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }

}