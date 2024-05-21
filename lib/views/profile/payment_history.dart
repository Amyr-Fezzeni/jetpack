import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/models/delivery_paiment.dart';
import 'package:jetpack/services/payment_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/widgets/loader.dart';

class PaymentHistoryWidget extends StatefulWidget {
  const PaymentHistoryWidget({super.key});

  @override
  State<PaymentHistoryWidget> createState() => _PaymentHistoryWidgetState();
}

class _PaymentHistoryWidgetState extends State<PaymentHistoryWidget> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> function;

  @override
  void initState() {
    super.initState();
    log(context.userId);
    function = PaymentService.deliveryPaimentCollection
        .where('userId', isEqualTo: context.userId)
        // .where('isPaid', isEqualTo: false)
        .snapshots();
    PaymentService.deliveryPaimentCollection
        .where('userId', isEqualTo: context.userId)
        .where('endTime', isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        // .where('isPaid', isEqualTo: false)
        .get()
        .then((data) {
      if (data.docs.isEmpty) {
        final p = DeliveryPayment(
            id: generateId(),
            userId: context.userId,
            isPaid: false,
            nbDelivered: 0,
            nbPickup: 0,
            startTime: getFirstDayOfWeek(DateTime.now()),
            endTime:
                getLastDayOfWeek(DateTime.now()).add(const Duration(days: 7)));
        PaymentService.deliveryPaimentCollection.doc(p.id).set(p.toMap());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: function,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.data != null) {
            final docs = snapshot.data!.docs;
            log(docs.length.toString());

            return Column(
              children: [
                pngIcon(payoutIcon, size: 100, color: null),
                const Gap(20),
                for (var doc in docs.reversed)
                  Builder(builder: (context) {
                    late DeliveryPayment payment;
                    payment = DeliveryPayment.fromMap(doc.data());
                    bool currentWeek = DateTime.now().isBefore(payment.endTime);
                    return Card(
                      child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.all(0),
                        color: payment.isPaid
                            ? Colors.green.withOpacity(.25)
                            : Colors.red.withOpacity(.15),
                        surfaceTintColor:
                            payment.isPaid ? Colors.green : Colors.red,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          width: double.maxFinite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (currentWeek)
                                        Txt("Current Week",
                                            bold: true, color: Colors.black),
                                      Txt("${txt('From')} ${getSimpleDate(payment.startTime)} ${txt('to')} ${getSimpleDate(payment.endTime)} ",
                                          bold: true,
                                          translate: false,
                                          color: Colors.black),
                                    ],
                                  ),
                                  const Spacer(),
                                  Icon(
                                    payment.isPaid ? Icons.check : Icons.close,
                                    color: payment.isPaid
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  // Txt(payment.isPaid ? "Paid" : "Not paid",
                                  //     color: payment.isPaid
                                  //         ? Colors.green
                                  //         : Colors.red,
                                  //     bold: true),
                                ],
                              ),

                              Txt("Colis delivered",
                                  extra: ": ${payment.nbDelivered}",
                                  color: Colors.black),
                              Txt("Manifest picked",
                                  extra: ": ${payment.nbPickup}",
                                  color: Colors.black),
                              Txt(
                                "${(payment.nbDelivered * context.currentUser.price + payment.nbPickup * 1).toStringAsFixed(2)} TND",
                                color:
                                    payment.isPaid ? Colors.green : Colors.red,
                                bold: true,
                                translate: false,
                              ),

                              // divider(bottom: 10, top: 10)
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          }

          return const SizedBox.shrink();
        });
  }
}
