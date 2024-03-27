import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/loader.dart';
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
    Widget tabItem({required String lable, required bool status}) {
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => showPublic = status),
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: showPublic == status
                            ? context.primaryColor
                            : Colors.grey,
                        width: 2))),
            height: 40,
            child: Center(
              child: Txt(
                lable,
                bold: showPublic == status,
                // size: 20,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.bgcolor,
      extendBodyBehindAppBar: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 40),
          child: Column(
            children: [
              SizedBox(
                width: 150,
                child: Center(
                  child: Stack(
                    children: [
                      profileIcon(
                        size: 150,
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
                      // Positioned(
                      //     top: 5,
                      //     right: 5,
                      //     child: InkWell(
                      //       onTap: () async {
                      //         final file = await pickImage();
                      //         if (file == null) return;

                      //         await UserService.uploadUserImage(
                      //             await UserService.uploadImage(
                      //                 File(file.path.toString()),
                      //                 folder: 'profile',
                      //                 type: file.extension.toString()));
                      //       },
                      //       child: Container(
                      //         padding: const EdgeInsets.all(5),
                      //         decoration: BoxDecoration(
                      //             boxShadow: defaultShadow,
                      //             color: red,
                      //             borderRadius: BorderRadius.circular(100)),
                      //         child: const Icon(Icons.camera_alt_outlined,
                      //             color: Colors.white, size: 25),
                      //       ),
                      //     ))
                    ],
                  ),
                ),
              ),
              Txt(context.currentUser.getFullName(), size: 20, bold: true),
              const Gap(30),
              CustomTextField(
                hint: txt('Search'),
                controller: TextEditingController(),
                leadingIcon: Icon(Icons.search,
                    color: context.invertedColor.withOpacity(.7), size: 25),
                icon: pngIcon(
                  filterIcon,
                  size: 25,
                  function: () {},
                ),
                height: 50,
              ),
              const Gap(20),
              Row(
                children: [
                  tabItem(lable: txt('Public'), status: true),
                  tabItem(lable: txt('Private'), status: false),
                ],
              ),
              const Gap(10),
              showPublic
                  ? SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 0,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        children: List.generate(
                          15,
                          (index) => card(),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 0,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        children: List.generate(
                          5,
                          (index) => card(),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
