import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/colis/colis_card.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';

class ColisList extends StatefulWidget {
  final String title;
  final List<Colis> colisData;
  const ColisList({super.key, required this.title, required this.colisData});

  @override
  State<ColisList> createState() => _ColisListState();
}

class _ColisListState extends State<ColisList> {
  List<Colis> selected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(widget.title),
      backgroundColor: context.bgcolor,
      body: SizedBox(
        width: context.w,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => setState(() => selected.clear()),
                      child: Txt("Clear", color: context.primaryColor)),
                  TextButton(
                      onPressed: () =>
                          setState(() => selected.addAll(widget.colisData)),
                      child: Txt("Select All", color: context.primaryColor)),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: widget.colisData
                        .map((colis) => Row(
                              children: [
                                Flexible(child: ColisCard(colis: colis)),
                                const Gap(15),
                                checkBox(
                                    selected.contains(colis),
                                    '',
                                    () => setState(() {
                                          selected.contains(colis)
                                              ? selected.remove(colis)
                                              : selected.add(colis);
                                        }))
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ),
              gradientButton(function: () {}, text: "Option", w: context.w),
              const Gap(10),
            ],
          ),
        ),
      ),
    );
  }
}
