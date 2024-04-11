import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/text_field.dart';

Future<UserModel?> pickDelivery() async {
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
          child: const DeliveryList(),
        );
      });
}

class DeliveryList extends StatefulWidget {
  const DeliveryList({super.key});

  @override
  State<DeliveryList> createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> {
  UserModel? selectedDelivery;
  late final Future<QuerySnapshot<Map<String, dynamic>>> function;
  TextEditingController search = TextEditingController();
  @override
  void initState() {
    function = UserService.userCollection
        .where("role", isEqualTo: Role.delivery.name)
        .get();
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
              Txt('Delivery List', bold: true),
              CustomTextField(
                  hint: txt("Search"),
                  controller: search,
                  validator: (p0) => null),
              divider(),
              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: function,
                  builder: (context, data) {
                    List<UserModel> listDelivery = [];
                    if (data.connectionState == ConnectionState.done &&
                        data.data != null) {
                      listDelivery = data.data!.docs
                          .map((e) => UserModel.fromMap(e.data()))
                          .toList();
                    }
                    return Column(
                      children: listDelivery
                          .where((delivery) =>
                              "${delivery.getFullName()}${delivery.cin}${delivery.phoneNumber}${delivery.adress}"
                                  .toLowerCase()
                                  .contains(search.text.toLowerCase()))
                          .map((delivery) => Card(
                                color: selectedDelivery != null &&
                                        selectedDelivery!.id == delivery.id
                                    ? context.primaryColor.withOpacity(.3)
                                    : null,
                                child: ListTile(
                                    onTap: () => setState(
                                        () => selectedDelivery = delivery),
                                    title:
                                        Txt(delivery.getFullName(), bold: true),
                                    subtitle: Txt(delivery.adress,
                                        color: context.iconColor)),
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
                      text: "cancel"),
                  gradientButton(
                      function: () => Navigator.pop(context, selectedDelivery),
                      text: "Confirm")
                ],
              )
            ],
          ),
        ));
  }
}
