import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/relaunch_colis.dart';
import 'package:jetpack/models/report.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/pdf_service.dart';
import 'package:jetpack/services/services.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/colis/colis_card.dart';
import 'package:jetpack/views/colis/colis_details.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';

class ReturnColisExpeditor extends StatefulWidget {
  const ReturnColisExpeditor({super.key});

  @override
  State<ReturnColisExpeditor> createState() => _ReturnColisExpeditorState();
}

class _ReturnColisExpeditorState extends State<ReturnColisExpeditor> {
  List<String> selected = [];
  List<Colis> colis = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    colis = context.expeditorWatch.allColis
        .where((c) => [
              ColisStatus.canceled.name,
              ColisStatus.returnConfirmed.name,
              ColisStatus.returnExpeditor.name
            ].contains(c.status))
        .toList();
    for (var c in selected.map((e) => e).toList()) {
      if (!colis.map((e) => e.id).contains(c)) selected.remove(c);
    }
    return Scaffold(
      appBar: appBar("Return colis"),
      backgroundColor: context.bgcolor,
      body: SizedBox(
        width: context.w,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: colis
                          .map((colis) => Row(
                                children: [
                                  Flexible(
                                      child: Card(
                                    color: context.bgcolor,
                                    child: ListTile(
                                      onTap: () => customPopup(
                                          context, ColisDetails(colis: colis)),
                                      title: Txt(capitalize(colis.name),
                                          bold: true),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Txt(colis.id,
                                              size: 10,
                                              color: context.primaryColor,
                                              bold: true),
                                          Txt("${colis.price.toStringAsFixed(2)} Dt",
                                              size: 10,
                                              color: context.iconColor),
                                        ],
                                      ),
                                      trailing: InkWell(
                                        onTap: () => popup(context,
                                            confirmFunction: () async {
                                          RelaunchColis relaunch =
                                              RelaunchColis(
                                                  id: generateId(),
                                                  colisId: colis.id,
                                                  dateCreated: DateTime.now(),
                                                  expeditorId: context.userId,
                                                  agencyId:
                                                      context
                                                          .userprovider
                                                          .currentUser!
                                                          .agency?['id'],
                                                  expeditorPhone:
                                                      context
                                                          .userprovider
                                                          .currentUser!
                                                          .phoneNumber,
                                                  expeditorName:
                                                      context.userprovider
                                                          .currentUser!
                                                          .getFullName(),
                                                  status:
                                                      ReportStatus.review.name);
                                          RelaunchColisService.requestRelaunch(
                                              relaunch);

                                          Future.delayed(const Duration(
                                                  milliseconds: 800))
                                              .then((value) => popup(context,
                                                  cancel: false,
                                                  description:
                                                      'Request sent to the admin for review'));
                                        },
                                            confirmText: txt('Yes'),
                                            description:
                                                'Request for relaunch?'),
                                        child: Icon(Icons.replay,
                                            color: context.iconColor, size: 25),
                                      ),
                                    ),
                                  )),
                                  // const Gap(10),
                                  // if (colis.status ==
                                  //     ColisStatus.returnConfirmed.name)
                                  //   InkWell(
                                  //     onTap: () =>
                                  //         PdfService.generateReturnColis(colis),
                                  //     child: Icon(
                                  //       Icons.download,
                                  //       color: context.iconColor,
                                  //       size: 25,
                                  //     ),
                                  //   ),
                                ],
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const Gap(10),
              ],
            )),
      ),
    );
  }
}
