import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/users/add_user.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/buttom_navigation_bar.dart';
import 'package:jetpack/views/widgets/text_field.dart';
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
      extendBody: true,
      appBar: appBar('Profile', leading: false),
      backgroundColor: context.bgcolor,
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0).copyWith(top: 10),
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
              const Gap(10),
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
              const Gap(20),

              CustomTextField(
                  label: txt("governorate"),
                  controller: TextEditingController(
                      text: context.currentUser.governorate)),
              CustomTextField(
                  label: txt("City"),
                  controller:
                      TextEditingController(text: context.currentUser.city)),
              CustomTextField(
                  label: txt("Region"),
                  controller:
                      TextEditingController(text: context.currentUser.region)),
              CustomTextField(
                  label: txt("Adress"),
                  controller:
                      TextEditingController(text: context.currentUser.adress)),
              CustomTextField(
                  label: txt("Phone number"),
                  controller: TextEditingController(
                      text: context.currentUser.phoneNumber)),
              if (context.currentUser.secondaryphoneNumber.isNotEmpty)
                CustomTextField(
                    label: txt("Secondary phone number"),
                    controller: TextEditingController(
                        text: context.currentUser.secondaryphoneNumber)),
              CustomTextField(
                  label: txt("Sector"),
                  controller: TextEditingController(
                      text: context.currentUser.sector['name'])),
              const Gap(100)
            ],
          ),
        ),
      ),
    );
  }
}
