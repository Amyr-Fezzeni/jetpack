// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/constants/tunis_data.dart';
import 'package:jetpack/models/sector.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/validators.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/custom_drop_down.dart';
import 'package:jetpack/views/widgets/data%20picker/pick_delivery.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:jetpack/views/widgets/text_field.dart';

class AddSector extends StatefulWidget {
  final Sector? sector;
  const AddSector({super.key, this.sector});

  @override
  State<AddSector> createState() => _AddSectorState();
}

class _AddSectorState extends State<AddSector> {
  final formkey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController region = TextEditingController();

  bool submitted = false;
  bool loading = false;
  late Sector sector;
  bool validateInfo() {
    List<bool> validators = [];
    validators.addAll([]);
    return !validators.any((v) => v == false);
  }

  @override
  void initState() {
    super.initState();

    sector = widget.sector ??
        Sector(
            id: generateId(),
            name: '',
            city: '',
            delivery: {"id": '', "name": ''},
            regions: []);
    name.text = sector.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar(widget.sector != null ? 'Update' : 'Add sector'),
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
                      hint: txt("Sector name"),
                      controller: name,
                      validator: nameValidator,
                      keybordType: TextInputType.name,
                      submitted: submitted),
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
                            sector.delivery = {
                              "id": data.id,
                              "name": data.getFullName()
                            };
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(builder: (context) {
                            return Txt(
                                sector.delivery['name'].isEmpty
                                    ? 'Delivery'
                                    : sector.delivery['name'],
                                bold: !sector.delivery['name'].isEmpty,
                                color: context.invertedColor.withOpacity(
                                    sector.delivery['name'].isEmpty ? .4 : 1));
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
                  CustDropDown<String>(
                      maxListHeight: 150,
                      hintText: txt('City'),
                      defaultSelectedIndex: sector.city.isEmpty
                          ? -1
                          : tunisData.keys.toList().indexOf(sector.city),
                      items: tunisData.keys
                          .map((e) =>
                              CustDropdownMenuItem(value: e, child: Txt(e)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => sector.city = value)),
                  const Gap(15),
                  if (sector.city.isNotEmpty) ...[
                    CustDropDown<String>(
                        maxListHeight: 150,
                        hintText: txt('Governorate'),
                        defaultSelectedIndex: -1,
                        items: tunisData[sector.city]!
                            .keys
                            .map((e) =>
                                CustDropdownMenuItem(value: e, child: Txt(e)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => sector.regions.add(value))),
                    const Gap(15)
                  ],
                 
                  ...sector.regions.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Txt(e, bold: true)),
                                const Spacer(),
                                deleteButton(
                                    function: () => setState(
                                        () => sector.regions.remove(e)))
                              ],
                            ),
                            divider()
                          ],
                        ),
                      )),
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
                                txt(widget.sector != null ? "Save" : "Create"),
                            w: context.w - 30,
                            function: () async {
                              setState(() {
                                submitted = true;
                              });

                              if (validateInfo()) {
                                sector.name = name.text;

                                if (widget.sector != null) {
                                  await SectorService.sectorCollection
                                      .doc(sector.id)
                                      .update(sector.toMap());
                                  Navigator.pop(context);
                                } else {
                                  final result =
                                      await SectorService.addSector(sector);
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
                  if (widget.sector != null &&
                      sector.id != context.userId &&
                      context.currentUser.role == Role.admin)
                    Center(
                      child: gradientButton(
                        text: txt("Delete"),
                        w: context.w - 30,
                        colors: [darkRed, darkRed],
                        function: () async {
                          await SectorService.sectorCollection
                              .doc(sector.id)
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
