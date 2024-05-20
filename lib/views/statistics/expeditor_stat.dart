import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExpeditorStat extends StatefulWidget {
  const ExpeditorStat({super.key});

  @override
  State<ExpeditorStat> createState() => _ExpeditorStatState();
}

class _ExpeditorStatState extends State<ExpeditorStat> {
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
                .getLastExpeditorPayment(context.userprovider.currentUser!)
                .toString(),
            bold: true,
            translate: false,
            size: 18,
            color: palette[5],
          )
        ],
      ),
      const Gap(20),
      Builder(builder: (context) {
        List<Map<String, dynamic>> data =
            context.statRead.colisExpeditor(context.userprovider.currentUser!);
        log('colis total: $data');
//[{type: delivered, count: 10, price: 497.4}, {type: canceled, count: 5, price: 177.0}]

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: palette.first, width: 3)),
                  child: Center(
                      child: Txt(data.first['count'].toString(),
                          translate: false, color: palette.first)),
                ),
                const Gap(10),
                Txt('Colis delivered', color: palette.first),
              ],
            ),
            Column(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: palette[1], width: 3)),
                  child: Center(
                      child: Txt(data.last['count'].toString(),
                          translate: false, color: palette[1])),
                ),
                const Gap(10),
                Txt('Colis canceled', color: palette[1]),
              ],
            ),
          ],
        );
      }),
      const Gap(20),
      Builder(builder: (context) {
        final data =
            context.statRead.colisExpeditor(context.userprovider.currentUser!);

        return SfCircularChart(
          palette: palette,
          title: ChartTitle(text: "", textStyle: context.text),
          legend: Legend(
              isVisible: true,
              overflowMode: LegendItemOverflowMode.scroll,
              textStyle: context.text),
          tooltipBehavior: TooltipBehavior(enable: true, elevation: 5),
          series: <CircularSeries>[
            DoughnutSeries<Map<String, dynamic>, String>(
                dataSource: data,
                xValueMapper: (Map<String, dynamic> data, _) =>
                    txt(data['type']),
                yValueMapper: (Map<String, dynamic> data, _) => data['price'],
                enableTooltip: true,
                // maximumValue: 700,
                dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: context.text.copyWith(color: Colors.white)))
          ],
        );
      }),
      const Gap(20),
      Builder(builder: (context) {
        List<Map<String, dynamic>> data =
            context.statRead.colisDay(context.userprovider.currentUser!);

        // log('colis per day: $data');
        return SfCartesianChart(
          palette: palette,
          tooltipBehavior: TooltipBehavior(enable: true, elevation: 5),
          legend: Legend(isVisible: true, textStyle: context.text),
          series: [
            StackedColumnSeries(
                dataSource: data.reversed.toList(),
                xValueMapper: (final d, _) =>
                    (d['day'] as String).split('-').take(2).join('/'),
                yValueMapper: (final d, _) => d['data'],
                name: txt('Colis per day')),
          ],
          primaryXAxis: const CategoryAxis(),
        );
      }),
      const Gap(10),
      Builder(builder: (context) {
        List<Map<String, dynamic>> data =
            context.statRead.ratringClients(context.userprovider.currentUser!);
        log('colis per day: $data');
        final delivered = data.map((e) => e).toList();
        delivered.sort((a, b) =>
            (b['delivered'] as int).compareTo((a['delivered'] as int)));
        final canceled = data.map((e) => e).toList();
        canceled.sort(
            (a, b) => (b['canceled'] as int).compareTo((a['canceled'] as int)));

        return Column(
          children: [
            Txt('Top clients', bold: true),
            SizedBox(
              width: double.maxFinite,
              child: DataTable(columns: [
                DataColumn(label: Txt('Name')),
                DataColumn(label: Txt('Colis delivered')),
              ], rows: [
                for (var d in delivered.take(3))
                  DataRow(cells: [
                    DataCell(Txt(d['name'], translate: false)),
                    DataCell(Txt(d['delivered'].toString(), translate: false)),
                  ])
              ]),
            ),
            divider(top: 10, bottom: 10),
            Txt('Worst clients', bold: true),
            SizedBox(
              width: double.maxFinite,
              child: DataTable(columns: [
                DataColumn(label: Txt('Name')),
                DataColumn(label: Txt('Colis canceled')),
              ], rows: [
                for (var d in canceled.take(3))
                  DataRow(cells: [
                    DataCell(Txt(d['name'], translate: false)),
                    DataCell(Txt(d['canceled'].toString(), translate: false)),
                  ])
              ]),
            ),
          ],
        );
      }),
    ]);
  }
}
