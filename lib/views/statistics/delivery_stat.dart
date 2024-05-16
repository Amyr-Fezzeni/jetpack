import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DeliveryStat extends StatefulWidget {
  const DeliveryStat({super.key});

  @override
  State<DeliveryStat> createState() => _DeliveryStatState();
}

class _DeliveryStatState extends State<DeliveryStat> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Gap(50),
      Column(
        children: [
          const Gap(10),
          Txt('Total revenue this week',
              color: palette[5], size: 16, bold: true),
          Txt(
            context.statRead
                .getLastDeliveryPayment(context.userprovider.currentUser!),
            bold: true,
            translate: false,
            size: 18,
            color: palette[5],
          )
        ],
      ),
      const Gap(20),
      const Gap(20),
      Builder(builder: (context) {
        List<Map<String, dynamic>> data = context.statRead
            .runsheetColisDelivery(context.userprovider.currentUser!);
        data.sort((a, b) => stringToDateReversed(a['date'])
            .compareTo(stringToDateReversed(b['date'])));
        log('colis per day: $data');
        return SfCartesianChart(
          palette: palette,
          tooltipBehavior: TooltipBehavior(enable: true, elevation: 5),
          legend: Legend(isVisible: true, textStyle: context.text),
          series: [
            StackedColumnSeries(
                dataSource: data,
                xValueMapper: (final d, _) =>
                    (d['date'] as String).split('-').skip(1).take(2).join('/'),
                yValueMapper: (final d, _) => d['delivered'],
                name: txt('Colis per day')),
            StackedColumnSeries(
                dataSource: data,
                xValueMapper: (final d, _) =>
                    (d['date'] as String).split('-').skip(1).take(2).join('/'),
                yValueMapper: (final d, _) => d['canceled'],
                name: txt('Colis per day')),
          ],
          primaryXAxis: const CategoryAxis(),
        );
      }),
      const Gap(10),
    ]);
  }
}
