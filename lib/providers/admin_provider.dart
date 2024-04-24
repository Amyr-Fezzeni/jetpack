import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/services/colis_service.dart';

class AdminProvider with ChangeNotifier {
  List<Colis> allColis = [];

  scanDepot(String colisId) async {
    // test colis
    await ColisService.colisCollection
        .doc(colisId)
        .update({"status": ColisStatus.depot.name});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? colisStream;

  startColisStream() {
    if (colisStream != null) return;

    colisStream = ColisService.colisCollection.snapshots();
    colisStream?.listen((event) {}).onData((data) async {
      filterColis(
          data.docs.map((colisDoc) => Colis.fromMap(colisDoc.data())).toList());
      notifyListeners();
    });
  }

  stopColisStream() {
    if (colisStream == null) return;
    colisStream?.listen((event) {}).cancel();
    colisStream = null;
  }

  filterColis(List<Colis> colis) {
    allColis = colis;
  }
}
