import 'package:flutter/material.dart';
import 'package:jetpack/providers/statistics.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';

class DeliveryStat extends StatefulWidget {
  const DeliveryStat({super.key});

  @override
  State<DeliveryStat> createState() => _DeliveryStatState();
}

class _DeliveryStatState extends State<DeliveryStat> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //revenue livreur par semaines
        Container(
            // width: 100,
            child: Builder(builder: (context) {
          return Column(
            children: [
              Txt('Total revenue this week', center: true, bold: true),
              Txt(context.statRead
                  .getLastDeliveryPayment(context.userprovider.currentUser!)),
            ],
          );
        }))
        //nb colis par jour vs retour (just current week)
        //rang - runsheet current week  pourcentage livre vs retour pour le  rang des livreurs
      ],
    );
  }
}
