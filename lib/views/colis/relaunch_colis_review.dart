import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/relaunch_colis.dart';
import 'package:jetpack/models/report.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/services.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/colis/colis_card.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/custom_drop_down.dart';
import 'package:jetpack/views/widgets/loader.dart';

class RelaunchColisReview extends StatefulWidget {
  final RelaunchColis relaunch;
  final Colis colis;
  const RelaunchColisReview(
      {super.key, required this.relaunch, required this.colis});

  @override
  State<RelaunchColisReview> createState() => _RelaunchColisReviewState();
}

class _RelaunchColisReviewState extends State<RelaunchColisReview> {
  late RelaunchColis relaunch;
  late Colis colis;
  @override
  void initState() {
    super.initState();
    colis = widget.colis;
    relaunch = widget.relaunch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar('Relaunch colis'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const Gap(20),
              Row(
                children: [
                  Txt(widget.relaunch.expeditorName, bold: true,translate: false),
                  const Spacer(),
                  phoneWidget(widget.relaunch.expeditorPhone, 1)
                ],
              ),
              divider(top: 10, bottom: 10),
              Center(
                child: InkWell(
                  onTap: () {
                    final data = ClipboardData(text: colis.id);
                    Clipboard.setData(data);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Code copied."),
                    ));
                  },
                  child: SizedBox(
                    height: 100,
                    width: 200,
                    child: BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: colis.id,
                      style: context.text,
                      color: context.invertedColor.withOpacity(.7),
                    ),
                  ),
                ),
              ),
              const Gap(20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15)
                    .copyWith(bottom: 15),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: context.invertedColor.withOpacity(.05),
                  borderRadius: BorderRadius.circular(smallRadius),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Txt("Client Name", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.name,translate: false))
                      ],
                    ),
                    Row(
                      children: [
                        Txt("Governorate", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.governorate,translate: false))
                      ],
                    ),
                    Row(
                      children: [
                        Txt("City", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.city,translate: false))
                      ],
                    ),
                    Row(
                      children: [
                        Txt("Region", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.region,translate: false))
                      ],
                    ),
                    Row(
                      children: [
                        Txt("Adress", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.address,translate: false))
                      ],
                    ),
                    Row(
                      children: [
                        Txt("Phone number", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.phone1,translate: false))
                      ],
                    ),
                    if (colis.phone2.isNotEmpty)
                      Row(
                        children: [
                          Txt("secondary phone number",
                              bold: true, extra: ': '),
                          Flexible(child: Txt(colis.phone2,translate: false))
                        ],
                      ),
                    Row(
                      children: [
                        Txt("Comment", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.comment,translate: false))
                      ],
                    ),
                    Row(
                      children: [
                        Txt("Items", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.numberOfItems.toString(),translate: false))
                      ],
                    ),
                    Row(
                      children: [
                        Txt("Price", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.price.toStringAsFixed(2),translate: false))
                      ],
                    ),
                    Row(
                      children: [
                        Txt("Fragile", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.isFragile ? 'Yes' : "No"))
                      ],
                    ),
                    Row(
                      children: [
                        Txt("Exchange", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.exchange ? 'Yes' : "No"))
                      ],
                    ),
                    Row(
                      children: [
                        Txt("Openable", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.openable ? 'Yes' : "No"))
                      ],
                    ),
                    Row(
                      children: [
                        Txt("Attempt", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.tentative.toString(),translate: false))
                      ],
                    ),
                    divider(),
                    Row(
                      children: [
                        Txt("Sector", bold: true, extra: ': '),
                        Flexible(child: Txt(colis.sectorName,translate: false))
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 150,
                    child: SimpleDropDown(
                        selectedValue: relaunch.status,
                        values: ReportStatus.values.map((e) => e.name).toList(),
                        onChanged: (value) {
                          if (relaunch.status == value) return;
                          setState(() {
                            relaunch.status = value;
                          });
                          RelaunchColisService.colisCollection
                              .doc(relaunch.id)
                              .update(relaunch.toMap());
                          if (value == ReportStatus.accepted.name) {
                            ColisService.colisCollection
                                .doc(relaunch.colisId)
                                .update({"status": ColisStatus.depot.name});
                          }
                        },
                        hint: txt('Status')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
