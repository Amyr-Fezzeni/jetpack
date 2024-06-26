import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/manifest.dart';
import 'package:jetpack/models/sector.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/manifest_service.dart';
import 'package:jetpack/services/pdf_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';

class ManifestScreen extends StatefulWidget {
  const ManifestScreen({super.key});

  @override
  State<ManifestScreen> createState() => _ManifestScreenState();
}

class _ManifestScreenState extends State<ManifestScreen> {
  List<Manifest> manifests = [];
  late final Stream<QuerySnapshot<Map<String, dynamic>>> function;

  @override
  void initState() {
    super.initState();
    function = ManifestService.manifestCollection
        .where('expeditorId', isEqualTo: context.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Manifest"),
      backgroundColor: context.bgcolor,
      body: SizedBox(
        width: context.w,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: function,
              builder: (context, data) {
                if (data.connectionState == ConnectionState.active &&
                    data.data != null) {
                  manifests = sortDateTimeList(data.data!.docs
                      .map((e) => Manifest.fromMap(e.data()))
                      .toList());
                }
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: manifests
                        .map((manifest) => manifestCard(manifest))
                        .toList(),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

List<Manifest> sortDateTimeList(List<Manifest> dateTimeList) {
  dateTimeList.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
  return dateTimeList;
}

Widget manifestCard(Manifest manifest) => Builder(builder: (context) {
      return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        width: double.maxFinite,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(smallRadius),
            color: context.bgcolor,
            boxShadow: defaultShadow),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Spacer(),
                InkWell(
                  onTap: () async {
                    final colisDocs = await ColisService.colisCollection.get();

                    PdfService.generateMagnifest(
                        manifest,
                        colisDocs.docs
                            .where((doc) => manifest.colis.contains(doc.id))
                            .map((e) => Colis.fromMap(e.data()))
                            .toList());
                  },
                  child: Icon(
                    Icons.download_for_offline_rounded,
                    color: context.primaryColor,
                    size: 45,
                  ),
                )
              ],
            ),
            Center(
              child: SizedBox(
                height: 100,
                width: 200,
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: manifest.id,
                  style: context.text,
                  color: context.invertedColor.withOpacity(.7),
                ),
              ),
            ),
            const Gap(10),
            Txt(getDate(manifest.dateCreated), bold: true, translate: false),
            Txt('Colis: (${manifest.colis.length})', bold: true,translate: false),
            Txt('Total price',
                extra: ': ${manifest.totalPrice.toStringAsFixed(2)} TND',
                bold: true),
            if (manifest.datePicked == null)
              FutureBuilder<Sector?>(
                  future: SectorService.getSector(manifest.region),
                  builder: (context, data) => data.connectionState ==
                              ConnectionState.done &&
                          data.data != null
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Expanded(child: Txt(data.data!.name, bold: true)),
                              const Spacer(),
                              phoneWidgetId('', id: data.data!.delivery['id'])
                            ])
                      : const SizedBox())
          ],
        ),
      );
    });
