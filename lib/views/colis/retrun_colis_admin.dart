// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/return_colis.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/colis/colis_card.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';

class ReturnColisAdmin extends StatefulWidget {
  const ReturnColisAdmin({super.key});

  @override
  State<ReturnColisAdmin> createState() => _ReturnColisAdminState();
}

class _ReturnColisAdminState extends State<ReturnColisAdmin> {
  late Future<List<Colis>> function;
  List<String> selected = [];
  List<Colis> colis = [];
  @override
  void initState() {
    function = ColisService.getColisFromStatus(
        status: [ColisStatus.canceled.name, ColisStatus.returnConfirmed.name]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    colis = context.adminWatch.allColis
        .where((c) => [
              ColisStatus.canceled.name,
              ColisStatus.returnConfirmed.name
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => setState(() => selected.clear()),
                        child: Txt("Clear", color: context.primaryColor)),
                    TextButton(
                        onPressed: () => setState(
                            () => selected.addAll(colis.map((e) => e.id))),
                        child: Txt("Select All", color: context.primaryColor)),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: colis
                          .map((colis) => Row(
                                children: [
                                  Flexible(child: ColisCard(colis: colis)),
                                  const Gap(10),
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
                                  if (colis.status == ColisStatus.canceled.name)
                                    checkBox(
                                        selected.contains(colis.id),
                                        '',
                                        () => setState(() {
                                              selected.contains(colis.id)
                                                  ? selected.remove(colis.id)
                                                  : selected.add(colis.id);
                                            }))
                                ],
                              ))
                          .toList(),
                    ),
                  ),
                ),
                if (selected.isNotEmpty)
                  gradientButton(
                      function: () async {
                        await customPopup(
                            context,
                            ColisOptions(
                                colis: colis
                                    .where((c) => selected.contains(c.id))
                                    .toList()),
                            maxWidth: false);
                      },
                      text: "Options",
                      color: selected.isEmpty ? Colors.grey : null,
                      w: context.w),
                const Gap(10),
              ],
            )),
      ),
    );
  }
}

class ColisOptions extends StatefulWidget {
  final List<Colis> colis;
  const ColisOptions({super.key, required this.colis});

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
                List<ReturnColis> invoices = [];
                try {
                  for (var colis in widget.colis) {
                    colis.status = ColisStatus.returnConfirmed.name;
                    await ColisService.colisCollection
                        .doc(colis.id)
                        .update(colis.toMap());
                    int index = invoices
                        .indexWhere((e) => e.expeditorId == colis.expeditorId);
                    if (index != -1) {
                      invoices[index].colis.add(colis);
                    } else {
                      final expeditor =
                          await UserService.getUserById(colis.expeditorId);
                      invoices.add(ReturnColis(
                          id: generateId(),
                          agencyName: colis.agenceName,
                          agencyId: colis.agenceId,
                          governorate: expeditor!.governorate,
                          city: expeditor.city,
                          region: expeditor.region,
                          address: expeditor.adress,
                          expeditorName: expeditor.getFullName(),
                          expeditorId: expeditor.id,
                          expeditorPhoneNumber: expeditor.phoneNumber,
                          colis: [colis],
                          date: DateTime.now(),
                          isClosed: false));
                    }
                  }
                  for (var invoice in invoices) {
                    await FirebaseFirestore.instance
                        .collection('return colis')
                        .doc(invoice.id)
                        .set(invoice.toMap());
                  }
                  context.pop();

                  // setState(() => loading = false);
                } on Exception catch (e) {
                  log(e.toString());
                  setState(() => loading = false);
                }
              },
              text: "Confirm return",
              w: 200),
          if (loading) cLoader()
        ],
      ),
    );
  }
}
