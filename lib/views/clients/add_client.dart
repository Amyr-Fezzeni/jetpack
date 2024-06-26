// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/constants/tunis_data.dart';
import 'package:jetpack/models/client.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/client_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/validators.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/custom_drop_down.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:jetpack/views/widgets/text_field.dart';

class AddClient extends StatefulWidget {
  final Client? client;
  const AddClient({super.key, this.client});

  @override
  State<AddClient> createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  final formkey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController secondaryPhoneController = TextEditingController();
  TextEditingController governorate = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController adress = TextEditingController();

  bool submitted = false;
  bool loading = false;
  late Client client;
  bool validateInfo() {
    List<bool> validators = [];
    validators.addAll([]);
    return !validators.any((v) => v == false);
  }

  @override
  void initState() {
    super.initState();

    client = widget.client ??
        Client(
            id: generateId(),
            firstName: '',
            lastName: '',
            adress: '',
            region: '',
            phoneNumber: '',
            secondaryPhoneNumber: '',
            governorate: '',
            city: '');
    firstNameController.text = client.firstName;
    lastNameController.text = client.lastName;
    adress.text = client.adress;
    phoneController.text = client.phoneNumber;
    secondaryPhoneController.text = client.secondaryPhoneNumber;
    governorate.text = client.governorate;
    city.text = client.city;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar(widget.client != null ? 'Update' : 'Add client'),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
          },
          child: Form(
            key: formkey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(40),
                  CustomTextField(
                      hint: txt("First name"),
                      controller: firstNameController,
                      validator: nameValidator,
                      keybordType: TextInputType.name,
                      submitted: submitted),
                  CustomTextField(
                      hint: txt("Last name"),
                      controller: lastNameController,
                      validator: nameValidator,
                      keybordType: TextInputType.name,
                      submitted: submitted),
                  CustomTextField(
                      hint: txt("Phone number"),
                      controller: phoneController,
                      keybordType: TextInputType.phone,
                      submitted: submitted),
                  CustomTextField(
                      hint: txt("Secondary phone number"),
                      controller: secondaryPhoneController,
                      keybordType: TextInputType.phone,
                      submitted: submitted),
                  ...[
                    SimpleDropDown(
                      selectedValue: client.governorate,
                      hint: "Governorate",
                      onChanged: (governorate) => setState(() {
                        client.governorate = governorate;
                        client.city = '';
                        client.region = '';
                      }),
                      values: tunisData.keys.toList(),
                    ),
                    if (client.governorate.isNotEmpty)
                      SimpleDropDown(
                        selectedValue: client.city,
                        hint: "City",
                        onChanged: (city) {
                          setState(() {
                            client.city = city;
                            client.region = '';
                          });
                        },
                        values: tunisData[client.governorate]!.keys.toList(),
                      ),
                    if (client.city.isNotEmpty) ...[
                      SimpleDropDown(
                        selectedValue: client.region,
                        hint: "Region",
                        onChanged: (region) {
                          setState(() {
                            client.region = region;
                          });
                        },
                        values: tunisData[client.governorate]![client.city]!
                            as List<String>,
                      ),
                    ],
                  ],
                  CustomTextField(
                      hint: txt("Client adress"),
                      controller: adress,
                      keybordType: TextInputType.text,
                      submitted: submitted),
                  const Gap(20),
                  context.userprovider.isLoading
                      ? Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: context.primaryColor,
                                borderRadius: BorderRadius.circular(80)),
                            child: cLoader(size: 40),
                          ),
                        )
                      : Center(
                          child: gradientButton(
                            text:
                                txt(widget.client != null ? "Save" : "Create"),
                            w: context.w - 30,
                            function: () async {
                              setState(() {
                                submitted = true;
                              });

                              if (validateInfo()) {
                                client.firstName = firstNameController.text;
                                client.lastName = lastNameController.text;
                                client.phoneNumber = phoneController.text;
                                client.secondaryPhoneNumber =
                                    secondaryPhoneController.text;
                                client.adress = adress.text;

                                if (widget.client != null) {
                                  await ClientService.clientCollection
                                      .doc(client.id)
                                      .update(client.toMap());
                                  Navigator.pop(context);
                                } else {
                                  final result =
                                      await ClientService.addClient(client);
                                  if (result == 'true') {
                                    Navigator.pop(context);
                                  } else {
                                    popup(context,
                                        cancel: false, description: result);
                                  }
                                }
                              }
                            },
                          ),
                        ),
                  if (widget.client != null &&
                      context.currentUser.role == Role.expeditor)
                    Center(
                      child: gradientButton(
                        text: txt("Delete"),
                        w: context.w - 30,
                        color:darkRed,
                        function: () async {
                          await ClientService.clientCollection
                              .doc(client.id)
                              .delete()
                              .then((value) => Navigator.pop(context));
                        },
                      ),
                    ),
                  const Gap(20)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
