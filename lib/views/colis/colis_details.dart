import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';

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
                  Txt("City", bold: true, extra: ': '),
                  Flexible(child: Txt(colis.city))
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
            ],
          ),
        ),
      ],
    ));
  }
}
