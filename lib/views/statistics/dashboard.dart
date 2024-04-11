import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/statistics/statistic_widget.dart';
import 'package:jetpack/views/widgets/bottuns.dart';

class HomeStatsScreen extends StatefulWidget {
  const HomeStatsScreen({super.key});

  @override
  State<HomeStatsScreen> createState() => _HomeStatsScreenState();
}

class _HomeStatsScreenState extends State<HomeStatsScreen> {
  int filter = 1;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                borderButton(
                    text: "Day",
                    opacity: 0,
                    textColor: filter == 1
                        ? context.primaryColor
                        : context.invertedColor.withOpacity(.7),
                    function: () => setState(() => filter = 1)),
                borderButton(
                    text: "Week",
                    opacity: 0,
                    textColor: filter == 7
                        ? context.primaryColor
                        : context.invertedColor.withOpacity(.7),
                    function: () => setState(() => filter = 7)),
                borderButton(
                    text: "Month",
                    opacity: 0,
                    textColor: filter == 30
                        ? context.primaryColor
                        : context.invertedColor.withOpacity(.7),
                    function: () => setState(() => filter = 30)),
              ],
            ),
            const Gap(10),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.center,
              children: [
                StatWidgetSimple(
                    title: "Expeditor (0)", colors: [Colors.orange, Colors.red]),
                StatWidgetSimple(
                    title: "Delivery (0)",
                    colors: [Colors.purple, Colors.limeAccent]),
                StatWidgetSimple(
                    title: "Colis (0)", colors: [Colors.blue, Colors.red]),
                StatWidgetSimple(
                    title: "Agence (0)", colors: [Colors.purple, Colors.pink]),
                StatWidgetSimple(
                    title: "Client (0)",
                    colors: [Colors.deepOrange, Colors.blue]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
