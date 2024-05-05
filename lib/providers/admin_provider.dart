import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/expeditor_payment.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/payment_service.dart';
import 'package:jetpack/services/pdf_service.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:jetpack/views/widgets/popup.dart';

class AdminProvider with ChangeNotifier {
  List<Colis> allColis = [];

  scanDepot(String colisId) async {
    try {
      Colis colis = allColis.where((c) => c.id == colisId).first;
      if (colis.status != ColisStatus.pickup.name) {
        popup(NavigationService.navigatorKey.currentContext!,
            description: txt('Colis already scanned before'));
        return;
      }
      await ColisService.colisCollection
          .doc(colisId)
          .update({"status": ColisStatus.depot.name});
    } on Exception {
      popup(NavigationService.navigatorKey.currentContext!,
          description: txt('Colis not found'));
      return;
    }
  }

  generateExpeditorPayment(List<Colis> colis, UserModel expeditor) async {
    double totalPrice = 0;
    double deliveryPrice = 0;

    for (var c in colis) {
      if (c.status == ColisStatus.delivered.name) {
        totalPrice += c.price;
        deliveryPrice += expeditor.price;
      } else {
        deliveryPrice += expeditor.returnPrice;
      }
    }

    final sector = await SectorService.getSector(expeditor.region);

    final p = ExpeditorPayment(
        id: generateId(),
        colis: colis.map((e) => e.id).toList(),
        expeditorId: expeditor.id,
        expeditorName: expeditor.getFullName(),
        expeditorPhoneNumber: expeditor.phoneNumber,
        region: expeditor.region,
        adress: expeditor.adress,
        date: DateTime.now(),
        deliveryId: sector != null ? sector.delivery['id'] : '',
        deliveryName: sector != null ? sector.delivery['name'] : '',
        price: totalPrice - deliveryPrice,
        totalprice: totalPrice,
        deliveryPrice: deliveryPrice,
        recived: false);

    await PaymentService.addExpeditorPaiment(p);
    PdfService.generateExpeditorPayment(p, colis);
    for (var c in colis) {
      await ColisService.colisCollection.doc(c.id).update({
        'status': c.status == ColisStatus.canceled.name
            ? "returnExpeditor"
            : ColisStatus.closed.name
      });
    }
    log(p.toString());
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
