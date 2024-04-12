// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/agency.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/validators.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
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
  TextEditingController lead = TextEditingController();
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
            employeesNumber: 0,
            deliveryMen: []);
    name.text = agency.name;
    lead.text = agency.agencyLead;
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
                  CustomTextField(
                      hint: txt("Agency lead"),
                      controller: lead,
                      keybordType: TextInputType.name,
                      submitted: submitted),
                  CustomTextField(
                      hint: txt("Agency adress"),
                      controller: adress,
                      keybordType: TextInputType.text,
                      submitted: submitted),
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
                                agency.agencyLead = lead.text;
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
                        colors: [darkRed, darkRed],
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
