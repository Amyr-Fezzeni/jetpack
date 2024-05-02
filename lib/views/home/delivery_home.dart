// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/runsheet.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/payment_service.dart';
import 'package:jetpack/services/pdf_service.dart';
import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/colis/colis_card.dart';
import 'package:jetpack/views/colis/colis_details.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/buttom_navigation_bar.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/nav_panel_customer.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:jetpack/views/widgets/text_field.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DeliveryHomeScreen> {
  String currentFilter = "Runsheet";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: const NavPanel(),
      backgroundColor: context.bgcolor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.primaryColor,
        onPressed: () async {
          TextEditingController controller = TextEditingController();
          customPopup(
              context,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: CustomTextField(
                                marginH: 0,
                                marginV: 0,
                                hint: 'Code',
                                controller: controller)),
                        const Gap(5),
                        gradientButton(
                            function: () {
                              final code = controller.text;
                              if (code.trim().isEmpty) return;
                              switch (currentFilter) {
                                case "Runsheet":
                                  context.deliveryRead.scanRunsheet(code);
                                  break;
                                case "Paiement":
                                  break;
                                case "Retour":
                                  break;
                                default:
                                  context.deliveryRead.scanManifest(code);
                                  break;
                              }
                              context.pop();
                            },
                            text: "Confirm")
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: divider()),
                        Text(
                          'Or',
                          style: context.theme.text18,
                        ),
                        Expanded(child: divider())
                      ],
                    ),
                    gradientButton(
                        w: double.maxFinite,
                        function: () async {
                          final code = await scanQrcode();
                          if (code == null) return;
                          switch (currentFilter) {
                            case "Runsheet":
                              context.deliveryRead.scanRunsheet(code);
                              break;
                            case "Paiement":
                              break;
                            case "Retour":
                              break;
                            default:
                              context.deliveryRead.scanManifest(code);
                          }
                          context.pop();
                        },
                        text: "Scan code")
                  ],
                ),
              ),
              maxWidth: false);
        },
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 25,
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: SingleChildScrollView(
        // physics: const NeverScrollableScrollPhysics(),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const Gap(40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Builder(builder: (context) {
                      return InkWell(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Icon(
                          Icons.menu,
                          color: context.invertedColor.withOpacity(.7),
                          size: 30,
                        ),
                      );
                    }),
                    const Gap(10),
                    logoWidget(size: 100),
                    const Spacer(),
                    profileIcon()
                  ],
                ),
                const Gap(20),
                Row(
                  children: [
                    Expanded(
                        child: CustomTextField(
                            hint: txt('Search'),
                            controller: TextEditingController(),
                            leadingIcon: Icon(Icons.search,
                                color: context.invertedColor.withOpacity(.7),
                                size: 25),
                            marginH: 0,
                            marginV: 0)),
                    const Gap(10),
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          boxShadow: defaultShadow,
                          borderRadius: BorderRadius.circular(smallRadius),
                          color: context.bgcolor),
                      child: Container(
                          height: 45,
                          width: 45,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(smallRadius),
                              color: context.invertedColor.withOpacity(.1)),
                          child: svgImage(filter, size: 25, function: () {
                            context.showPopUpScreen(DraggableScrollableSheet(
                              initialChildSize: .5,
                              builder: (context, scrollController) => Container(
                                height: 200,
                                color: context.bgcolor,
                                child: const Center(),
                              ),
                            ));
                          })),
                    )
                  ],
                ),
                const Gap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...[
                      'Runsheet',
                      'Paiement',
                      'Retour',
                      'Pickup',
                    ].map((title) => Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: InkWell(
                            onTap: () => setState(() {
                              currentFilter = title;
                            }),
                            child: Txt(title,
                                color: title == currentFilter
                                    ? context.primaryColor
                                    : null),
                          ),
                        ))
                  ],
                ),
                divider(),
                const Gap(10),
                Builder(builder: (context) {
                  {
                    switch (currentFilter) {
                      case "Runsheet":
                        return runsheetWidget();
                      case "Paiement":
                        return paimentWidget();
                      case "Retour":
                        return returnWidget();
                      case "Pickup":
                        return pickupWidget();

                      default:
                        return const SizedBox.shrink();
                    }
                  }
                }),
                const Gap(100)
              ],
            )),
      ),
    );
  }

  Widget runsheetWidget() {
    return Column(
      children: [
        if (context.deliveryWatch.depot.isNotEmpty)
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(smallRadius),
                  border:
                      Border.all(color: context.invertedColor.withOpacity(.2))),
              child: Center(
                child: Txt(
                    "you have ${context.deliveryWatch.depot.length} colis at depot"),
              )),
        Column(
          children: context.deliveryWatch.depot
              .map((colis) => Card(
                    color: context.bgcolor,
                    child: ListTile(
                      title: Txt(colis.name, bold: true),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Txt(colis.id,
                              size: 10,
                              color: context.primaryColor,
                              bold: true),
                          if (colis.appointmentDate != null) ...[
                            Txt('Appointment',
                                extra: ": ${getDate(colis.appointmentDate)}")
                          ]
                        ],
                      ),
                      trailing: InkWell(
                        onTap: () =>
                            customPopup(context, ColisDetails(colis: colis)),
                        child: Icon(Icons.edit_document,
                            color: context.iconColor, size: 35),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const Gap(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            borderButton(
                text: 'End of day report',
                textColor: context.invertedColor.withOpacity(.6),
                color: context.invertedColor.withOpacity(.2),
                trailing: Icon(
                  Icons.download,
                  color: context.invertedColor.withOpacity(.6),
                  size: 20,
                ),
                function: () {
                  if (context.deliveryRead.runsheetData == null) return;
                  context.deliveryRead.generateDayReport();
                }),
            borderButton(
                text: 'Generate runsheet',
                textColor: context.primaryColor,
                opacity: 0.1,
                trailing: Icon(
                  Icons.download,
                  color: context.primaryColor,
                  size: 20,
                ),
                function: () {
                  if (context.deliveryRead.runsheetData == null) return;
                  final r = context.deliveryRead.runsheetData!;
                  PdfService.generateRunsheet(RunsheetPdf(
                      id: r.id,
                      agenceName:
                          context.userprovider.currentUser!.agency!['name'],
                      deliveryCin: context.userprovider.currentUser!.cin,
                      deliveryName:
                          context.userprovider.currentUser!.getFullName(),
                      matricule: context.userprovider.currentUser!.matricule,
                      date: r.date,
                      colis: context.deliveryRead.runsheet,
                      price: r.price,
                      note: r.note));
                }),
          ],
        ),
        const Gap(10),
        if (context.deliveryWatch.runsheetData != null)
          SizedBox(
            height: context.h,
            child: ReorderableListView(
                children: context.deliveryWatch.runsheetData!.colis
                    .map((id) => colisRunsheetCard(id))
                    .toList(),
                onReorder: (oldIndex, newIndex) => context.deliveryRead
                    .updateOrderRunsheet(oldIndex, newIndex)),
          ),
      ],
    );
  }

  Widget paimentWidget() {
    return Column(
      children: [
        if (context.deliveryWatch.payments.isNotEmpty)
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(smallRadius),
                  border:
                      Border.all(color: context.invertedColor.withOpacity(.2))),
              child: Center(
                child: Txt(
                    "you have ${context.deliveryWatch.payments.length} payment to pickup"),
              )),
        Column(
          children: context.deliveryWatch.payments
              .map((payment) => Card(
                    color: context.bgcolor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Txt(payment.expeditorName, bold: true),
                                    Txt([payment.region, payment.adress]
                                        .join(', ')),
                                    Txt('Total price',
                                        color: context.iconColor,
                                        extra: ": ${payment.totalprice}TND"),
                                    Txt('Net price',
                                        color: context.iconColor,
                                        extra: ": ${payment.price}TND"),
                                    Txt(getDate(payment.date)),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    phoneWidget(payment.expeditorPhoneNumber, 1,
                                        size: 35),
                                    const Gap(10),
                                    InkWell(
                                      onTap: () async {
                                        PdfService.generateExpeditorPayment(
                                            payment,
                                            await ColisService.getColis(
                                                payment.colis));
                                      },
                                      child: Icon(Icons.picture_as_pdf_rounded,
                                          color:
                                              context.iconColor.withOpacity(.6),
                                          size: 35),
                                    ),
                                  ])
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 5, bottom: 5),
                          child: borderButton(
                              text: "Done",
                              textColor: context.primaryColor,
                              function: () async {
                                popup(context,
                                    description:
                                        'Are you sure you want to close this payment?',
                                    confirmFunction: () {
                                  PaymentService.expeditorPaimentCollection
                                      .doc(payment.id)
                                      .update({'recived': true});
                                });
                              },
                              radius: smallRadius,
                              opacity: .5),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget returnWidget() {
    return Column(
      children: [
        if (context.deliveryWatch.returnExpeditor.isNotEmpty)
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(smallRadius),
                  border:
                      Border.all(color: context.invertedColor.withOpacity(.2))),
              child: Center(
                child: Txt(
                    "you have ${context.deliveryWatch.returnExpeditor.length} colis return to pickup"),
              )),
        Column(
          children: context.deliveryWatch.returnExpeditor
              .map((colis) => FutureBuilder(
                  future: UserService.getUserById(colis.expeditorId),
                  builder: (context, snapshot) {
                    return snapshot.connectionState == ConnectionState.done &&
                            snapshot.data != null
                        ? Builder(builder: (context) {
                            UserModel user = snapshot.data!;
                            return Card(
                              color: context.bgcolor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Txt(user.getFullName(),
                                                  bold: true),
                                              SizedBox(
                                                width: context.w * .6,
                                                child: Txt([
                                                  user.governorate,
                                                  user.region,
                                                  user.adress
                                                ].join(', ')),
                                              ),
                                              Txt("${colis.price.toStringAsFixed(2)} Dt",
                                                  size: 10,
                                                  color: context.iconColor),
                                            ]),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () => customPopup(
                                                    context,
                                                    ColisDetails(colis: colis)),
                                                child: Icon(Icons.notes_rounded,
                                                    color: context.iconColor,
                                                    size: 35),
                                              ),
                                              const Gap(10),
                                              phoneWidget(user.phoneNumber, 1,
                                                  size: 35),
                                            ])
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 5, bottom: 5),
                                    child: borderButton(
                                        text: "Done",
                                        textColor: context.primaryColor,
                                        function: () async {
                                          popup(context,
                                              description:
                                                  'Are you sure you want to close this colis?',
                                              confirmFunction: () {
                                            ColisService.colisCollection
                                                .doc(colis.id)
                                                .update({
                                              'status':
                                                  ColisStatus.closedReturn.name
                                            });
                                          });
                                        },
                                        radius: smallRadius,
                                        opacity: .5),
                                  ),
                                ],
                              ),
                            );
                          })
                        : const SizedBox.shrink();
                  }))
              .toList(),
        ),
      ],
    );
  }

  Widget pickupWidget() {
    return Column(
      children: [
        if (context.deliveryWatch.pickup.isNotEmpty)
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(smallRadius),
                  border:
                      Border.all(color: context.invertedColor.withOpacity(.2))),
              child: Center(
                child: Txt(
                    "you have ${context.deliveryWatch.pickup.length} manifest to pickup"),
              )),
        Column(
          children: context.deliveryWatch.pickup
              .map((manifest) => Card(
                    color: context.bgcolor,
                    child: ListTile(
                      title: Txt(manifest.expeditorName, bold: true),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Txt(manifest.id,
                              translate: false,
                              size: 10,
                              color: context.primaryColor),
                          Txt("${manifest.colis.length} colis",
                              size: 10, translate: false, bold: true),
                        ],
                      ),
                      trailing: SizedBox(
                        height: 60,
                        width: 60,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                final data = ClipboardData(text: manifest.id);
                                Clipboard.setData(data);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Code copied."),
                                ));
                              },
                              child: Icon(Icons.copy,
                                  color: context.iconColor, size: 25),
                            ),
                            Center(
                                child: phoneWidget(manifest.phoneNumber, 1,
                                    size: 25))
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
//  onTap: () => PdfService.generateColis(colis),

