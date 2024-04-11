import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/users/add_user.dart';
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
          padding:
              const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 40),
          child: Column(
            children: [
              if (context.currentUser.role == Role.admin)
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
            ],
          ),
        ),
      ),
    );
  }
}
