import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';

class DeliveryEndOfDayWidget extends StatelessWidget {
  const DeliveryEndOfDayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      int deliverd = 0;
      int returnColis = 0;
      int exchange = 0;
      double recette = 0;
      for (var colis in context.deliveryRead.runsheet) {
        if (colis.status == ColisStatus.delivered.name) {
          deliverd += 1;
          recette += colis.price;
          if (colis.exchange) {
            exchange += 1;
          }
        } else {
          returnColis += 1;
        }
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Txt('Rapport de fin de journée', bold: true),
            divider(top: 5, bottom: 5),
            Txt('Nombre total des colis livrés', extra: ": $deliverd"),
            Txt('Nombre des colis retour', extra: ": $returnColis"),
            Txt('Nombre des colis echange', extra: ": $exchange"),
            Txt('Total recette', extra: ": ${recette.toStringAsFixed(3)} TND"),
            const Gap(10),
            Align(
              alignment: Alignment.centerRight,
              child: borderButton(
                  text: "Ok",
                  function: () => context.pop(),
                  w: 100,
                  radius: smallRadius),
            )
          ],
        ),
      );
    });
  }
}
