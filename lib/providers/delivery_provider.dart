import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/delivery_paiment.dart';
import 'package:jetpack/models/manifest.dart';
import 'package:jetpack/models/runsheet.dart';
import 'package:jetpack/models/sector.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/manifest_service.dart';
import 'package:jetpack/services/pdf_service.dart';
import 'package:jetpack/services/runsheet_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/util/navigation_service.dart';

class DeliveryProvider with ChangeNotifier {
  List<Colis> readyForPickup = [];
  List<Manifest> pickup = [];
  List<Colis> depot = [];
  List<Colis> runsheet = [];
  Sector? sector;
  RunSheet? runsheetData;

  Future<void> scanDepot() async {
    runsheet.where((colis) => !colis.exchange).length;
  }

  Future<void> generateDayReport() async {
    final doc = await RunsheetService.deliveryPaimentCollection
        .where('endDate', isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        .get();
    late DeliveryPayment payment;

    if (doc.docs.isNotEmpty) {
      payment = DeliveryPayment.fromMap(doc.docs.first.data());
    } else {
      final date = getFirstDayOfWeek(DateTime.now());
      log(date.toString());
      payment = DeliveryPayment(
          id: generateId(),
          nbDelivered: 0,
          nbPickup: 0,
          startTime: date,
          endTime: date.add(const Duration(days: 7)));
      await RunsheetService.deliveryPaimentCollection
          .doc(payment.id)
          .set(payment.toMap());
    }
    for (var colis in runsheet) {
      if (colis.status == ColisStatus.delivered.name) {
        payment.nbDelivered += 1;
      }
      if (colis.status == ColisStatus.canceled.name) {}
      if (colis.status == ColisStatus.returnDepot.name) {
        colis.status = ColisStatus.depot.name;
        colis.tentative += 1;
        if (colis.tentative > 3) {
          colis.status = ColisStatus.canceled.name;
        } else {
          colis.status = ColisStatus.depot.name;
        }
        ColisService.colisCollection.doc(colis.id).update(colis.toMap());
      }
      if (colis.status == ColisStatus.appointment.name) {}
    }
    runsheetData!.collectionDate = DateTime.now();
    await RunsheetService.runsheetCollection
        .doc(runsheetData!.id)
        .update({'collectionDate': DateTime.now().millisecondsSinceEpoch});
    await RunsheetService.deliveryPaimentCollection
        .doc(payment.id)
        .update(payment.toMap());
    await PdfService.generateDayReport();
  }

  Future<void> scanRunsheet(Colis colis) async {
    ColisService.colisCollection
        .doc(colis.id)
        .update({'status': ColisStatus.inDelivery.name});

    BuildContext context = NavigationService.navigatorKey.currentContext!;
    log(DateTime.now().toString());
    log(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    if (runsheetData == null) {
      runsheetData = RunSheet(
          id: generateBarCodeId(),
          agenceId: context.userprovider.currentUser!.agency!['id'],
          deliveryId: context.userId,
          dateCreated: DateTime.now(),
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          collectionDate: null,
          colis: [colis.id],
          price: colis.price,
          note: '');
      await RunsheetService.addRunsheet(runsheetData!);
    } else {
      runsheetData!.colis.add(colis.id);
      runsheetData!.price += colis.price;
      await RunsheetService.runsheetCollection
          .doc(runsheetData!.id)
          .update(runsheetData!.toMap());
    }

    // await getRunsheetColis(runsheetData!.colis);
  }

  Future<void> scanManifest(Manifest manifest) async {
    await ManifestService.manifestCollection
        .doc(manifest.id)
        .update({"datePicked": DateTime.now().millisecondsSinceEpoch});
    for (var id in manifest.colis) {
      await ColisService.colisCollection.doc(id).update({
        "status": ColisStatus.pickup.name,
        "pickupDate": DateTime.now().millisecondsSinceEpoch
      });
    }
  }

  setSector() async {
    sector = await SectorService.getSector(NavigationService
        .navigatorKey.currentContext!.userprovider.currentUser!.region);
  }

  filterColis(List<Colis> colis) {
    readyForPickup.clear();
    depot.clear();
    runsheet.clear();

    log('colis: ${colis.map((e) => e.status).join(', ')}');
    for (var c in colis) {
      if (c.status == ColisStatus.ready.name) {
        readyForPickup.add(c);
      }
      if (c.status == ColisStatus.depot.name) {
        depot.add(c);
      }
      if ([
        ColisStatus.inDelivery.name,
        ColisStatus.confirmed.name,
        ColisStatus.delivered.name,
        ColisStatus.canceled.name,
        ColisStatus.returnDepot.name,
        ColisStatus.appointment.name
      ].contains(c.status)) {
        runsheet.add(c);
      }
    }
  }

  // getRunsheetColis(List<String> listId) async {
  //   final data = await ColisService.colisCollection
  //       .where('deliveryId',
  //           isEqualTo: NavigationService.navigatorKey.currentContext!.userId)
  //       .get();
  //   runsheet = data.docs
  //       .where((doc) => listId.contains(doc.id))
  //       .map((doc) => Colis.fromMap(doc.data()))
  //       .toList();
  //   notifyListeners();
  // }

  Future<void> updateOrderRunsheet(oldIndex, newIndex) async {
    log("$oldIndex, $newIndex");
    List<String> colis = runsheetData!.colis.map((e) => e).toList();
    final id = colis.removeAt(oldIndex);
    if (newIndex == runsheetData!.colis.length) {
      colis.add(id);
    } else {
      colis.insert(newIndex, id);
    }

    RunsheetService.runsheetCollection
        .doc(runsheetData!.id)
        .update({"colis": colis});
  }

// stream data
  Stream<QuerySnapshot<Map<String, dynamic>>>? colisStream;

  startColisStream() async {
    if (colisStream != null) return;
    await setSector();

    colisStream = ColisService.colisCollection
        .where('deliveryId',
            isEqualTo: NavigationService.navigatorKey.currentContext!.userId)
        .snapshots();
    colisStream?.listen((event) {}).onData((data) async {
      filterColis(
          data.docs.map((colisDoc) => Colis.fromMap(colisDoc.data())).toList());
      notifyListeners();
    });
    startManifestStream();
    startRunsheetStream();
  }

  stopColisStream() {
    stopManifestStream();
    stopRunsheetStream();
    if (colisStream == null) return;
    colisStream?.listen((event) {}).cancel();
    colisStream = null;
    sector = null;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? manifestStream;

  startManifestStream() {
    if (manifestStream != null) return;
    if (sector == null) return;
    log('manifest');
    manifestStream = ManifestService.manifestCollection
        .where("datePicked", isNull: true)
        .where('region', whereIn: sector!.regions)
        .snapshots();
    manifestStream?.listen((event) {}).onData((data) async {
      pickup = data.docs
          .map((colisDoc) => Manifest.fromMap(colisDoc.data()))
          .toList();
      // log(pickup.toString());
      notifyListeners();
    });
  }

  stopManifestStream() {
    if (manifestStream == null) return;
    manifestStream?.listen((event) {}).cancel();
    manifestStream = null;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? runsheetStream;

  startRunsheetStream() async {
    if (runsheetStream != null) return;

    runsheetStream = RunsheetService.runsheetCollection
        .where('deliveryId',
            isEqualTo: NavigationService.navigatorKey.currentContext!.userId)
        // .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .where('collectonDate', isNull: true)
        .snapshots();
    runsheetStream?.listen((event) {}).onData((data) async {
      log('runsheet: ${data.docs.length}');
      if (data.docs.isNotEmpty) {
        runsheetData = RunSheet.fromMap(data.docs.first.data());
        notifyListeners();
      } else {
        runsheetData = null;
      }
    });
  }

  stopRunsheetStream() {
    if (runsheetStream == null) return;
    runsheetStream?.listen((event) {}).cancel();
    runsheetStream = null;
    runsheetData = null;
  }
}
