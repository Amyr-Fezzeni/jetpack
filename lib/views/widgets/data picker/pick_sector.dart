import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/sector.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/text_field.dart';

Future<Sector?> pickSector() async {
  final context = NavigationService.navigatorKey.currentContext!;
  return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: context.bgcolor,
          surfaceTintColor: context.bgcolor,
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(smallRadius)),
          child: const SectorList(),
        );
      });
}

class SectorList extends StatefulWidget {
  const SectorList({super.key});

  @override
  State<SectorList> createState() => _SectorListState();
}

class _SectorListState extends State<SectorList> {
  Sector? selectedSector;
  late final Future<QuerySnapshot<Map<String, dynamic>>> function;
  TextEditingController search = TextEditingController();
  @override
  void initState() {
    function = SectorService.sectorCollection.get();
    super.initState();
    search.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: context.bgcolor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Txt('Sector List', bold: true),
              CustomTextField(
                  hint: txt("Search"),
                  controller: search,
                  validator: (p0) => null),
              divider(),
              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: function,
                  builder: (context, data) {
                    List<Sector> listSector = [];
                    if (data.connectionState == ConnectionState.done &&
                        data.data != null) {
                      listSector = data.data!.docs
                          .map((e) => Sector.fromMap(e.data()))
                          .toList();
                    }
                    return Column(
                      children: listSector
                          .where((sector) =>
                              "${sector.name}${sector.regions.join(' ')}"
                                  .toLowerCase()
                                  .contains(search.text.toLowerCase()))
                          .map((sector) => Card(
                                color: selectedSector != null &&
                                        selectedSector!.id == sector.id
                                    ? context.primaryColor.withOpacity(.3)
                                    : null,
                                child: ListTile(
                                    onTap: () =>
                                        setState(() => selectedSector = sector),
                                    title: Txt(sector.name, bold: true,translate: false),
                                    subtitle: Txt(sector.regions.join(', '),
                                        color: context.iconColor,translate: false)),
                              ))
                          .toList(),
                    );
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  borderButton(
                      h: 50,
                      radius: smallRadius,
                      function: () => Navigator.pop(context),
                      text: txt("cancel")),
                  gradientButton(
                      function: () => Navigator.pop(context, selectedSector),
                      text: txt("Confirm"))
                ],
              )
            ],
          ),
        ));
  }
}
