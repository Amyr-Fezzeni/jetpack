// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/constants/tunis_data.dart';
import 'package:jetpack/models/agency.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/validators.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/custom_drop_down.dart';
import 'package:jetpack/views/widgets/data%20picker/pick_admin.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:jetpack/views/widgets/text_field.dart';

class AddAgency extends StatefulWidget {
  final Agency? agency;
  const AddAgency({super.key, this.agency});

  @override
  State<AddAgency> createState() => _AddAgencyState();
}

class _AddAgencyState extends State<AddAgency> {
  final formkey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController adress = TextEditingController();
  TextEditingController employee = TextEditingController();

  bool submitted = false;
  bool loading = false;
  late Agency agency;
  bool validateInfo() {
    List<bool> validators = [];
    validators.addAll([]);
    return !validators.any((v) => v == false);
  }

  @override
  void initState() {
    super.initState();

    agency = widget.agency ??
        Agency(
            id: generateId(),
            name: '',
            adress: '',
            agencyLead: '',
            adminId: '',
            employeesNumber: 0,
            governorate: '',
            citys: [],
            deliveryMen: []);
    name.text = agency.name;
    adress.text = agency.adress;
    employee.text = agency.employeesNumber.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar(widget.agency != null ? 'Update' : 'Add agency'),
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
                      hint: txt("Agency name"),
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
                        final data = await pickAdmin();
                        if (data != null) {
                          setState(() {
                            agency.adminId = data.id;
                            agency.agencyLead = data.getFullName();
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(builder: (context) {
                            return Txt(
                                agency.agencyLead.isEmpty
                                    ? 'Agency admin'
                                    : agency.agencyLead,
                                bold: agency.agencyLead.isNotEmpty,
                                color: context.invertedColor.withOpacity(
                                    agency.agencyLead.isEmpty ? .4 : 1));
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
                      hint: txt("Address"),
                      controller: adress,
                      keybordType: TextInputType.text,
                      submitted: submitted),
                  ...[
                    SimpleDropDown(
                      selectedValue: agency.governorate,
                      hint: "Governorate",
                      onChanged: (governorate) =>
                          setState(() => agency.governorate = governorate),
                      values: tunisData.keys.toList(),
                    ),
                    if (agency.governorate.isNotEmpty)
                      SimpleDropDown(
                        selectedValue: '',
                        hint: "City",
                        onChanged: (city) {
                          agency.citys.contains(city)
                              ? null
                              : setState(() => agency.citys.add(city));
                        },
                        values: tunisData[agency.governorate]!.keys.toList(),
                      ),
                  ],
                  ...agency.citys.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Txt(e, bold: true)),
                                const Spacer(),
                                deleteButton(
                                    function: () =>
                                        setState(() => agency.citys.remove(e)))
                              ],
                            ),
                            divider()
                          ],
                        ),
                      )),
                  const Gap(20),
                  CustomTextField(
                      hint: txt("0"),
                      label: txt("Employee"),
                      controller: employee,
                      keybordType: TextInputType.number,
                      validator: (value) {
                        try {
                          return int.parse(value.toString()) >= 0 ? null : '';
                        } catch (e) {
                          return txt('Invalid number');
                        }
                      },
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
                                txt(widget.agency != null ? "Save" : "Create"),
                            w: context.w - 30,
                            function: () async {
                              setState(() {
                                submitted = true;
                              });

                              if (validateInfo()) {
                                agency.name = name.text;
                                agency.adress = adress.text;
                                agency.employeesNumber =
                                    int.parse(employee.text);

                                if (widget.agency != null) {
                                  await AgencyService.agencyCollection
                                      .doc(agency.id)
                                      .update(agency.toMap());
                                  Navigator.pop(context);
                                } else {
                                  final result =
                                      await AgencyService.addAgency(agency);
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
                  if (widget.agency != null &&
                      agency.id != context.userId &&
                      context.currentUser.role == Role.admin)
                    Center(
                      child: gradientButton(
                        text: txt("Delete"),
                        w: context.w - 30,
                        color: darkRed,
                        function: () async {
                          await AgencyService.agencyCollection
                              .doc(agency.id)
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
