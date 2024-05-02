import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';

class ColisDetails extends StatelessWidget {
  final Colis colis;

  const ColisDetails({super.key, required this.colis});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        const Gap(40),
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
          margin:
              const EdgeInsets.symmetric(horizontal: 15).copyWith(bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: context.invertedColor.withOpacity(.05),
            borderRadius: BorderRadius.circular(smallRadius),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Txt("Client Name", bold: true, extra: ': '),
                  Flexible(child: Txt(colis.name))
                ],
              ),
              Row(
                children: [
                  Txt("Governorate", bold: true, extra: ': '),
                  Flexible(child: Txt(colis.governorate))
                ],
              ),
              Row(
                children: [
                  Txt("City", bold: true, extra: ': '),
                  Flexible(child: Txt(colis.city))
                ],
              ),
              Row(
                children: [
                  Txt("Region", bold: true, extra: ': '),
                  Flexible(child: Txt(colis.region))
                ],
              ),
              Row(
                children: [
                  Txt("Adress", bold: true, extra: ': '),
                  Flexible(child: Txt(colis.address))
                ],
              ),
              Row(
                children: [
                  Txt("Phone number", bold: true, extra: ': '),
                  Flexible(child: Txt(colis.phone1))
                ],
              ),
              if (colis.phone2.isNotEmpty)
                Row(
                  children: [
                    Txt("secondary phone number", bold: true, extra: ': '),
                    Flexible(child: Txt(colis.phone2))
                  ],
                ),
              Row(
                children: [
                  Txt("Comment", bold: true, extra: ': '),
                  Flexible(child: Txt(colis.comment))
                ],
              ),
              Row(
                children: [
                  Txt("Items", bold: true, extra: ': '),
                  Flexible(child: Txt(colis.numberOfItems.toString()))
                ],
              ),
              Row(
                children: [
                  Txt("Price", bold: true, extra: ': '),
                  Flexible(child: Txt(colis.price.toStringAsFixed(2)))
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
                  Flexible(child: Txt(colis.tentative.toString()))
                ],
              ),
              divider(),
              Row(
                children: [
                  Txt("Sector", bold: true, extra: ': '),
                  Flexible(child: Txt(colis.sectorName))
                ],
              ),
              if ([Role.admin.name, Role.expeditor.name]
                  .contains(context.currentUser.role.name))
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt("Delivery", bold: true, extra: ': '),
                    Expanded(child: Txt(colis.deliveryName)),
                    const Spacer(),
                    phoneWidgetId('', id: colis.deliveryId)
                  ],
                ),
              if ([Role.admin.name, Role.expeditor.name]
                  .contains(context.currentUser.role.name))
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Builder(builder: (context) {
                        Color color = getColor(colis.status);

                        return PopupMenuButton(
                          onSelected: (value) {},
                          color: context.bgcolor,
                          child: Container(
                              height: 35,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: color.withOpacity(.2),
                                border: Border.all(color: color),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0)),
                              ),
                              child: Center(
                                child: Text(
                                  txt(getText(colis.status)),
                                  style: context.text
                                      .copyWith(fontSize: 14, color: color),
                                ),
                              )),
                          itemBuilder: (BuildContext c) {
                            return [
                              ColisStatus.returnDepot,
                              ColisStatus.canceled
                            ]
                                .map((ColisStatus status) => PopupMenuItem(
                                      onTap: () async {
                                        if (colis.status ==
                                            ColisStatus.delivered.name) return;
                                        if (colis.status == status.name) {
                                          return;
                                        }
                                        ColisService.colisCollection
                                            .doc(colis.id)
                                            .update({
                                          'status': status.name
                                        }).then((value) => context.pop());
                                      },
                                      value: status.name,
                                      child: Text(
                                        getText(status.name),
                                        style: context.theme.text18,
                                      ),
                                    ))
                                .toList();
                          },
                        );
                      }),
                      const Gap(10),
                      if (colis.status == ColisStatus.appointment.name)
                        Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: context.invertedColor.withOpacity(.2)),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Txt(getDate(colis.appointmentDate)))
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ));
  }
}
