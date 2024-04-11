import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';

class StatWidgetSimple extends StatefulWidget {
  final String title;
  final List<Color> colors;

  const StatWidgetSimple(
      {super.key, required this.title, required this.colors});

  @override
  State<StatWidgetSimple> createState() => _StatWidgetSimpleState();
}

class _StatWidgetSimpleState extends State<StatWidgetSimple> {
  List<FlSpot> spots = [];
  @override
  void initState() {
    spots = getRandom();
    super.initState();
    Random ranmon = Random();
    Timer.periodic(Duration(seconds: ranmon.nextInt(5) + 1), (timer) {
      setState(() {
        spots = getRandom();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      // margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          boxShadow: defaultShadow,
          color: context.bgcolor,
          borderRadius: BorderRadius.circular(smallRadius),
          border: Border.all(color: context.invertedColor.withOpacity(.3))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Txt(widget.title, bold: true),
            ],
          ),
          const Gap(10),
          SizedBox(
            height: 100,
            width: context.w * .4,
            child: LineChart(LineChartData(
              lineTouchData: const LineTouchData(enabled: false),
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: false),
              minY: 0.9,
              borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                      color: context.invertedColor.withOpacity(.3), width: 1)),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: .1,
                  gradient: LinearGradient(
                      colors: widget.colors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight),
                  barWidth: 1,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: widget.colors
                          .map((color) => color.withOpacity(0.3))
                          .toList(),
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ],
            )),
          )
        ],
      ),
    );
  }
}

List<FlSpot> getRandom() {
  Random random = Random();
  return List.generate(30,
      (index) => FlSpot(index.toDouble(), (random.nextInt(10) + 1).toDouble()));
}
