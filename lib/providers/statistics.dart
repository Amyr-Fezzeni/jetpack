import 'package:flutter/material.dart';
import 'package:jetpack/models/agency.dart';
import 'package:jetpack/models/client.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/delivery_paiment.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/expeditor_payment.dart';
import 'package:jetpack/models/manifest.dart';
import 'package:jetpack/models/runsheet.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/manifest_service.dart';
import 'package:jetpack/services/payment_service.dart';
import 'package:jetpack/services/runsheet_service.dart';
import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/services/util/logic_service.dart';

class Statistics with ChangeNotifier {
  List<UserModel> expeditors = [];
  List<UserModel> delivery = [];
  List<Agency> agency = [];
  List<Colis> colis = [];
  List<ExpeditorPayment> exPayments = [];
  List<DeliveryPayment> deliveryPayments = [];
  List<Client> clients = [];
  List<RunSheet> runsheets = [];
  List<Manifest> manifests = [];
  bool sameWeek(DateTime? date) {
    return true;
  }

  bool sameMonth(DateTime? date) {
    return true;
  }

  bool sameDay(DateTime first, DateTime second) {
    return true;
  }

  deliveryInit(String userId) async {}

  expeditorInit(String userId) async {}
  adminInit(String userId) async {}
  init({required String userId, required Role role}) async {
    await getUsers();
    await getExpeditorPayments();
    await getDeliveryyPayments();
    await getAgengy();
    await getColis();
    await getRunsheet();
    await getManifest();
    if (role == Role.delivery) {
      deliveryInit(userId);
    }
    if (role == Role.expeditor) {
      expeditorInit(userId);
    }
    if (role == Role.admin) {
      adminInit(userId);
    }
  }

  getUsers() async {
    final users = (await UserService.userCollection.get())
        .docs
        .map((e) => UserModel.fromMap(e.data()));
    for (var user in users) {
      if (user.role == Role.delivery) delivery.add(user);
      if (user.role == Role.expeditor) expeditors.add(user);
    }
  }

  getExpeditorPayments() async {
    exPayments = (await PaymentService.expeditorPaimentCollection.get())
        .docs
        .map((e) => ExpeditorPayment.fromMap(e.data()))
        .toList();
  }

  getDeliveryyPayments() async {
    deliveryPayments = (await PaymentService.deliveryPaimentCollection.get())
        .docs
        .map((e) => DeliveryPayment.fromMap(e.data()))
        .toList();
  }

  getAgengy() async {
    agency = (await AgencyService.agencyCollection.get())
        .docs
        .map((e) => Agency.fromMap(e.data()))
        .toList();
  }

  getManifest() async {
    manifests = (await ManifestService.manifestCollection.get())
        .docs
        .map((e) => Manifest.fromMap(e.data()))
        .toList();
  }

  getColis() async {
    colis = (await ColisService.colisCollection.get())
        .docs
        .map((e) => Colis.fromMap(e.data()))
        .toList();
  }

  getRunsheet() async {
    runsheets = (await RunsheetService.runsheetCollection.get())
        .docs
        .map((e) => RunSheet.fromMap(e.data()))
        .toList();
  }

// delivery extra
  getLastDeliveryPayment(UserModel user) {
    final data = deliveryPayments.where((p) => p.userId == user.id);
    return data.isEmpty
        ? '0.000 TND'
        : '${(data.last.nbDelivered * user.price + data.last.nbPickup * user.returnPrice).toStringAsFixed(3)} TND';
  }

  List<Map<String, dynamic>> runsheetColisDelivery(UserModel user) {
    final data = runsheets
        .where((p) => p.deliveryId == user.id && sameWeek(p.dateCreated!));
    if (data.isEmpty) return [];
    List<Map<String, dynamic>> lst = [];
    for (var d in data) {
      Map<String, dynamic> dayData = {
        "date": d.date,
        'index': lst.length,
        'delivered': 0,
        'canceled': 0
      };
      for (var c in colis.where((element) => d.colis.contains(element.id))) {
        if ([ColisStatus.closed.name, ColisStatus.delivered.name]
            .contains(c.status)) {
          dayData['delivered'] += 1;
          continue;
        }
        if ([ColisStatus.closedReturn.name].contains(c.status)) {
          dayData['canceled'] += 1;
          continue;
        }
      }
      lst.add(dayData);
    }
    return lst;
  }

  // expeditor extra
  getLastExpeditorPayment(UserModel user) {
    final data = exPayments.where((p) => p.expeditorId == user.id);
    return data.isEmpty
        ? '0.000 TND'
        : '${(data.last.price - data.last.deliveryPrice).toStringAsFixed(3)} TND';
  }

  Map<String, dynamic> colisExpeditor(UserModel user) {
    final data = colis
        .where((p) => p.expeditorId == user.id && sameWeek(p.deliveryDate));
    int delivered = 0;
    double deliveredPrice = 0;
    int canceled = 0;
    for (var c in data) {
      if ([ColisStatus.delivered.name, ColisStatus.closed.name]
          .contains(c.status)) {
        delivered += 1;
        deliveredPrice += c.price - user.price;
      }
      if ([ColisStatus.returnConfirmed.name, ColisStatus.closedReturn.name]
          .contains(c.status)) {
        canceled += 1;
      }
    }
    return {
      "delivered": {"count": delivered, "price": deliveredPrice},
      "canceled": {"count": canceled, "price": canceled * user.returnPrice}
    };
  }

  Map<String, dynamic> colisDay(UserModel user) {
    final data = manifests
        .where((m) => m.expeditorId == user.id && sameWeek(m.dateCreated))
        .toList();
    Map<String, dynamic> weekData = {};
    for (var manifest in data) {
      if (weekData.keys.contains(getDate(manifest.dateCreated))) {
        weekData[getDate(manifest.dateCreated)] += manifest.colis.length;
        continue;
      }
      weekData[getDate(manifest.dateCreated)] = manifest.colis.length;
    }
    return {};
  }

  List<Map<String, dynamic>> ratringClients(UserModel user) {
    final data = colis
        .where((m) =>
            m.expeditorId == user.id &&
            [ColisStatus.closed.name, ColisStatus.closedReturn.name]
                .contains(m.status))
        .toList();
    Map<String, Map<String, dynamic>> bestUsers = {};
    for (var c in data) {
      if (bestUsers.keys.contains(c.clientId)) {
        bestUsers[c.clientId]!['delivered'] +=
            c.status == ColisStatus.closed.name ? 1 : 0;
        bestUsers[c.clientId]!['delivered'] -=
            c.status == ColisStatus.closedReturn.name ? 1 : 0;
        bestUsers[c.clientId]!['delivered'] +=
            (c.status == ColisStatus.closed.name ? 1 : 0) -
                (c.status == ColisStatus.closedReturn.name ? 1 : 0);
      } else {
        bestUsers[c.clientId] = {
          "name": c.name,
          "id": c.clientId,
          "delivered": c.status == ColisStatus.closed.name ? 1 : 0,
          "canceled": c.status == ColisStatus.closedReturn.name ? 1 : 0,
          "count": (c.status == ColisStatus.closed.name ? 1 : 0) -
              (c.status == ColisStatus.closedReturn.name ? 1 : 0),
        };
      }
    }
    List<Map<String, dynamic>> users = bestUsers.values.toList();
    users.sort((a, b) => (a['count'] as int).compareTo((b['count'] as int)));
    return users;
  }

  // admin extra
  // List<Map<String, dynamic>> ratringColis(UserModel user) {
  //   final data = colis
  //       .where((m) =>
  //           m.expeditorId == user.id &&
  //           [ColisStatus.closed.name, ColisStatus.closedReturn.name]
  //               .contains(m.status))
  //       .toList();
  //   Map<String, Map<String, dynamic>> bestUsers = {};
  //   for (var c in data) {
  //     if (bestUsers.keys.contains(c.clientId)) {
  //     } else {}
  //   }
  //   List<Map<String, dynamic>> users = bestUsers.values.toList();
  //   users.sort((a, b) => (a['count'] as int).compareTo((b['count'] as int)));
  //   return users;
  // }

  List<Map<String, dynamic>> ratringDelivery(UserModel user) {
    final data = colis
        .where((c) => c.deliveryDate != null && sameWeek(c.deliveryDate))
        .where((m) => [
              ColisStatus.delivered.name,
              ColisStatus.closed.name,
              ColisStatus.closedReturn.name,
              ColisStatus.returnConfirmed.name
            ].contains(m.status))
        .toList();
    Map<String, Map<String, dynamic>> lstExpeditor = {};
    Map<String, Map<String, dynamic>> lstAgency = {};
    Map<String, Map<String, dynamic>> lstSector = {};
    Map<String, Map<String, dynamic>> lstColis = {};
    for (var c in data) {
      if ([
        ColisStatus.delivered.name,
        ColisStatus.closed.name,
      ].contains(c.status)) {
        

      } else {}
    }
    // List<Map<String, dynamic>> users = bestUsers.values.toList();
    // users.sort((a, b) => (a['count'] as int).compareTo((b['count'] as int)));
    return [lstColis, lstExpeditor, lstSector, lstAgency];
  }
}