import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/colis/add_colis.dart';
import 'package:jetpack/views/colis/colis_details.dart';
import 'package:jetpack/views/colis/runsheet_colis_details.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:url_launcher/url_launcher.dart';

class ColisCard extends StatelessWidget {
  final Colis colis;
  const ColisCard({super.key, required this.colis});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.bgcolor,
      child: ListTile(
        title: Txt(capitalize(colis.name), bold: true),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Txt(colis.id, size: 10, color: context.primaryColor, bold: true),
            Txt("${colis.price.toStringAsFixed(2)} Dt",
                size: 10, color: context.iconColor),
          ],
        ),
        trailing: InkWell(
          onTap: () => colis.status == ColisStatus.inProgress.name
              ? context.moveTo(AddColis(colis: colis))
              : customPopup(context, ColisDetails(colis: colis)),
          child: Icon(
              colis.status == ColisStatus.inProgress.name
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.notes_rounded,
              color: context.iconColor,
              size: 25),
        ),
      ),
    );
  }
}

Widget colisRunsheetCard(String id) => Builder(
    key: ValueKey(id),
    builder: (context) {
      final c = context.deliveryWatch.allColis.where((c) => c.id == id);
      if (c.isEmpty) return const SizedBox.shrink();
      Colis colis = c.first;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(smallRadius),
            color: context.bgcolor,
            boxShadow: defaultShadow),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(smallRadius),
              color: getColor(colis.status).withOpacity(.15)),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => customPopup(
                          context, RunsheetColisDetails(colis: colis)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Txt(colis.name, bold: true),
                            Txt('${colis.price}TND', color: context.iconColor),
                            if (colis.expeditorName.isNotEmpty)
                              Txt(colis.expeditorName, bold: true),
                            if (colis.exchange)
                              Txt('EXCHANGE',
                                  color: context.iconColor, bold: true),
                            if (colis.address.isNotEmpty)
                              Txt(colis.address, color: context.iconColor),
                            // divider(),
                            if (colis.deliveryComment.isNotEmpty)
                              Txt(colis.deliveryComment,
                                  maxLines: 2,
                                  size: 12,
                                  color: context.iconColor),
                          ]),
                    ),
                  ),
                  phoneWidget(colis.phone1, 1),
                  if (colis.phone2.isNotEmpty) phoneWidget(colis.phone2, 2),
                ],
              ),
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: Container(
              //     margin: const EdgeInsets.symmetric(vertical: 5),
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              //     decoration: BoxDecoration(
              //       color: getColor(colis.status).withOpacity(.2),
              //       border: Border.all(color: getColor(colis.status)),
              //       borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              //     ),
              //     child: Txt(getText(colis.status)),
              //   ),
              // ),
              const Gap(10),
              SizedBox(
                child: Builder(builder: (context) {
                  Color color = getColor(colis.status);

                  return Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton(
                      onSelected: (value) {},
                      color: context.bgcolor,
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
                      itemBuilder: (BuildContext c) {
                        return [
                          ColisStatus.confirmed,
                          ColisStatus.delivered,
                          ColisStatus.returnDepot,
                          ColisStatus.canceled,
                          ColisStatus.appointment
                        ]
                            .map((ColisStatus status) => PopupMenuItem(
                                  onTap: () async {
                                    if (colis.status == status.name) {
                                      return;
                                    }

                                    if (status == ColisStatus.appointment) {
                                      final date = await datePopup(
                                          day: true, minDate: DateTime.now());
                                      if (date == null) return;
                                      colis.appointmentDate = date;
                                    }
                                    colis.status = status.name;
                                    if (colis.status ==
                                        ColisStatus.delivered.name) {
                                      colis.deliveryDate = DateTime.now();
                                    }
                                    ColisService.colisCollection
                                        .doc(colis.id)
                                        .update(colis.toMap());
                                  },
                                  value: status.name,
                                  child: Text(
                                    getText(status.name),
                                    style: context.theme.text18,
                                  ),
                                ))
                            .toList();
                      },
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      );
    });

Widget phoneWidget(String phoneNumber, int index, {double size = 50}) =>
    InkWell(
      onTap: () => launchUrl(
        Uri(scheme: 'tel', path: phoneNumber),
      ),
      child: Container(
        height: size,
        width: size,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
            boxShadow: defaultShadow,
            borderRadius: BorderRadius.circular(100),
            color: Colors.green),
        child: Stack(
          children: [
            Center(
                child: Icon(Icons.phone, color: Colors.white, size: size / 2)),
            Positioned(
                top: 0,
                right: 0,
                child: Container(
                  height: size / 2,
                  width: size / 2,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: defaultShadow,
                      borderRadius: BorderRadius.circular(bigRadius)),
                  child: Center(
                      child: Txt(index.toString(),
                          color: Colors.black, size: size / 3)),
                ))
          ],
        ),
      ),
    );
