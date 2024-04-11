// ignore_for_file: use_build_context_synchronously
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/data%20picker/pick_client.dart';
import 'package:jetpack/views/widgets/data%20picker/pick_delivery.dart';
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
  final formkey = GlobalKey<FormState>();
  TextEditingController items = TextEditingController();
  TextEditingController comment = TextEditingController();
  TextEditingController price = TextEditingController();

  bool submitted = false;
  bool loading = false;
  late Colis colis;
  bool validateInfo() {
    List<bool> validators = [];
    validators.addAll([
      colis.clientId.isNotEmpty,
      colis.deliveryId.isNotEmpty,
      double.tryParse(items.text) != null && double.tryParse(items.text)! >= 0,
      double.tryParse(price.text) != null && double.tryParse(price.text)! >= 0,
    ]);
    return !validators.any((v) => v == false);
  }

  @override
  void initState() {
    super.initState();

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
          status: ColisStatus.inProgress.name,
          clientId: '',
          expeditorId: context.userprovider.currentUser!.id,
          deliveryId: '',
          deliveryName: '',
        );

    comment.text = colis.phone1;
    price.text = colis.price.toString();
    items.text = colis.numberOfItems.toString();
    if (widget.colis == null) {
      checkBarCodeUniqueId();
    }
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
          child: Form(
            key: formkey,
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
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 15)
                        .copyWith(bottom: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: context.invertedColor.withOpacity(.05),
                      borderRadius: BorderRadius.circular(smallRadius),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final data = await pickClient();
                        if (data != null) {
                          setState(() {
                            colis.name = "${data.firstName} ${data.lastName}";
                            colis.address = data.adress;
                            colis.city = data.city;
                            colis.governorate = data.governorate;
                            colis.phone1 = data.phoneNumber;
                            colis.phone2 = data.secondaryPhoneNumber;
                            colis.clientId = data.id;
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(builder: (context) {
                            return Txt(
                                colis.clientId.isEmpty
                                    ? 'Select client'
                                    : colis.name,
                                bold: colis.clientId.isNotEmpty,
                                color: context.invertedColor.withOpacity(
                                    colis.clientId.isEmpty ? .4 : 1));
                          }),
                          const Spacer(),
                          Icon(
                            Icons.keyboard_arrow_right_sharp,
                            color: context.iconColor,
                            size: 25,
                          )
                        ],
                      ),
                    ),
                  ),
                  if (colis.clientId.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15)
                          .copyWith(bottom: 15),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: context.invertedColor.withOpacity(.05),
                        borderRadius: BorderRadius.circular(smallRadius),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Txt("Client Name", bold: true, extra: ': '),
                              Flexible(child: Txt(colis.name))
                            ],
                          ),
                          Row(
                            children: [
                              Txt("Adress", bold: true, extra: ': '),
                              Flexible(child: Txt(colis.address))
                            ],
                          ),
                          Row(
                            children: [
                              Txt("Governorate", bold: true, extra: ': '),
                              Flexible(child: Txt(colis.governorate))
                            ],
                          ),
                          Row(
                            children: [
                              Txt("City", bold: true, extra: ': '),
                              Flexible(child: Txt(colis.city))
                            ],
                          ),
                          Row(
                            children: [
                              Txt("Phone number", bold: true, extra: ': '),
                              Flexible(child: Txt(colis.phone1))
                            ],
                          ),
                          if (colis.phone2.isNotEmpty)
                            Row(
                              children: [
                                Txt("secondary phone number",
                                    bold: true, extra: ': '),
                                Flexible(child: Txt(colis.phone2))
                              ],
                            ),
                        ],
                      ),
                    ),
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 15)
                        .copyWith(bottom: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: context.invertedColor.withOpacity(.05),
                      borderRadius: BorderRadius.circular(smallRadius),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final data = await pickDelivery();
                        if (data != null) {
                          setState(() {
                            colis.deliveryName = data.getFullName();
                            colis.deliveryId = data.id;
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(builder: (context) {
                            return Txt(
                                colis.deliveryId.isEmpty
                                    ? 'Delivery'
                                    : colis.deliveryName,
                                bold: colis.deliveryId.isNotEmpty,
                                color: context.invertedColor.withOpacity(
                                    colis.deliveryId.isEmpty ? .4 : 1));
                          }),
                          const Spacer(),
                          Icon(
                            Icons.keyboard_arrow_right_sharp,
                            color: context.iconColor,
                            size: 25,
                          )
                        ],
                      ),
                    ),
                  ),
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
                      label: txt("Price"),
                      controller: price,
                      keybordType: TextInputType.number,
                      validator: (value) {
                        try {
                          return double.parse(value.toString()) >= 0
                              ? null
                              : '';
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
                                colis.numberOfItems = int.parse(items.text);
                                colis.price = double.parse(price.text);
                                colis.comment = comment.text;
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
                                    popup(context, "Ok",
                                        cancel: false, description: result);
                                  }
                                }
                              }
                            },
                          ),
                        ),
                  if (widget.colis != null &&
                      colis.id != context.userId &&
                      context.currentUser.role == Role.admin)
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
      ),
    );
  }
}
