import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/expeditor_payment.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/payment_service.dart';
import 'package:jetpack/services/pdf_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/colis/colis_details.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';

class ExpeditorTrackingScreen extends StatefulWidget {
  final UserModel user;
  const ExpeditorTrackingScreen({super.key, required this.user});

  @override
  State<ExpeditorTrackingScreen> createState() =>
      _ExpeditorTrackingScreenState();
}

class _ExpeditorTrackingScreenState extends State<ExpeditorTrackingScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> function;

  @override
  void initState() {
    super.initState();
    function = PaymentService.expeditorPaimentCollection
        .where('expeditorId', isEqualTo: widget.user.id)
        .snapshots();
  }

  bool payment = true;
  List<Colis> selected = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Expeditor tracking'),
      backgroundColor: context.bgcolor,
      body: SizedBox(
        width: context.w,
        height: context.h,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                gradientButton(
                    function: () => setState(() => payment = true),
                    text: "Payment list"),
                gradientButton(
                    function: () => setState(() => payment = false),
                    text: "Colis list"),
              ],
            ),
            payment
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          StreamBuilder(
                              stream: function,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.active &&
                                    snapshot.data != null) {
                                  return Column(
                                    children: [
                                      ...snapshot.data!.docs.reversed
                                          .map((e) => ExpeditorPayment.fromMap(
                                              e.data()))
                                          .map(
                                              (payment) => paymentCard(payment))
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              })
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  const Gap(10),
                                  if (context.role == Role.admin)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                            onPressed: () => setState(
                                                () => selected.clear()),
                                            child: Txt("Clear",
                                                color: context.primaryColor)),
                                        TextButton(
                                            onPressed: () => setState(() {
                                                  selected.clear();
                                                  selected.addAll(context
                                                      .adminRead.allColis
                                                      .where((c) =>
                                                          c.expeditorId ==
                                                          widget.user.id)
                                                      .where((c) => [
                                                            ColisStatus
                                                                .delivered.name,
                                                            ColisStatus
                                                                .returnConfirmed
                                                                .name
                                                          ].contains(
                                                              c.status)));
                                                }),
                                            child: Txt("Select All",
                                                color: context.primaryColor)),
                                      ],
                                    ),
                                  ...filterColis((context.role == Role.expeditor
                                              ? context.expeditorWatch.allColis
                                              : context.adminWatch.allColis)
                                          .where((c) =>
                                              c.expeditorId == widget.user.id)
                                          .toList())
                                      .map((colis) => Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(child: colisCard(colis)),
                                              if ([
                                                    ColisStatus.delivered.name,
                                                    ColisStatus
                                                        .returnConfirmed.name
                                                  ].contains(colis.status) &&
                                                  context.role == Role.admin)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5, left: 5),
                                                  child: Row(
                                                    children: [
                                                      // if ([
                                                      //   ColisStatus
                                                      //       .returnExpeditor
                                                      //       .name,
                                                      //   ColisStatus
                                                      //       .canceled.name
                                                      // ].contains(colis.status))
                                                      //   Icon(Icons.download,
                                                      //       color: context
                                                      //           .iconColor,
                                                      //       size: 25),
                                                      // const Gap(5),
                                                      checkBox(
                                                          selected
                                                              .map((e) => e.id)
                                                              .contains(
                                                                  colis.id),
                                                          '',
                                                          () => setState(() => selected
                                                                  .map((e) =>
                                                                      e.id)
                                                                  .contains(
                                                                      colis.id)
                                                              ? selected
                                                                  .removeWhere(
                                                                      (s) =>
                                                                          s.id ==
                                                                          colis
                                                                              .id)
                                                              : selected
                                                                  .add(colis))),
                                                    ],
                                                  ),
                                                )
                                            ],
                                          )),
                                  const Gap(40)
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (selected.isNotEmpty)
                          gradientButton(
                              function: () async {
                                await customPopup(
                                    context,
                                    ColisOptions(
                                        colis: selected,
                                        expeditor: widget.user),
                                    maxWidth: false);
                              },
                              text: "Option",
                              w: context.w - 20)
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  List<Colis> filterColis(List<Colis> colis) {
    List<Colis> delivered = [];
    List<Colis> canceled = [];
    List<Colis> closed = [];
    List<Colis> pickup = [];
    List<Colis> rest = [];

    for (var c in colis) {
      switch (c.status) {
        case "delivered":
          delivered.add(c);
          break;
        case "canceled":
          canceled.add(c);
          break;
        case "pickup":
          pickup.add(c);
          break;
        case "closed":
          closed.add(c);
          break;
        case "closedReturn":
          closed.add(c);
          break;
        default:
          rest.add(c);
      }
    }
    return [...delivered, ...canceled, ...rest, ...pickup];
  }

  Widget colisCard(Colis colis) => Card(
        elevation: 4,
        color: context.bgcolor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () =>
                          customPopup(context, ColisDetails(colis: colis)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Txt(colis.id,
                                bold: true, color: red, translate: false),
                            Txt(colis.name, bold: true, translate: false),
                            Txt('${colis.price}TND',
                                color: context.iconColor, translate: false),
                            if (colis.exchange)
                              Txt('EXCHANGE',
                                  color: context.iconColor, bold: true),
                            if (colis.address.isNotEmpty)
                              Txt(colis.address,
                                  color: context.iconColor, translate: false),
                          ]),
                    ),
                  ),
                  // phoneWidget(colis.phone1, 1),
                  // if (colis.phone2.isNotEmpty) phoneWidget(colis.phone2, 2),
                ],
              ),
              const Gap(10),
              SizedBox(
                child: Builder(builder: (context) {
                  Color color = getColor(colis.status);

                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                        height: 35,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: color.withOpacity(.2),
                          border: Border.all(color: color),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: Text(
                          txt(getText(colis.status)),
                          style: context.text.copyWith(
                            fontSize: 14,
                          ),
                        )),
                  );
                }),
              )
            ],
          ),
        ),
      );
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
                              Txt("Date",
                                  extra: ": ${getDate(payment.date)}",
                                  bold: true),
                              Txt('Total price',
                                  color: context.iconColor,
                                  extra: ": ${payment.totalprice}TND"),
                              Txt('Net price',
                                  color: context.iconColor,
                                  extra: ": ${payment.price}TND"),
                            ]),
                      ),
                    ),
                    // phoneWidget(colis.phone1, 1),
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

class ColisOptions extends StatefulWidget {
  final List<Colis> colis;
  final UserModel expeditor;
  const ColisOptions({super.key, required this.colis, required this.expeditor});

  @override
  State<ColisOptions> createState() => _ColisOptionsState();
}

class _ColisOptionsState extends State<ColisOptions> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          gradientButton(
              function: () async {
                if (loading) return;
                setState(() => loading = true);
                try {
                  await context.adminRead
                      .generateExpeditorPayment(widget.colis, widget.expeditor)
                      .then((value) => context.pop());

                  setState(() => loading = false);
                } on Exception catch (e) {
                  log(e.toString());
                  setState(() => loading = false);
                }
              },
              text: "Generate payment",
              w: 200),
          // gradientButton(
          //     function: () async {
          //       if (loading) return;
          //       setState(() => loading = true);
          //       try {
          //         for (var c in widget.colis) {
          //           await ColisService.colisCollection
          //               .doc(c.id)
          //               .update({'status': ColisStatus.ready.name});
          //         }
          //         setState(() => loading = false);
          //       } on Exception catch (e) {
          //         log(e.toString());
          //         setState(() => loading = false);
          //       }
          //     },
          //     text: "Ready for delivery",
          //     w: 200),
          if (loading) cLoader()
        ],
      ),
    );
  }
}
