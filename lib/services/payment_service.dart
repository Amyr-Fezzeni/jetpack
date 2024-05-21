import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jetpack/models/delivery_paiment.dart';
import 'package:jetpack/models/expeditor_payment.dart';
import 'package:jetpack/services/util/language.dart';

class PaymentService {
  static CollectionReference<Map<String, dynamic>> deliveryPaimentCollection =
      FirebaseFirestore.instance.collection('deliveryPaiment');
  static Future<String> addDeliveryPaiment(DeliveryPayment payment) async {
    try {
      await deliveryPaimentCollection.doc(payment.id).set(payment.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }

  static CollectionReference<Map<String, dynamic>> expeditorPaimentCollection =
      FirebaseFirestore.instance.collection('expeditor payment');
  static Future<String> addExpeditorPaiment(ExpeditorPayment payment) async {
    try {
      await expeditorPaimentCollection.doc(payment.id).set(payment.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }

  static Future<Map<String, dynamic>> getAllPayments() async {
    final expeditor = (await expeditorPaimentCollection.get())
        .docs
        .map((e) => ExpeditorPayment.fromMap(e.data()))
        .where((p) => !p.recived)
        .toList();

    final delivery = (await deliveryPaimentCollection.get())
        .docs
        .map((e) => DeliveryPayment.fromMap(e.data()))
        .where((p) => !p.isPaid)
        .toList();
    // expeditor.sort((a, b) => !a.recived ? 1 : -1);
    log(expeditor.length.toString());
    log(delivery.length.toString());
    return {"expeditor": expeditor, "delivery": delivery};
  }
}
