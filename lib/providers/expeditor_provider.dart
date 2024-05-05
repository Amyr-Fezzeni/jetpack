// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/manifest.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/manifest_service.dart';
import 'package:jetpack/services/pdf_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/util/navigation_service.dart';

class ExpeditorProvider with ChangeNotifier {
  List<Colis> allColis = [];

  Stream<QuerySnapshot<Map<String, dynamic>>>? colisStream;

  startColisStream() {
    if (colisStream != null) return;

    colisStream = ColisService.colisCollection
        .where('expeditorId',
            isEqualTo: NavigationService.navigatorKey.currentContext!.userId)
        .snapshots();
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

  Future<bool> generateMagnifest(List<Colis> colis) async {
    try {
      String id = generateBarCodeId();
      BuildContext context = NavigationService.navigatorKey.currentContext!;
      final expeditor = context.userprovider.currentUser!;
      Manifest magnifest = Manifest(
          id: id,
          phoneNumber: expeditor.phoneNumber,
          expeditorId: expeditor.id,
          expeditorName: expeditor.getFullName(),
          fiscalMatricule: expeditor.fiscalMatricule,
          governorate: expeditor.governorate,
          city: expeditor.city,
          region: expeditor.region,
          adress: expeditor.adress,
          dateCreated: DateTime.now(),
          colis: colis.map((e) => e.id).toList(),
          totalPrice: colis.map((e) => e.price).reduce((a, b) => a + b));

      final value = await ManifestService.createMagnifest(magnifest);
      await PdfService.generateMagnifest(magnifest, colis);
      if (value == 'true') {
        for (var c in colis) {
          await ColisService.colisCollection
              .doc(c.id)
              .update({'status': ColisStatus.ready.name});
        }
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      log(e.toString());
      return false;
    }
  }
}
