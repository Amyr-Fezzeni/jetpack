import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/users/add_user.dart';
import 'package:jetpack/views/widgets/loader.dart';
// import '../../constants/constants.dart';
import '../../services/util/language.dart';
import '../../services/user_service.dart';
import '../../views/widgets/bottuns.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool showPublic = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      extendBodyBehindAppBar: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 40),
          child: Column(
            children: [
              // if (context.currentUser.role == Role.admin)
              Align(
                alignment: Alignment.bottomRight,
                child: borderButton(
                    text: 'Edit Informations',
                    opacity: 0,
                    textColor: context.primaryColor,
                    function: () => context.moveTo(AddUser(
                        role: context.userprovider.currentUser!.role,
                        user: context.userprovider.currentUser))),
              ),
              const Gap(40),
              Center(
                child: profileIcon(
                  size: 150,
                  url: context.currentUser.photo,
                  ontap: () async {
                    final file = await pickImage();
                    if (file == null) return;

                    await UserService.uploadUserImage(
                        await UserService.uploadImage(
                            File(file.path.toString()),
                            folder: 'profile',
                            type: file.extension.toString()));
                  },
                ),
              ),
              Txt(context.currentUser.getFullName(), size: 20, bold: true),
              const Gap(30),
              Row(
                children: [
                  Txt("Governorate", bold: true, extra: ': '),
                  Flexible(child: Txt(context.currentUser.governorate))
                ],
              ),
              Row(
                children: [
                  Txt("City", bold: true, extra: ': '),
                  Flexible(child: Txt(context.currentUser.city))
                ],
              ),
              Row(
                children: [
                  Txt("Region", bold: true, extra: ': '),
                  Flexible(child: Txt(context.currentUser.region))
                ],
              ),
              Row(
                children: [
                  Txt("Adress", bold: true, extra: ': '),
                  Flexible(child: Txt(context.currentUser.adress))
                ],
              ),
              Row(
                children: [
                  Txt("Phone number", bold: true, extra: ': '),
                  Flexible(child: Txt(context.currentUser.phoneNumber))
                ],
              ),
              if (context.currentUser.secondaryphoneNumber.isNotEmpty)
                Row(
                  children: [
                    Txt("secondary phone number", bold: true, extra: ': '),
                    Flexible(
                        child: Txt(context.currentUser.secondaryphoneNumber))
                  ],
                ),
              divider(),
              Row(
                children: [
                  Txt("Sector", bold: true, extra: ': '),
                  Flexible(child: Txt(context.currentUser.sector['name']))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
