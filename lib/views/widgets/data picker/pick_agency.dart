import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/agency.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/text_field.dart';

Future<Agency?> pickAgency() async {
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
          child: const AgencyList(),
        );
      });
}

class AgencyList extends StatefulWidget {
  const AgencyList({super.key});

  @override
  State<AgencyList> createState() => _AgencyListState();
}

class _AgencyListState extends State<AgencyList> {
  Agency? selectedAgency;
  late final Future<QuerySnapshot<Map<String, dynamic>>> function;
  TextEditingController search = TextEditingController();
  @override
  void initState() {
    function = AgencyService.agencyCollection.get();
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
              Txt('Agency List', bold: true),
              CustomTextField(
                  hint: txt("Search"),
                  controller: search,
                  validator: (p0) => null),
              divider(),
              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: function,
                  builder: (context, data) {
                    List<Agency> listAgency = [];
                    if (data.connectionState == ConnectionState.done &&
                        data.data != null) {
                      listAgency = data.data!.docs
                          .map((e) => Agency.fromMap(e.data()))
                          .toList();
                    }
                    return Column(
                      children: listAgency
                          .where((agency) =>
                              "${agency.name}${agency.agencyLead}${agency.adress}"
                                  .toLowerCase()
                                  .contains(search.text.toLowerCase()))
                          .map((agency) => Card(
                                color: selectedAgency != null &&
                                        selectedAgency!.id == agency.id
                                    ? context.primaryColor.withOpacity(.3)
                                    : context.bgcolor,
                                child: ListTile(
                                    onTap: () =>
                                        setState(() => selectedAgency = agency),
                                    title: Txt(agency.name, bold: true,translate: false),
                                    subtitle: Txt(agency.agencyLead,
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
                      function: () => Navigator.pop(context, selectedAgency),
                      text: txt("Confirm"))
                ],
              )
            ],
          ),
        ));
  }
}
