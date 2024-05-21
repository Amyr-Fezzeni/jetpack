import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/delivery_paiment.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/expeditor_payment.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/payment_service.dart';
import 'package:jetpack/services/pdf_service.dart';
import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/colis/colis_details.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/popup.dart';

class AdminTrackingScreen extends StatefulWidget {
  const AdminTrackingScreen({super.key});

  @override
  State<AdminTrackingScreen> createState() => _AdminTrackingScreenState();
}

class _AdminTrackingScreenState extends State<AdminTrackingScreen> {
  late final Future<Map<String, dynamic>> function;

  @override
  void initState() {
    super.initState();
    function = PaymentService.getAllPayments();
  }

  bool payment = true;
  List<Colis> selected = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Payment tracking'),
      backgroundColor: context.bgcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: FutureBuilder<Map<String, dynamic>>(
              future: function,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return Column(
                    children: [
                      const Gap(20),
                      ...snapshot.data!['delivery']
                          .map((payment) => userPaymentCard(payment)),
                      ...snapshot.data!['expeditor']
                          .map((payment) => paymentCard(payment)),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
        ),
      ),
    );
  }

  Widget paymentCard(ExpeditorPayment payment) => Builder(builder: (context) {
        return Card(
          color: context.bgcolor,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => customPopup(
                            context,
                            Flexible(
                                child: SingleChildScrollView(
                              child: Column(
                                children: (context.role == Role.expeditor
                                        ? context.expeditorRead.allColis
                                        : context.adminRead.allColis)
                                    .where((c) => payment.colis.contains(c.id))
                                    .map((colis) => Card(
                                          color: context.theme.bgColor,
                                          child: Card(
                                            elevation: 0,
                                            color: colis.status ==
                                                    ColisStatus.closed.name
                                                ? Colors.green.withOpacity(.2)
                                                : Colors.red.withOpacity(.2),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () =>
                                                              customPopup(
                                                                  context,
                                                                  ColisDetails(
                                                                      colis:
                                                                          colis)),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(colis.id,
                                                                    style: context
                                                                        .theme
                                                                        .text18
                                                                        .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    )),
                                                                Text(colis.name,
                                                                    style: context
                                                                        .theme
                                                                        .text18
                                                                        .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    )),
                                                                Text(
                                                                    '${colis.price}TND',
                                                                    style: context
                                                                        .theme
                                                                        .text18),
                                                                if (colis
                                                                    .exchange)
                                                                  Text(
                                                                      'EXCHANGE',
                                                                      style: context
                                                                          .theme
                                                                          .text18),
                                                                if (colis
                                                                    .address
                                                                    .isNotEmpty)
                                                                  Text(
                                                                      colis
                                                                          .address,
                                                                      style: context
                                                                          .theme
                                                                          .text18),
                                                              ]),
                                                        ),
                                                      ),
                                                      // phoneWidget(colis.phone1, 1),
                                                      // if (colis.phone2.isNotEmpty) phoneWidget(colis.phone2, 2),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            )),
                            maxWidth: false),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Txt(payment.expeditorName,
                                  bold: true, translate: false),
                              Txt("Date: ${getDate(payment.date)}", bold: true),
                              Txt('Total price',
                                  color: context.iconColor,
                                  extra: ": ${payment.totalprice}TND"),
                              Txt('Net price',
                                  color: context.iconColor,
                                  extra: ": ${payment.price}TND"),
                            ]),
                      ),
                    ),
                    // Builder(
                    //   builder: (context) {
                    //     final delivery =
                    //     return phoneWidget(payment., 1);
                    //   }
                    // ),
                    // if (colis.phone2.isNotEmpty) phoneWidget(colis.phone2, 2),
                  ],
                ),
                SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => PdfService.generateExpeditorPayment(
                            payment,
                            (context.role == Role.expeditor
                                    ? context.expeditorRead.allColis
                                    : context.adminRead.allColis)
                                .where((c) => payment.colis.contains(c.id))
                                .toList()),
                        child: Container(
                          height: 35,
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: context.invertedColor.withOpacity(.2)),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Txt("Download"),
                              const Gap(5),
                              Icon(Icons.download,
                                  color: context.iconColor, size: 20)
                            ],
                          ),
                        ),
                      ),
                      const Gap(20),
                      Builder(builder: (context) {
                        Color color =
                            payment.recived ? Colors.green : Colors.red;
                        log(DateTime.now().millisecondsSinceEpoch.toString());
                        return Container(
                            height: 35,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: color.withOpacity(.2),
                              border: Border.all(color: color),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Text(
                              txt(payment.recived ? "Recived" : "Not recived"),
                              style: context.text.copyWith(
                                fontSize: 14,
                              ),
                            ));
                      }),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      });
}

Widget userPaymentCard(DeliveryPayment payment) => FutureBuilder<UserModel?>(
    future: UserService.getUserById(payment.userId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.data != null) {
        UserModel user = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: Card(
              elevation: 0,
              color: payment.isPaid
                  ? Colors.green.withOpacity(.25)
                  : Colors.red.withOpacity(.15),
              surfaceTintColor: payment.isPaid ? Colors.green : Colors.red,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                width: double.maxFinite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        profileIcon(url: user.photo),
                        const Gap(10),
                        Txt(user.getFullName(), bold: true)
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (DateTime.now().isBefore(payment.endTime))
                              Txt("Current Week", bold: true),
                            Txt("${txt('From')} ${getSimpleDate(payment.startTime)} ${txt('to')} ${getSimpleDate(payment.endTime)} ",
                                bold: true, translate: false),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                    Txt("Colis delivered", extra: ": ${payment.nbDelivered}"),
                    Txt("Manifest picked", extra: ": ${payment.nbPickup}"),
                    Txt("${(payment.nbDelivered * user.price + payment.nbPickup * 1).toStringAsFixed(2)} TND",
                        color: payment.isPaid ? Colors.green : Colors.red,
                        bold: true,
                        translate: false),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Builder(builder: (context) {
                          late final Color color;

                          switch (payment.isPaid) {
                            case true:
                              color = Colors.green;
                              break;
                            case false:
                              color = Colors.red;
                              break;
                            default:
                              color = context.theme.invertedColor;
                          }

                          return PopupMenuButton(
                            onSelected: (value) {},
                            color: context.bgcolor,
                            child: Container(
                                // width: 120,
                                height: 35,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(.2),
                                  border: Border.all(color: color),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5.0) //
                                      ),
                                ),
                                child: Center(
                                  child: Text(
                                    txt(payment.isPaid ? "Paid" : "Not paid"),
                                    style: context.text
                                        .copyWith(fontSize: 14, color: color),
                                  ),
                                )),
                            itemBuilder: (BuildContext c) {
                              return [true, false].map((bool status) {
                                switch (status) {
                                  case true:
                                    return PopupMenuItem(
                                      onTap: () async {
                                        if (payment.isPaid == status) return;
                                        await PaymentService
                                            .deliveryPaimentCollection
                                            .doc(payment.id)
                                            .update({'isPaid': status});
                                      },
                                      value: 'Paid',
                                      child: Row(
                                        // mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check,
                                              color: Colors.green, size: 25),
                                          const Gap(10),
                                          Text(
                                            txt("Paid"),
                                            style: context.theme.text18,
                                          ),
                                        ],
                                      ),
                                    );

                                  default:
                                    return PopupMenuItem(
                                      onTap: () async {
                                        if (payment.isPaid == status) return;
                                        await PaymentService
                                            .deliveryPaimentCollection
                                            .doc(payment.id)
                                            .update({'isPaid': status});
                                      },
                                      value: 'Not paid',
                                      child: Row(
                                        // mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.close,
                                              color: Colors.red, size: 25),
                                          const Gap(10),
                                          Text(
                                            txt("Not paid"),
                                            style: context.theme.text18,
                                          ),
                                        ],
                                      ),
                                    );
                                }
                              }).toList();
                            },
                          );
                        }))
                  ],
                ),
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
