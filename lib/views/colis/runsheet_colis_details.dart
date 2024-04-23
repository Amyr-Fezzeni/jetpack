import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/text_field.dart';

class RunsheetColisDetails extends StatefulWidget {
  final Colis colis;
  const RunsheetColisDetails({super.key, required this.colis});

  @override
  State<RunsheetColisDetails> createState() => _RunsheetColisDetailsState();
}

class _RunsheetColisDetailsState extends State<RunsheetColisDetails> {
  TextEditingController comment = TextEditingController();
  @override
  void initState() {
    super.initState();
    comment.text = widget.colis.deliveryComment;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        const Gap(40),
        Center(
          child: SizedBox(
            height: 100,
            width: 200,
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: widget.colis.id,
              style: context.text,
              color: context.invertedColor.withOpacity(.7),
            ),
          ),
        ),
        const Gap(20),
        Container(
          margin:
              const EdgeInsets.symmetric(horizontal: 15).copyWith(bottom: 5),
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
                  Flexible(child: Txt(widget.colis.name))
                ],
              ),
              Row(
                children: [
                  Txt("Governorate", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.governorate))
                ],
              ),
              Row(
                children: [
                  Txt("City", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.city))
                ],
              ),
              Row(
                children: [
                  Txt("Region", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.region))
                ],
              ),
              Row(
                children: [
                  Txt("Adress", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.address))
                ],
              ),
              Row(
                children: [
                  Txt("Phone number", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.phone1))
                ],
              ),
              if (widget.colis.phone2.isNotEmpty)
                Row(
                  children: [
                    Txt("secondary phone number", bold: true, extra: ': '),
                    Flexible(child: Txt(widget.colis.phone2))
                  ],
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Txt("Client comment", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.comment))
                ],
              ),
              Row(
                children: [
                  Txt("Items", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.numberOfItems.toString()))
                ],
              ),
              Row(
                children: [
                  Txt("Price", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.price.toStringAsFixed(2)))
                ],
              ),
              Row(
                children: [
                  Txt("Fragile", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.isFragile ? 'Yes' : "No"))
                ],
              ),
              Row(
                children: [
                  Txt("Exchange", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.exchange ? 'Yes' : "No"))
                ],
              ),
              Row(
                children: [
                  Txt("Openable", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.openable ? 'Yes' : "No"))
                ],
              ),
              Row(
                children: [
                  Txt("Attempt", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.tentative.toString()))
                ],
              ),
              divider(),
              Row(
                children: [
                  Txt("Sector", bold: true, extra: ': '),
                  Flexible(child: Txt(widget.colis.sectorName))
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: CustomTextField(
                            marginH: 0,
                            marginV: 0,
                            padding: 10,
                            maxLines: 4,
                            height: 100,
                            hint: txt("Comment"),
                            controller: comment)),
                    const Gap(10),
                    gradientButton(
                        function: () {
                          //add comment
                          ColisService.colisCollection
                              .doc(widget.colis.id)
                              .update({"deliveryComment": comment.text}).then(
                                  (value) => context.pop());
                        },
                        text: "Save")
                  ],
                ),
                // const Gap(10),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Builder(builder: (context) {
                //       Color color = getColor(widget.colis.status);

                //       return PopupMenuButton(
                //         onSelected: (value) {},
                //         color: context.bgcolor,
                //         child: Container(
                //             height: 35,
                //             padding: const EdgeInsets.all(5),
                //             decoration: BoxDecoration(
                //               color: color.withOpacity(.2),
                //               border: Border.all(color: color),
                //               borderRadius:
                //                   const BorderRadius.all(Radius.circular(5.0)),
                //             ),
                //             child: Center(
                //               child: Text(
                //                 txt(getText(widget.colis.status)),
                //                 style: context.text
                //                     .copyWith(fontSize: 14, color: color),
                //               ),
                //             )),
                //         itemBuilder: (BuildContext c) {
                //           return [
                //             ColisStatus.confirmed,
                //             ColisStatus.delivered,
                //             ColisStatus.returnDepot,
                //             ColisStatus.canceled
                //           ]
                //               .map((ColisStatus status) => PopupMenuItem(
                //                     onTap: () async {
                //                       if (widget.colis.status == status.name) {
                //                         return;
                //                       }
                //                       ColisService.colisCollection
                //                           .doc(widget.colis.id)
                //                           .update({'status': status.name}).then(
                //                               (value) => context.pop());
                //                     },
                //                     value: status.name,
                //                     child: Text(
                //                       getText(status.name),
                //                       style: context.theme.text18,
                //                     ),
                //                   ))
                //               .toList();
                //         },
                //       );
                //     })
                //   ],
                // ),
              ],
            ),
          ),
        ),
        const Gap(15)
      ],
    ));
  }
}
