// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/constants/tunis_data.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/sector.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/agency_service.dart';
import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/validators.dart';
import 'package:jetpack/views/widgets/custom_drop_down.dart';
import 'package:jetpack/views/widgets/data%20picker/pick_agency.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:jetpack/views/widgets/text_field.dart';

class AddUser extends StatefulWidget {
  final Role role;
  final UserModel? user;
  const AddUser({super.key, this.user, required this.role});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final formkey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController adressController = TextEditingController();
  TextEditingController cinController = TextEditingController();

  TextEditingController secondaryPhoneController = TextEditingController(); //
  TextEditingController agencyController = TextEditingController(); //
  TextEditingController matriculeController = TextEditingController(); //
  TextEditingController fiscalMatriculeController = TextEditingController(); //
  TextEditingController price = TextEditingController(); //
  TextEditingController returnPriceController = TextEditingController(); //

  bool submitted = false;
  bool loading = false;
  String city = '';
  late UserModel user;
  bool validateInfo() {
    List<bool> validators = [];
    validators.addAll([
      nameValidator(firstNameController.text) == null,
      emailValidator(emailController.text) == null,
      ((passwordController.text.isEmpty && widget.user != null) ||
          passwordValidator(passwordController.text) == null),
      cinController.text.isNotEmpty && cinController.text.length == 8
    ]);
    if (user.role == Role.delivery) {
      validators.add(user.sector['id'].isNotEmpty);
      validators.add(matriculeController.text.trim().isNotEmpty);
      validators.add(double.parse(price.text) > 0);
    }
    if (user.role == Role.expeditor) {
      validators.add(double.parse(price.text) > 0);
      validators.add(double.parse(returnPriceController.text) > 0);
    }
    if (user.role == Role.admin) {}
    return !validators.any((v) => v == false);
  }

  List<Sector> sectors = [];
  Map<String, dynamic> agency = {"id": '', "name": ''};

  @override
  void initState() {
    super.initState();

    user = widget.user ??
        UserModel(
            id: generateId(),
            cin: '',
            firstName: '',
            lastName: '',
            email: '',
            agency: {"id": '', "name": ''},
            sector: {"id": '', "name": ''},
            role: widget.role,
            gender: Gender.male,
            password: '',
            dateCreated: DateTime.now());
    firstNameController.text = user.firstName;
    lastNameController.text = user.lastName;
    emailController.text = user.email;
    phoneController.text = user.phoneNumber;
    cinController.text = user.cin;
    adressController.text = user.adress;
    secondaryPhoneController.text = user.secondaryphoneNumber;

    matriculeController.text = user.matricule;
    fiscalMatriculeController.text = user.fiscalMatricule;
    price.text = user.price > 0 ? user.price.toString() : '';
    returnPriceController.text =
        user.returnPrice > 0 ? user.returnPrice.toString() : ''.toString();
    SectorService.sectorCollection.get().then((docs) {
      sectors = docs.docs.map((e) => Sector.fromMap(e.data())).toList();
      setState(() {});
    });
  }

  setSector() async {
    final Sector? sector = await SectorService.getSector(user.region);
    if (sector == null) {
      setState(() {
        user.sector = {"id": '', "name": ''};
      });
      await popup(context,
          cancel: false,
          description: txt("No sector found with governorate data"));
      return;
    }

    setState(() {
      user.sector = {"id": sector.id, "name": sector.name};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar(widget.user != null
          ? 'Update'
          : 'Add ${widget.role == Role.admin ? 'Admin' : widget.role == Role.expeditor ? 'Expeditor' : 'Delivery'}'),
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
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: context.invertedColor.withOpacity(.3)),
                          borderRadius: BorderRadius.circular(100),
                          color: context.bgcolor,
                          boxShadow: defaultShadow),
                      child: InkWell(
                        onTap: () async {
                          setState(() => loading = true);
                          try {
                            final file = await pickImage();
                            if (file != null) {
                              user.photo = await UserService.uploadImage(
                                  File(file.path!),
                                  folder: '${user.id}/profile',
                                  type: file.extension.toString());
                            }
                            setState(() => loading = false);
                          } catch (e) {
                            setState(() => loading = false);
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: loading
                              ? Center(child: cLoader())
                              : user.photo.isNotEmpty
                                  ? Image.network(user.photo, fit: BoxFit.cover)
                                  : Image.asset(
                                      profileImg,
                                      fit: BoxFit.cover,
                                    ),
                        ),
                      ),
                    ),
                  ),
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
                    validator: (value) {
                      bool nameValid = RegExp(r"^[a-zA-Z]")
                              .hasMatch(value ?? " ") ||
                          !RegExp("^[\u0000-\u007F]+\$").hasMatch(value ?? " ");

                      return value.toString().isEmpty
                          ? txt("Please enter your Last name")
                          : value.toString().length < 3
                              ? txt('Too short')
                              : !nameValid
                                  ? txt('Wrong name format')
                                  : null;
                    },
                    keybordType: TextInputType.name,
                    submitted: submitted,
                  ),
                  CustomTextField(
                      hint: txt("Cin"),
                      controller: cinController,
                      keybordType: TextInputType.number,
                      validator: (p0) => cinController.text.isNotEmpty &&
                              cinController.text.length == 8
                          ? null
                          : txt('Cin is required'),
                      submitted: submitted),
                  CustomTextField(
                      hint: txt("Phone number"),
                      controller: phoneController,
                      validator: phoneNumberValidator,
                      keybordType: TextInputType.number,
                      submitted: submitted),
                  if ([Role.expeditor].contains(user.role))
                    CustomTextField(
                        hint: txt("Secondary phone number (optional)"),
                        controller: secondaryPhoneController,
                        validator: (value) => value.toString().length == 8 ||
                                value.toString().isEmpty
                            ? null
                            : txt('Phone number invalid'),
                        keybordType: TextInputType.number,
                        submitted: submitted),
                  CustomTextField(
                    hint: txt("Email"),
                    controller: emailController,
                    validator: emailValidator,
                    keybordType: TextInputType.emailAddress,
                    submitted: submitted,
                  ),
                  CustomTextField(
                      hint: txt("Password (8 or more characters)"),
                      controller: passwordController,
                      validator: widget.user != null
                          ? (value) => value.toString().isEmpty ||
                                  value.toString().length >= 8
                              ? null
                              : ''
                          : passwordValidator,
                      submitted: submitted),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Txt("Gender", bold: true),
                        const Gap(10),
                        Wrap(
                          children: [
                            checkBox(
                                user.gender.name == 'male',
                                txt('Male'),
                                () =>
                                    setState(() => user.gender = Gender.male)),
                            checkBox(
                                user.gender.name == 'female',
                                txt('Female'),
                                () => setState(
                                    () => user.gender = Gender.female)),
                            checkBox(
                                user.gender.name == 'other',
                                txt('Other'),
                                () =>
                                    setState(() => user.gender = Gender.other)),
                          ],
                        ),
                        const Gap(20),
                        Txt('Birthday', bold: true, extra: '*'),
                        const Gap(5),
                        InkWell(
                          onTap: () async {
                            final data = await datePopup(
                                title: 'Birthday',
                                day: true,
                                initDate: user.birthday,
                                maxDate: DateTime.now()
                                    .add(const Duration(seconds: 1)));
                            if (data != null) {
                              setState(() {
                                user.birthday = data;
                              });
                            }
                          },
                          child: Container(
                            height: 50,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: context.invertedColor.withOpacity(.05),
                              borderRadius: BorderRadius.circular(smallRadius),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Txt(
                                    user.birthday != null
                                        ? getDate(user.birthday)
                                        : '--/ --/ ----',
                                    translate: false),
                                svgImage(calendar)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(5),
                  // if ([Role.delivery, Role.expeditor].contains(user.role))
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
                        final data = await pickAgency();
                        if (data != null) {
                          setState(() {
                            user.agency = {"id": data.id, "name": data.name};
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(builder: (context) {
                            bool agencyEmpty =
                                user.agency == null || user.agency!['id'] == '';
                            return Txt(
                                agencyEmpty
                                    ? txt('Agency')
                                    : user.agency!['name'],
                                bold: !agencyEmpty,
                                color: context.invertedColor
                                    .withOpacity(agencyEmpty ? .4 : 1),
                                translate: false);
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
                  // if ([Role.delivery].contains(user.role))

                  ...[
                    SimpleDropDown(
                      selectedValue: user.governorate,
                      hint: "Governorate",
                      onChanged: (governorate) => setState(() {
                        user.governorate = governorate;
                        user.city = '';
                        user.region = '';
                      }),
                      values: tunisData.keys.toList(),
                    ),
                    if (user.governorate.isNotEmpty)
                      SimpleDropDown(
                        selectedValue: user.city,
                        hint: "City",
                        onChanged: (city) {
                          setState(() {
                            user.city = city;
                            user.region = '';
                          });
                        },
                        values: tunisData[user.governorate]!.keys.toList(),
                      ),
                    if (user.city.isNotEmpty) ...[
                      SimpleDropDown(
                        selectedValue: user.region,
                        hint: "Region",
                        onChanged: (region) {
                          setState(() {
                            user.region = region;
                          });
                          setSector();
                        },
                        values: tunisData[user.governorate]![user.city]!
                            as List<String>,
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
                                user.sector['name'].isEmpty
                                    ? txt("No sector found")
                                    : "${txt('Sector')}: ${user.sector['name']}",
                                color: context.invertedColor.withOpacity(
                                    user.sector['name'].isEmpty ? .4 : 1),
                                translate: false)
                          ],
                        ),
                      )
                    ],
                  ],
                  CustomTextField(
                      hint: txt("Adress"),
                      controller: adressController,
                      submitted: submitted),
                  if ([Role.delivery].contains(user.role))
                    CustomTextField(
                        hint: txt("Matricule"),
                        controller: matriculeController,
                        submitted: submitted),
                  if ([Role.expeditor].contains(user.role))
                    CustomTextField(
                        hint: txt("Fiscal Matricule (optional)"),
                        controller: fiscalMatriculeController,
                        submitted: submitted),
                  if ([Role.expeditor, Role.delivery].contains(user.role))
                    CustomTextField(
                        hint: txt("0"),
                        controller: price,
                        label: txt("Price"),
                        validator: priceValidator,
                        keybordType: TextInputType.number,
                        submitted: submitted),
                  if ([Role.expeditor].contains(user.role))
                    CustomTextField(
                        hint: txt("0"),
                        label: txt("Return price"),
                        controller: returnPriceController,
                        keybordType: TextInputType.number,
                        validator: priceValidator,
                        submitted: submitted),
                  if (widget.user != null &&
                      user.id != context.userId &&
                      context.currentUser.role == Role.admin)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Txt("Account status", bold: true),
                        ),
                        const Gap(10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Wrap(
                            children: [
                              checkBox(
                                  user.status.name == 'active',
                                  txt('Active'),
                                  () => setState(
                                      () => user.status = UserStatus.active)),
                              checkBox(
                                  user.status.name == 'banned',
                                  txt('Banned'),
                                  () => setState(
                                      () => user.status = UserStatus.banned)),
                              checkBox(
                                  user.status.name == 'disabled',
                                  txt('Disabled'),
                                  () => setState(
                                      () => user.status = UserStatus.disabled)),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                            text: txt(widget.user != null ? "Save" : "Create"),
                            w: context.w - 30,
                            function: () async {
                              setState(() {
                                submitted = true;
                              });

                              if (validateInfo()) {
                                user.firstName = firstNameController.text;
                                user.lastName = lastNameController.text;
                                user.email = emailController.text;
                                user.cin = cinController.text;
                                user.phoneNumber = phoneController.text;
                                if (passwordController.text.isNotEmpty) {
                                  user.password =
                                      generateMD5(passwordController.text);
                                }

                                user.secondaryphoneNumber =
                                    secondaryPhoneController.text;
                                user.adress = adressController.text;
                                user.matricule = matriculeController.text;
                                user.fiscalMatricule =
                                    fiscalMatriculeController.text;
                                try {
                                  user.price = double.parse(price.text);
                                  user.returnPrice =
                                      double.parse(returnPriceController.text);
                                } on Exception {
                                  null;
                                }

                                if (widget.user != null) {
                                  await UserService.userCollection
                                      .doc(user.id)
                                      .update(user.toMap());
                                  Navigator.pop(context);
                                } else {
                                  final result =
                                      await UserService.addUser(user);
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
                  if (widget.user != null &&
                      user.id != context.userId &&
                      context.currentUser.role == Role.admin)
                    Center(
                      child: gradientButton(
                        text: txt("Delete"),
                        w: context.w - 30,
                        color: darkRed,
                        function: () async {
                          await UserService.userCollection
                              .doc(user.id)
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
