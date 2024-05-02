// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/pdf_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/colis/colis_card.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:jetpack/views/widgets/text_field.dart';

class ColisList extends StatefulWidget {
  final String title;
  final List<ColisStatus> status;
  const ColisList({super.key, required this.title, required this.status});

  @override
  State<ColisList> createState() => _ColisListState();
}

class _ColisListState extends State<ColisList> {
  List<String> selected = [];
  List<Colis> colis = [];
  @override
  Widget build(BuildContext context) {
    colis = context.role == Role.admin
        ? context.adminWatch.allColis
            .where((c) => widget.status.map((e) => e.name).contains(c.status))
            .toList()
        : context.expeditorWatch.allColis
            .where((c) => widget.status.map((e) => e.name).contains(c.status))
            .toList();
    return Scaffold(
      appBar: appBar(widget.title),
      backgroundColor: context.bgcolor,
      floatingActionButton: !widget.status.contains(ColisStatus.pickup)
          ? null
          : FloatingActionButton(
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
                                    context.adminRead.scanDepot(code);
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
                                context.adminRead.scanDepot(code);
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
      body: SizedBox(
        width: context.w,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.status.contains(ColisStatus.inProgress))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () => setState(() => selected.clear()),
                          child: Txt("Clear", color: context.primaryColor)),
                      TextButton(
                          onPressed: () => setState(
                              () => selected.addAll(colis.map((e) => e.id))),
                          child:
                              Txt("Select All", color: context.primaryColor)),
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
                                  if (widget.status
                                      .contains(ColisStatus.inProgress)) ...[
                                    const Gap(10),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () =>
                                              PdfService.generateColis(colis),
                                          child: Icon(
                                            Icons.download,
                                            color: context.iconColor,
                                            size: 35,
                                          ),
                                        ),
                                        const Gap(10),
                                        checkBox(
                                            selected.contains(colis.id),
                                            '',
                                            () => setState(() {
                                                  selected.contains(colis.id)
                                                      ? selected
                                                          .remove(colis.id)
                                                      : selected.add(colis.id);
                                                })),
                                      ],
                                    )
                                  ]
                                ],
                              ))
                          .toList(),
                    ),
                  ),
                ),
                if (widget.status.contains(ColisStatus.inProgress) &&
                    selected.isNotEmpty)
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
                try {
                  await context.expeditorRead
                      .generateMagnifest(widget.colis)
                      .then((value) => context.pop());

                  setState(() => loading = false);
                } on Exception catch (e) {
                  log(e.toString());
                  setState(() => loading = false);
                }
              },
              text: "Generate magnifest",
              w: 200),
          if (loading) cLoader()
        ],
      ),
    );
  }
}
