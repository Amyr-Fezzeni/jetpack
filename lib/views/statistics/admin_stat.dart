import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminStat extends StatelessWidget {
  const AdminStat({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(50),
        Txt(''),
        Builder(builder: (context) {
          Map<String, Map<String, Map<String, dynamic>>> data =
              context.statRead.ratringAdmin();

          final colisData = data['colis']!.values.toList();
          // log(colisData.toString());
          colisData.sort((a, b) =>
              stringToDate(b['date']).compareTo(stringToDate(a['date'])));
          log(colisData.toString());
          // [{date: 12-05-2024, delivered: 0, canceled: 1},
          //{date: 04-05-2024, delivered: 1, canceled: 0},
          //{date: 02-05-2024, delivered: 3, canceled: 0},
          //{date: 01-05-2024, delivered: 2, canceled: 0}]
          return Column(
            children: [
              Txt('Colis', bold: true, size: 18, color: palette[5]),
              SfCartesianChart(
                palette: palette,
                tooltipBehavior: TooltipBehavior(enable: true, elevation: 5),
                legend: Legend(isVisible: true, textStyle: context.text),
                series: [
                  StackedColumnSeries(
                      dataSource: colisData.reversed.toList(),
                      xValueMapper: (final d, _) =>
                          (d['date'] as String).split('-').take(2).join('/'),
                      yValueMapper: (final d, _) => d['delivered'],
                      name: txt('Delivered')),
                  StackedColumnSeries(
                      dataSource: colisData.reversed.toList(),
                      xValueMapper: (final d, _) =>
                          (d['date'] as String).split('-').take(2).join('/'),
                      yValueMapper: (final d, _) => d['canceled'],
                      name: txt('Canceled')),
                ],
                primaryXAxis: const CategoryAxis(),
              ),
              const Gap(20),
              Txt('Top Expeditor delivered', bold: true),
              Builder(builder: (context) {
                final expeditor =
                    data['expeditor']!.values.map((e) => e).toList();
                expeditor.sort((a, b) =>
                    (b['delivered'] as int).compareTo((a['delivered'] as int)));
                log(expeditor.toString());
                return SizedBox(
                  width: double.maxFinite,
                  child: Expanded(
                    child: DataTable(columns: [
                      DataColumn(label: Txt('Expeditor name', bold: true)),
                      DataColumn(label: Txt('delivered', bold: true)),
                      // DataColumn(label: Txt(' Total', bold: true)),
                    ], rows: [
                      for (var d in expeditor.take(3))
                        DataRow(
                            color: MaterialStateColor.resolveWith(
                                (states) => Colors.green.withOpacity(.1)),
                            cells: [
                              DataCell(Txt(d['name'], translate: false)),
                              DataCell(Txt(d['delivered'].toString(),
                                  translate: false)),
                              // DataCell(Txt(
                              //     (d['canceled'] + d['delivered']).toString(),
                              //     translate: false)),
                            ])
                    ]),
                  ),
                );
              }),
              divider(top: 10, bottom: 10),
              Txt('Top Expeditor canceled', bold: true),
              Builder(builder: (context) {
                final expeditor =
                    data['expeditor']!.values.map((e) => e).toList();
                expeditor.sort((a, b) =>
                    (b['canceled'] as int).compareTo((a['canceled'] as int)));

                return SizedBox(
                  width: double.maxFinite,
                  child: DataTable(columns: [
                    DataColumn(label: Txt('Expeditor name', bold: true)),
                    DataColumn(label: Txt('Colis canceled', bold: true)),
                  ], rows: [
                    for (var d in expeditor.take(3))
                      DataRow(
                          color: MaterialStateColor.resolveWith(
                              (states) => Colors.red.withOpacity(.1)),
                          cells: [
                            DataCell(Txt(d['name'], translate: false)),
                            DataCell(Txt(d['canceled'].toString(),
                                translate: false)),
                          ])
                  ]),
                );
              }),
              divider(top: 10, bottom: 10),
              Txt('Top agency', bold: true),
              Builder(builder: (context) {
                final agency = data['agency']!.values.map((e) => e).toList();
                agency.sort((a, b) =>
                    (b['delivered'] as int).compareTo((a['delivered'] as int)));

                return SizedBox(
                  width: double.maxFinite,
                  child: DataTable(columns: [
                    DataColumn(label: Txt('Agency name', bold: true)),
                    DataColumn(label: Txt('Colis delivered', bold: true)),
                  ], rows: [
                    for (var d in agency.take(3))
                      DataRow(
                          color: MaterialStateColor.resolveWith(
                              (states) => Colors.green.withOpacity(.1)),
                          cells: [
                            DataCell(Txt(d['name'], translate: false)),
                            DataCell(Txt(d['delivered'].toString(),
                                translate: false)),
                          ])
                  ]),
                );
              }),
              divider(top: 10, bottom: 10),
              Txt('Top agency pickup', bold: true),
              Builder(builder: (context) {
                final agency = data['agency']!.values.map((e) => e).toList();
                agency.sort((a, b) =>
                    ((b['delivered'] as int) + (b['canceled'] as int))
                        .compareTo(
                            (a['delivered'] as int) + (a['canceled'] as int)));

                return SizedBox(
                  width: double.maxFinite,
                  child: DataTable(columns: [
                    DataColumn(label: Txt('Agency name', bold: true)),
                    DataColumn(label: Txt('Colis pickup', bold: true)),
                  ], rows: [
                    for (var d in agency.take(3))
                      DataRow(
                          color: MaterialStateColor.resolveWith(
                              (states) => Colors.red.withOpacity(.1)),
                          cells: [
                            DataCell(Txt(d['name'], translate: false)),
                            DataCell(Txt(
                                (d['delivered'] + d['canceled']).toString(),
                                translate: false)),
                          ])
                  ]),
                );
              }),
              divider(top: 10, bottom: 10),
              Txt('Top sector canceled', bold: true),
              Builder(builder: (context) {
                final sector = data['sector']!.values.map((e) => e).toList();
                sector.sort((a, b) =>
                    (b['canceled'] as int).compareTo(a['canceled'] as int));

                return SizedBox(
                  width: double.maxFinite,
                  child: DataTable(columns: [
                    DataColumn(label: Txt('Sector name', bold: true)),
                    DataColumn(label: Txt('Colis canceled', bold: true)),
                  ], rows: [
                    for (var d in sector.take(3))
                      DataRow(
                          color: MaterialStateColor.resolveWith(
                              (states) => Colors.red.withOpacity(.1)),
                          cells: [
                            DataCell(Txt(d['name'], translate: false)),
                            DataCell(Txt(d['canceled'].toString(),
                                translate: false)),
                          ])
                  ]),
                );
              }),
              divider(top: 10, bottom: 10),
            ],
          );
        })
      ],
    );
  }
}
