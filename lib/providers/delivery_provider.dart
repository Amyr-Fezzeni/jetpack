// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/delivery_paiment.dart';
import 'package:jetpack/models/expeditor_payment.dart';
import 'package:jetpack/models/manifest.dart';
import 'package:jetpack/models/return_colis.dart';
import 'package:jetpack/models/runsheet.dart';
import 'package:jetpack/models/sector.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/manifest_service.dart';
import 'package:jetpack/services/payment_service.dart';
import 'package:jetpack/services/pdf_service.dart';
import 'package:jetpack/services/runsheet_service.dart';
import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:permission_handler/permission_handler.dart';

class DeliveryProvider with ChangeNotifier {
  List<Colis> allColis = [];
  List<Colis> readyForPickup = [];
  List<Manifest> pickup = [];
  List<ExpeditorPayment> payments = [];
  List<Colis> depot = [];
  List<Colis> returnExpeditor = [];
  List<ReturnColis> returnColis = [];
  List<Colis> runsheet = [];
  Sector? sector;
  RunSheet? runsheetData;

  Future<void> generateDayReport() async {
    final doc = await PaymentService.deliveryPaimentCollection
        // .where('endDate', isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        .where('userId',
            isEqualTo: NavigationService.navigatorKey.currentContext!.userId)
        .where('isPaid', isEqualTo: false)
        .get();
    late DeliveryPayment payment;
    final docs =
        doc.docs.map((e) => DeliveryPayment.fromMap(e.data())).toList();
    if (docs.where((p) => p.endTime.isAfter(DateTime.now())).isNotEmpty) {
      payment = docs.where((p) => p.endTime.isAfter(DateTime.now())).last;
    } else {
      payment = DeliveryPayment(
          id: generateId(),
          userId: NavigationService.navigatorKey.currentContext!.userId,
          isPaid: false,
          nbDelivered: 0,
          nbPickup: 0,
          startTime: getFirstDayOfWeek(DateTime.now()),
          endTime: getLastDayOfWeek(getFirstDayOfWeek(DateTime.now())));

      await PaymentService.deliveryPaimentCollection
          .doc(payment.id)
          .set(payment.toMap());
    }
    // log(payment.toString());
    // log(getFirstDayOfWeek(DateTime(2024, 4, 23))
    //     .millisecondsSinceEpoch
    //     .toString());
    // log(getLastDayOfWeek(payment.startTime).millisecondsSinceEpoch.toString());
    for (var colis in runsheet) {
      if (colis.status == ColisStatus.delivered.name) {
        payment.nbDelivered += 1;
      }
      if (colis.status == ColisStatus.canceled.name) {}
      if (colis.status == ColisStatus.returnDepot.name) {
        if (colis.tentative >= 3) {
          colis.status = ColisStatus.canceled.name;
        } else {
          colis.status = ColisStatus.depot.name;
        }
        ColisService.colisCollection.doc(colis.id).update(colis.toMap());
      }
      if (colis.status == ColisStatus.appointment.name) {
        if (colis.appointmentDate != null) {
          colis.status = ColisStatus.returnDepot.name;
          colis.tentative += 1;
          ColisService.colisCollection.doc(colis.id).update(colis.toMap());
        }
      }
    }
    runsheetData!.collectionDate = DateTime.now();
    await RunsheetService.runsheetCollection
        .doc(runsheetData!.id)
        .update({'collectionDate': DateTime.now().millisecondsSinceEpoch});
    await PaymentService.deliveryPaimentCollection
        .doc(payment.id)
        .update(payment.toMap());
    BuildContext context = NavigationService.navigatorKey.currentContext!;
    await PdfService.generateDayReport(RunsheetPdf(
        id: runsheetData!.id,
        agenceName: context.userprovider.currentUser!.agency!['name'],
        deliveryCin: context.userprovider.currentUser!.cin,
        deliveryName: context.userprovider.currentUser!.getFullName(),
        matricule: context.userprovider.currentUser!.matricule,
        date: runsheetData!.date,
        colis: runsheet,
        price: runsheetData!.price,
        note: runsheetData!.note));
  }

  Future<void> scanRunsheet(String colisId) async {
    BuildContext context = NavigationService.navigatorKey.currentContext!;
    if (!depot.map((e) => e.id).contains(colisId)) {
      popup(context,
          description: txt("Colis Not found or already scanned"),
          cancel: false);
      return;
    }
    final colis = depot.where((element) => element.id == colisId).first;
    colis.tentative += 1;
    colis.status = ColisStatus.inDelivery.name;
    colis.pickupDate = DateTime.now();
    ColisService.colisCollection.doc(colis.id).update(colis.toMap());

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
  }

  Future<void> scanManifest(String manifestId) async {
    BuildContext context = NavigationService.navigatorKey.currentContext!;
    if (!pickup.map((e) => e.id).contains(manifestId)) {
      popup(context,
          description: txt("Manifest Not found or already scanned"),
          cancel: false);
      return;
    }
    final manifest = pickup.where((element) => element.id == manifestId).first;
    final doc = await PaymentService.deliveryPaimentCollection
        // .where('endDate', isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        .where('userId',
            isEqualTo: NavigationService.navigatorKey.currentContext!.userId)
        .where('isPaid', isEqualTo: false)
        .get();
    late DeliveryPayment payment;

    if (doc.docs.isNotEmpty) {
      payment = DeliveryPayment.fromMap(doc.docs.last.data());
    } else {
      payment = DeliveryPayment(
          id: generateId(),
          userId: NavigationService.navigatorKey.currentContext!.userId,
          isPaid: false,
          nbDelivered: 0,
          nbPickup: 0,
          startTime: getFirstDayOfWeek(DateTime.now()),
          endTime: getLastDayOfWeek(DateTime.now()));
      await PaymentService.deliveryPaimentCollection
          .doc(payment.id)
          .set(payment.toMap());
    }
    await ManifestService.manifestCollection
        .doc(manifest.id)
        .update({"datePicked": DateTime.now().millisecondsSinceEpoch});
    for (var id in manifest.colis) {
      await ColisService.colisCollection.doc(id).update({
        "status": ColisStatus.pickup.name,
        "pickupDate": DateTime.now().millisecondsSinceEpoch
      });
    }
    payment.nbPickup += 1;
    await PaymentService.deliveryPaimentCollection
        .doc(payment.id)
        .update(payment.toMap());
  }

  setSector() async {
    sector = await SectorService.getSector(NavigationService
        .navigatorKey.currentContext!.userprovider.currentUser!.region);
  }

  filterColis(List<Colis> colis) {
    readyForPickup.clear();
    depot.clear();
    runsheet.clear();
    returnExpeditor.clear();
    allColis = colis;
    log('colis: ${colis.map((e) => e.status).join(', ')}');
    for (var c in colis) {
      if (c.status == ColisStatus.ready.name) {
        readyForPickup.add(c);
      }
      if ([ColisStatus.depot.name].contains(c.status)) {
        depot.add(c);
      }
      if ([ColisStatus.returnExpeditor.name, ColisStatus.returnConfirmed.name]
          .contains(c.status)) {
        returnExpeditor.add(c);
      }
      if (c.status == ColisStatus.appointment.name) {
        if (c.appointmentDate!.isBefore(DateTime.now()) ||
            (c.appointmentDate!.day == DateTime.now().day)) {
          depot.add(c);
        }
      }
      log(runsheetData.toString());
      if (runsheetData != null) {
        if (runsheetData!.colis.contains(c.id)) runsheet.add(c);
      }
      // if ([
      //   ColisStatus.inDelivery.name,
      //   ColisStatus.confirmed.name,
      //   ColisStatus.delivered.name,
      //   ColisStatus.canceled.name,
      //   ColisStatus.returnDepot.name,
      //   ColisStatus.appointment.name
      // ].contains(c.status)) {
      //   // if (c.status == ColisStatus.appointment.name &&
      //   //     (c.appointmentDate == null ||
      //   //         c.appointmentDate?.day != DateTime.now().day)) {
      //   //   continue;
      //   // }
      //   runsheet.add(c);
      // }
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
    listenLocation();
    startManifestStream();
    startRunsheetStream();
    startPaymentStream();
    startReturnColisStream();
    colisStream = ColisService.colisCollection
        .where('deliveryId',
            isEqualTo: NavigationService.navigatorKey.currentContext!.userId)
        .where('status', isNotEqualTo: ColisStatus.closed.name)
        .snapshots();
    colisStream?.listen((event) {}).onData((data) async {
      filterColis(
          data.docs.map((colisDoc) => Colis.fromMap(colisDoc.data())).toList());
      notifyListeners();
    });
  }

  stopColisStream() {
    locationListening = false;
    stopManifestStream();
    stopRunsheetStream();
    stopReturnColisStream();
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
        .where('date',
            isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()))
        // .where('collectonDate', isNull: true)
        .snapshots();
    runsheetStream?.listen((event) {}).onData((data) async {
      log('runsheet: ${data.docs.length}');
      if (data.docs.isNotEmpty) {
        runsheetData = RunSheet.fromMap(data.docs.last.data());
        if (runsheetData!.date !=
            DateFormat('yyyy-MM-dd').format(DateTime.now())) {
          runsheetData = null;
        }
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

  Stream<QuerySnapshot<Map<String, dynamic>>>? paymentStream;

  startPaymentStream() async {
    if (paymentStream != null) return;

    paymentStream = PaymentService.expeditorPaimentCollection
        .where('deliveryId',
            isEqualTo: NavigationService.navigatorKey.currentContext!.userId)
        .where('recived', isEqualTo: false)
        .snapshots();
    paymentStream?.listen((event) {}).onData((data) async {
      payments =
          data.docs.map((e) => ExpeditorPayment.fromMap(e.data())).toList();

      notifyListeners();
    });
  }

  stopPaymentStream() {
    if (paymentStream == null) return;
    paymentStream?.listen((event) {}).cancel();
    paymentStream = null;
    payments = [];
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? returnColisStream;

  startReturnColisStream() async {
    if (returnColisStream != null) return;

    returnColisStream = FirebaseFirestore.instance
        .collection('return colis')
        .where('isClosed', isEqualTo: false)
        .where('region', whereIn: sector!.regions)
        .snapshots();
    returnColisStream?.listen((event) {}).onData((data) async {
      returnColis =
          data.docs.map((e) => ReturnColis.fromMap(e.data())).toList();

      notifyListeners();
    });
  }

  stopReturnColisStream() {
    if (returnColisStream == null) return;
    returnColisStream?.listen((event) {}).cancel();
    returnColisStream = null;
    returnColis.clear();
  }

  GeoPoint? lastCurrentLocation;
  GeoPoint? currentLocation;
  bool locationListening = false;
  Future<void> listenLocation() async {
    // log('listenLocation()');
    if (locationListening) return;
    locationListening = true;
    if (NavigationService
            .navigatorKey.currentContext!.userprovider.currentUser ==
        null) return;
    Timer.periodic(const Duration(seconds: 60), (timer) async {
      BuildContext context = NavigationService.navigatorKey.currentContext!;
      if (context.userprovider.currentUser == null) {
        timer.cancel();
        locationListening = false;
        await UserService.userCollection.doc(context.userId).update({
          'location': null,
        });
        return;
      }
      final data = await requestLocationPermition();
      if (!data) return;
      final loc = await Geolocator.getCurrentPosition();

      // log(loc.toString());
      if (GeoPoint(loc.latitude, loc.longitude) == currentLocation) {
        // log('same location');
        return;
      }
      if (lastCurrentLocation == null) {
        if (currentLocation == null) {
          currentLocation = GeoPoint(loc.latitude, loc.longitude);
          updateCurrentLocation();
        } else {
          lastCurrentLocation = currentLocation;
          currentLocation = GeoPoint(loc.latitude, loc.longitude);
          updateCurrentLocation();
        }
      } else {
        lastCurrentLocation = currentLocation;
        currentLocation = GeoPoint(loc.latitude, loc.longitude);
        updateCurrentLocation();
      }
    });
  }

  updateCurrentLocation() async {
    log('location: $currentLocation');
    if (currentLocation == null) return;
    await UserService.userCollection
        .doc(NavigationService.navigatorKey.currentContext!.userId)
        .update({
      'location':
          GeoPoint(currentLocation!.latitude, currentLocation!.longitude),
      'lastUpdateLocation': DateTime.now().millisecondsSinceEpoch
    });
  }

  Future<bool> requestLocationPermition() async {
    await Geolocator.requestPermission();
    //log((await Geolocator.checkPermission()).toString());
    // Position pos = await Geolocator.getCurrentPosition();
    // //log((await location.requestPermission()).toString());
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      // log("serviceEnabled: $serviceEnabled");
      return true;
    }
    if (!serviceEnabled) {
      openAppSettings();
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    // log("permission: $permission");
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
