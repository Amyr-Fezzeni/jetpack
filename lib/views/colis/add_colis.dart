// ignore_for_file: use_build_context_synchronously
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/constants/tunis_data.dart';
import 'package:jetpack/models/client.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/sector.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/colis_service.dart';
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

class AddColis extends StatefulWidget {
  final Colis? colis;
  const AddColis({super.key, this.colis});

  @override
  State<AddColis> createState() => _AddColisState();
}

class _AddColisState extends State<AddColis> {
  TextEditingController items = TextEditingController();
  TextEditingController comment = TextEditingController();
  TextEditingController price = TextEditingController();
  // client data
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController secondaryPhoneController = TextEditingController();
  TextEditingController adress = TextEditingController();

  bool submitted = false;
  bool loading = false;
  late Colis colis;
  late Client client;
  bool clientExist = false;
  bool validateInfo() {
    List<bool> validators = [];
    validators.addAll([
      colis.deliveryId.isNotEmpty,
      double.tryParse(items.text) != null && double.tryParse(items.text)! >= 0,
      double.tryParse(price.text) != null && double.tryParse(price.text)! >= 0,
    ]);
    return !validators.any((v) => v == false);
  }

  @override
  void initState() {
    super.initState();
    // client

//colis
    colis = widget.colis ??
        Colis(
          id: generateBarCodeId(),
          name: '',
          governorate: '',
          city: '',
          address: '',
          phone1: '',
          phone2: '',
          numberOfItems: 0,
          price: 0,
          isFragile: false,
          exchange: false,
          comment: '',
          openable: false,
          status: ColisStatus.inProgress.name,
          clientId: '',
          expeditorId: context.userprovider.currentUser!.id,
          deliveryId: '',
          deliveryName: '',
        );

    comment.text = colis.phone1;
    price.text = colis.price.toString();
    items.text = colis.numberOfItems.toString();
    //client
    client = Client(
        id: generateId(),
        firstName: '',
        lastName: '',
        adress: '',
        phoneNumber: '',
        secondaryPhoneNumber: '',
        governorate: '',
        city: '');
    firstNameController.text = client.firstName;
    lastNameController.text = client.lastName;
    adress.text = client.adress;
    phoneController.text = client.phoneNumber;
    secondaryPhoneController.text = client.secondaryPhoneNumber;
    if (widget.colis != null) {
      ClientService.clientCollection.doc(colis.clientId).get().then((value) {
        client = Client.fromMap(value.data()!);
        firstNameController.text = client.firstName;
        lastNameController.text = client.lastName;
        adress.text = client.adress;
        phoneController.text = client.phoneNumber;
        secondaryPhoneController.text = client.secondaryPhoneNumber;
        setState(() {});
      });
    }

    if (widget.colis == null) {
      checkBarCodeUniqueId();
    }
  }

  setSector() async {
    final Sector? sector = await SectorService.getSector(client.governorate);
    if (sector == null) {
      setState(() {
        colis.deliveryId = '';
        colis.deliveryName = '';
      });
      await popup(context,
          description: "No sector found with governorate data");
      return;
    }

    setState(() {
      colis.deliveryId = sector.delivery['id'];
      colis.deliveryName = sector.delivery['name'];
    });
  }

  checkBarCodeUniqueId() async {
    String id = colis.id;
    bool existe = true;
    try {
      while (existe) {
        final data = await ColisService.colisCollection.doc(id).get();
        if (!data.exists) {
          setState(() {
            colis.id = id;
          });
          existe = false;
          break;
        }
        id = generateBarCodeId();
      }
    } catch (e) {
      setState(() {
        colis.id = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar(widget.colis != null ? 'Update' : 'Add colis'),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(40),
                Center(
                  child: SizedBox(
                    height: 100,
                    width: 200,
                    child: BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: colis.id,
                      style: context.text,
                      color: context.invertedColor.withOpacity(.7),
                    ),
                  ),
                ),
                const Gap(20),
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 15)
                      .copyWith(bottom: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: context.invertedColor.withOpacity(.05),
                    borderRadius: BorderRadius.circular(smallRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Txt("Id: ",
                          bold: colis.clientId.isNotEmpty,
                          color: context.invertedColor
                              .withOpacity(colis.clientId.isEmpty ? .4 : 1)),
                      Txt(colis.id,
                          bold: colis.clientId.isNotEmpty,
                          color: context.primaryColor),
                    ],
                  ),
                ),
                // Container(
                //   height: 50,
                //   margin: const EdgeInsets.symmetric(horizontal: 15)
                //       .copyWith(bottom: 15),
                //   padding: const EdgeInsets.symmetric(horizontal: 15),
                //   decoration: BoxDecoration(
                //     color: context.invertedColor.withOpacity(.05),
                //     borderRadius: BorderRadius.circular(smallRadius),
                //   ),
                //   child: InkWell(
                //     onTap: () async {
                //       final data = await pickClient();
                //       if (data != null) {
                //         setState(() {
                //           colis.name = "${data.firstName} ${data.lastName}";
                //           colis.address = data.adress;
                //           colis.city = data.city;
                //           colis.governorate = data.governorate;
                //           colis.phone1 = data.phoneNumber;
                //           colis.phone2 = data.secondaryPhoneNumber;
                //           colis.clientId = data.id;
                //         });
                //       }
                //     },
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Builder(builder: (context) {
                //           return Txt(
                //               colis.clientId.isEmpty
                //                   ? 'Select client'
                //                   : colis.name,
                //               bold: colis.clientId.isNotEmpty,
                //               color: context.invertedColor.withOpacity(
                //                   colis.clientId.isEmpty ? .4 : 1));
                //         }),
                //         const Spacer(),
                //         Icon(
                //           Icons.keyboard_arrow_right_sharp,
                //           color: context.iconColor,
                //           size: 25,
                //         )
                //       ],
                //     ),
                //   ),
                // ),

                // if (colis.clientId.isNotEmpty)
                //   Container(
                //     margin: const EdgeInsets.symmetric(horizontal: 15)
                //         .copyWith(bottom: 15),
                //     padding: const EdgeInsets.symmetric(
                //         horizontal: 15, vertical: 10),
                //     decoration: BoxDecoration(
                //       color: context.invertedColor.withOpacity(.05),
                //       borderRadius: BorderRadius.circular(smallRadius),
                //     ),
                //     child: Column(
                //       children: [
                //         Row(
                //           children: [
                //             Txt("Client Name", bold: true, extra: ': '),
                //             Flexible(child: Txt(colis.name))
                //           ],
                //         ),
                //         Row(
                //           children: [
                //             Txt("Adress", bold: true, extra: ': '),
                //             Flexible(child: Txt(colis.address))
                //           ],
                //         ),
                //         Row(
                //           children: [
                //             Txt("Governorate", bold: true, extra: ': '),
                //             Flexible(child: Txt(colis.governorate))
                //           ],
                //         ),
                //         Row(
                //           children: [
                //             Txt("City", bold: true, extra: ': '),
                //             Flexible(child: Txt(colis.city))
                //           ],
                //         ),
                //         Row(
                //           children: [
                //             Txt("Phone number", bold: true, extra: ': '),
                //             Flexible(child: Txt(colis.phone1))
                //           ],
                //         ),
                //         if (colis.phone2.isNotEmpty)
                //           Row(
                //             children: [
                //               Txt("secondary phone number",
                //                   bold: true, extra: ': '),
                //               Flexible(child: Txt(colis.phone2))
                //             ],
                //           ),
                //       ],
                //     ),
                //   ),
                // Container(
                //   height: 50,
                //   margin: const EdgeInsets.symmetric(horizontal: 15)
                //       .copyWith(bottom: 15),
                //   padding: const EdgeInsets.symmetric(horizontal: 15),
                //   decoration: BoxDecoration(
                //     color: context.invertedColor.withOpacity(.05),
                //     borderRadius: BorderRadius.circular(smallRadius),
                //   ),
                //   child: InkWell(
                //     onTap: () async {
                //       final data = await pickDelivery();
                //       if (data != null) {
                //         setState(() {
                //           colis.deliveryName = data.getFullName();
                //           colis.deliveryId = data.id;
                //         });
                //       }
                //     },
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Builder(builder: (context) {
                //           return Txt(
                //               colis.deliveryId.isEmpty
                //                   ? 'Delivery'
                //                   : colis.deliveryName,
                //               bold: colis.deliveryId.isNotEmpty,
                //               color: context.invertedColor.withOpacity(
                //                   colis.deliveryId.isEmpty ? .4 : 1));
                //         }),
                //         const Spacer(),
                //         Icon(
                //           Icons.keyboard_arrow_right_sharp,
                //           color: context.iconColor,
                //           size: 25,
                //         )
                //       ],
                //     ),
                //   ),
                // ),

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
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                          hint: txt("Phone number"),
                          marginV: 0,
                          controller: phoneController,
                          keybordType: TextInputType.phone,
                          submitted: submitted),
                    ),
                    const Gap(10),
                    gradientButton(
                        function: () {
                          ClientService.clientCollection
                              .where('phoneNumber',
                                  isEqualTo: phoneController.text)
                              .get()
                              .then((data) async {
                            if (data.docs.isEmpty) {
                              popup(context,
                                  cancel: false,
                                  description:
                                      "No Client found with this phone number '${phoneController.text}'");
                            } else {
                              final clientData =
                                  Client.fromMap(data.docs.first.data());
                              customPopup(context, Builder(builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                              horizontal: 15)
                                          .copyWith(bottom: 15),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: context.invertedColor
                                            .withOpacity(.05),
                                        borderRadius:
                                            BorderRadius.circular(smallRadius),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Txt("Client Name",
                                                  bold: true, extra: ': '),
                                              Flexible(
                                                  child: Txt(
                                                      '${clientData.firstName} ${clientData.lastName}'))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Txt("Adress",
                                                  bold: true, extra: ': '),
                                              Flexible(
                                                  child: Txt(clientData.adress))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Txt("Governorate",
                                                  bold: true, extra: ': '),
                                              Flexible(
                                                  child: Txt(
                                                      clientData.governorate))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Txt("City",
                                                  bold: true, extra: ': '),
                                              Flexible(
                                                  child: Txt(clientData.city))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Txt("Phone number",
                                                  bold: true, extra: ': '),
                                              Flexible(
                                                  child: Txt(
                                                      clientData.phoneNumber))
                                            ],
                                          ),
                                          if (clientData
                                              .secondaryPhoneNumber.isNotEmpty)
                                            Row(
                                              children: [
                                                Txt("secondary phone number",
                                                    bold: true, extra: ': '),
                                                Flexible(
                                                    child: Txt(clientData
                                                        .secondaryPhoneNumber))
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    gradientButton(
                                        function: () {
                                          client = clientData;
                                          firstNameController.text =
                                              client.firstName;
                                          lastNameController.text =
                                              client.lastName;
                                          secondaryPhoneController.text =
                                              client.secondaryPhoneNumber;
                                          adress.text = client.adress;
                                          clientExist = true;

                                          Navigator.pop(context);
                                          setState(() {});
                                          setSector();
                                        },
                                        text: "Confirm")
                                  ],
                                );
                              }));
                            }
                          });
                        },
                        text: "Check"),
                    const Gap(15)
                  ],
                ),
                const Gap(10),
                CustomTextField(
                    hint: txt("Secondary phone number"),
                    controller: secondaryPhoneController,
                    keybordType: TextInputType.phone,
                    submitted: submitted),

                SimpleDropDown(
                  selectedValue: client.city,
                  hint: "City",
                  onChanged: (city) => setState(() {
                    client.city = city;
                    colis.city = city;
                  }),
                  values: tunisData.keys.toList(),
                ),
                if (client.city.isNotEmpty) ...[
                  SimpleDropDown(
                    selectedValue: client.governorate,
                    hint: "Governorate",
                    onChanged: (governorate) {
                      setState(() {
                        client.governorate = governorate;
                        colis.governorate = governorate;
                      });
                      setSector();
                    },
                    values: tunisData[client.city]!.keys.toList(),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15)
                        .copyWith(bottom: 15),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.invertedColor.withOpacity(.05),
                      borderRadius: BorderRadius.circular(smallRadius),
                    ),
                    child: Row(
                      children: [
                        Txt(
                            colis.deliveryName.isEmpty
                                ? "No sector found"
                                : "Delivery: ${colis.deliveryName}",
                            color: context.invertedColor.withOpacity(
                                colis.deliveryName.isEmpty ? .4 : 1))
                      ],
                    ),
                  )
                ],
                CustomTextField(
                    hint: txt("Client adress"),
                    controller: adress,
                    keybordType: TextInputType.text,
                    submitted: submitted),

                // colis
                CustomTextField(
                    hint: txt("Comment"),
                    controller: comment,
                    keybordType: TextInputType.text,
                    submitted: submitted),
                CustomTextField(
                    hint: txt("0"),
                    label: txt("Items"),
                    controller: items,
                    keybordType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      try {
                        return int.parse(value.toString()) >= 0 ? null : '';
                      } catch (e) {
                        return txt('Invalid number');
                      }
                    },
                    submitted: submitted),
                CustomTextField(
                    hint: txt("0"),
                    label: txt("Price (Dt)"),
                    controller: price,
                    keybordType: TextInputType.number,
                    validator: (value) {
                      try {
                        return double.parse(value.toString()) >= 0 ? null : '';
                      } catch (e) {
                        return txt('Invalid number');
                      }
                    },
                    submitted: submitted),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt("Fragile", bold: true),
                      const Gap(10),
                      Wrap(
                        children: [
                          checkBox(colis.isFragile, txt('Yes'),
                              () => setState(() => colis.isFragile = true)),
                          checkBox(!colis.isFragile, txt('No'),
                              () => setState(() => colis.isFragile = false)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt("Exchange", bold: true),
                      const Gap(10),
                      Wrap(
                        children: [
                          checkBox(colis.exchange, txt('Yes'),
                              () => setState(() => colis.exchange = true)),
                          checkBox(!colis.exchange, txt('No'),
                              () => setState(() => colis.exchange = false)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt("Openable", bold: true),
                      const Gap(10),
                      Wrap(
                        children: [
                          checkBox(colis.openable, txt('Yes'),
                              () => setState(() => colis.openable = true)),
                          checkBox(!colis.openable, txt('No'),
                              () => setState(() => colis.openable = false)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(20),
                if (widget.colis != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15)
                        .copyWith(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Txt("Status", bold: true),
                        const Gap(10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ...ColisStatus.values.map((status) => checkBox(
                                colis.status == status.name,
                                txt(status.name),
                                () => setState(
                                    () => colis.status = status.name))),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                          text: txt(widget.colis != null ? "Save" : "Create"),
                          w: context.w - 30,
                          function: () async {
                            setState(() {
                              submitted = true;
                            });

                            if (validateInfo()) {
                              //client
                              client.firstName = firstNameController.text;
                              client.lastName = lastNameController.text;
                              client.phoneNumber = phoneController.text;
                              client.secondaryPhoneNumber =
                                  secondaryPhoneController.text;
                              client.adress = adress.text;

                              //colis
                              colis.clientId = client.id;
                              colis.name = client.getFullName();
                              colis.address = adress.text;
                              colis.phone1 = client.phoneNumber;
                              colis.phone2 = client.secondaryPhoneNumber;

                              colis.numberOfItems = int.parse(items.text);
                              colis.price = double.parse(price.text);
                              colis.comment = comment.text;

                              if (!clientExist) {
                                ClientService.addClient(client);
                              } else {
                                ClientService.clientCollection
                                    .doc(client.id)
                                    .update(client.toMap());
                              }

                              if (widget.colis != null) {
                                await ColisService.colisCollection
                                    .doc(colis.id)
                                    .update(colis.toMap());
                                Navigator.pop(context);
                              } else {
                                final result =
                                    await ColisService.addColis(colis);
                                if (result == 'true') {
                                  Navigator.pop(context);
                                } else {
                                  popup(context,
                                      cancel: false, description: result);
                                }
                              }
                            } else {
                              popup(context,
                                  cancel: false,
                                  description:
                                      "Please complete required fields!");
                            }
                          },
                        ),
                      ),
                if (widget.colis != null &&
                    colis.id != context.userId &&
                    context.currentUser.role == Role.expeditor)
                  Center(
                    child: gradientButton(
                      text: txt("Delete"),
                      w: context.w - 30,
                      colors: [darkRed, darkRed],
                      function: () async {
                        await ColisService.colisCollection
                            .doc(colis.id)
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
    );
  }
}
