import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/expeditor_payment.dart';
import 'package:jetpack/models/return_colis.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/payment_service.dart';
import 'package:jetpack/services/pdf_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/colis/colis_card.dart';
import 'package:jetpack/views/colis/colis_details.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';

class ConfirmedReturnScreen extends StatefulWidget {
  const ConfirmedReturnScreen({super.key});

  @override
  State<ConfirmedReturnScreen> createState() => _ConfirmedReturnScreenState();
}

class _ConfirmedReturnScreenState extends State<ConfirmedReturnScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> function;

  @override
  void initState() {
    super.initState();
    function =
        FirebaseFirestore.instance.collection('return colis').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(''),
      backgroundColor: context.bgcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: StreamBuilder(
              stream: function,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active &&
                    snapshot.data != null) {
                  return Column(
                    children: [
                      const Gap(20),
                      ...snapshot.data!.docs.reversed
                          .map((e) => ReturnColis.fromMap(e.data()))
                          .map((invoice) => paymentCard(invoice))
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
        ),
      ),
    );
  }

  Widget paymentCard(ReturnColis invoice) => Builder(builder: (context) {
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
                                children: invoice.colis
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
                              Txt(invoice.expeditorName, bold: true),
                              Txt("Date: ${getDate(invoice.date)}", bold: true),
                              Txt('', color: context.iconColor, extra: ""),
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
                        onTap: () => PdfService.generateReturnColis(invoice),
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
                            invoice.isClosed ? Colors.green : Colors.red;
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
                              txt(invoice.isClosed ? "Recived" : "Not recived"),
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
