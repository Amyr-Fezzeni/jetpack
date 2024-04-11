// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/colis/colis_card.dart';
import 'package:jetpack/views/colis/colis_details.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:jetpack/views/widgets/text_field.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DeliveryHomeScreen> {
  String currentFilter = "Runsheet";
  late final Stream<QuerySnapshot<Map<String, dynamic>>> colisFunction;

  @override
  void initState() {
    super.initState();
    colisFunction = FirebaseFirestore.instance
        .collection('colis')
        .where('status', isEqualTo: ColisStatus.depot.name)
        .where('deliveryId', isEqualTo: context.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const Gap(40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Icon(
                        Icons.menu,
                        color: context.invertedColor.withOpacity(.7),
                        size: 30,
                      ),
                    ),
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
                        return runsheetCard();
                      case "Paiement":
                        return paimentCard();
                      case "Retour":
                        return returnCard();
                      case "Pickup":
                        return pickupWidget();

                      default:
                        return const SizedBox.shrink();
                    }
                  }
                })
              ],
            )),
      ),
    );
  }

  Widget runsheetCard() {
    return Card(
      color: context.bgcolor,
      child: InkWell(
        onTap: () => context.showPopUpScreen(DraggableScrollableSheet(
            initialChildSize: 1,
            builder: (context, scroll) => SingleChildScrollView(
                  controller: scroll,
                  child: Container(
                    color: context.bgcolor,
                    height: 600,
                    width: context.w,
                  ),
                ))),
        child: ListTile(
          title: Txt("name"),
          subtitle: Txt("description", size: 10, color: context.iconColor),
          leading: profileIcon(),
          trailing: InkWell(
            onTap: () => {launchUrl(Uri(scheme: 'tel', path: '50100100'))},
            child: const Icon(Icons.phone, color: Colors.green, size: 25),
          ),
        ),
      ),
    );
  }

  Widget paimentCard() {
    return Card(
      color: context.bgcolor,
      child: InkWell(
        onTap: () => context.showPopUpScreen(DraggableScrollableSheet(
            initialChildSize: .5,
            builder: (context, scroll) => Container(
                  color: context.bgcolor,
                ))),
        child: ListTile(
          title: Txt(""),
          subtitle: Txt("", size: 10, color: context.iconColor),
        ),
      ),
    );
  }

  Widget returnCard() {
    return Card(
      color: context.bgcolor,
      child: InkWell(
        onTap: () => context.showPopUpScreen(DraggableScrollableSheet(
            initialChildSize: .5,
            builder: (context, scroll) => Container(
                  color: context.bgcolor,
                ))),
        child: ListTile(
          title: Txt(""),
          subtitle: Txt("", size: 10, color: context.iconColor),
        ),
      ),
    );
  }

  Widget pickupWidget() {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () async {
              String? barcode = await scanQrcode();
              log(barcode.toString());

              popup(context, "Ok",
                  description: barcode.toString(), cancel: false);
            },
            child: Container(
              height: 45,
              width: 45,
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                  boxShadow: defaultShadow,
                  borderRadius: BorderRadius.circular(smallRadius),
                  color: context.bgcolor),
              child: Icon(Icons.qr_code_scanner_rounded,
                  color: context.primaryColor, size: 35),
            ),
          ),
        ),
        StreamBuilder(
            stream: colisFunction,
            builder: (context, data) {
              if (data.connectionState == ConnectionState.active &&
                  data.data != null) {
                return Column(
                  children: data.data!.docs
                      .map((e) => Colis.fromMap(e.data()))
                      .map((colis) => Card(
                            color: context.bgcolor,
                            child: ListTile(
                              title: Txt(colis.name, bold: true),
                              subtitle: Txt(colis.id,
                                  size: 10,
                                  color: context.primaryColor,
                                  bold: true),
                              trailing: InkWell(
                                onTap: () => customPopup(
                                    context,
                                    ColisDetails(
                                      colis: colis,
                                    )),
                                child: Icon(Icons.edit_document,
                                    color: context.iconColor, size: 35),
                              ),
                            ),
                          ))
                      .toList(),
                );
              }
              return const SizedBox.shrink();
            }),
        const Gap(10),
      ],
    );
  }
}
