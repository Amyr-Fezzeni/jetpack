import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/client.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:jetpack/views/clients/add_client.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/text_field.dart';

Future<Client?> pickClient() async {
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
          child: const ClientList(),
        );
      });
}

class ClientList extends StatefulWidget {
  const ClientList({super.key});

  @override
  State<ClientList> createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  Client? selectedClient;
  late final Future<QuerySnapshot<Map<String, dynamic>>> function;
  TextEditingController search = TextEditingController();
  @override
  void initState() {
    function = ClientService.clientCollection.get();
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
              Txt('Client List', bold: true),
              CustomTextField(
                  hint: txt("Search"),
                  controller: search,
                  validator: (p0) => null),
              divider(),
              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: function,
                  builder: (context, data) {
                    List<Client> listClient = [];
                    if (data.connectionState == ConnectionState.done &&
                        data.data != null) {
                      listClient = data.data!.docs
                          .map((e) => Client.fromMap(e.data()))
                          .toList();
                    }
                    return Column(
                      children: listClient
                          .where((client) =>
                              "${client.firstName}${client.lastName}${client.phoneNumber}${client.secondaryPhoneNumber}"
                                  .toLowerCase()
                                  .contains(search.text.toLowerCase()))
                          .map((client) => Card(
                                color: selectedClient != null &&
                                        selectedClient!.id == client.id
                                    ? context.primaryColor.withOpacity(.3)
                                    : null,
                                child: ListTile(
                                    onTap: () =>
                                        setState(() => selectedClient = client),
                                    title: Txt(
                                        "${client.firstName}${client.lastName}",
                                        bold: true),
                                    subtitle: Txt(client.adress,
                                        color: context.iconColor)),
                              ))
                          .toList(),
                    );
                  }),
              borderButton(
                  function: () => context.moveTo(const AddClient()),
                  text: "Add new client",
                  opacity: 0,
                  textColor: context.primaryColor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  borderButton(
                      h: 50,
                      radius: smallRadius,
                      function: () => Navigator.pop(context),
                      text: "cancel"),
                  gradientButton(
                      function: () => Navigator.pop(context, selectedClient),
                      text: "Confirm")
                ],
              )
            ],
          ),
        ));
  }
}
