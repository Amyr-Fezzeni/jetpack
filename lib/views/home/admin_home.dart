// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/clients/clients_list.dart';
import 'package:jetpack/views/colis/colis_gtid_list.dart';
import 'package:jetpack/views/users/users_list.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<AdminHomeScreen> {
  String currentFilter = "Runsheet";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const Gap(60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Icon(
                        Icons.menu,
                        color: context.invertedColor.withOpacity(.7),
                        size: 30,
                      ),
                    ),
                    const Gap(10),
                    logoWidget(size: 100),
                    const Spacer(),
                    profileIcon(url: context.currentUser.photo)
                  ],
                ),
                const Gap(20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    card(Icons.people, 'Admin',
                        const UsersListScreen(role: Role.admin)),
                    card(Icons.people_outline_outlined, 'Epeditor',
                        const UsersListScreen(role: Role.expeditor)),
                    card(Icons.people_outline, 'Delivery',
                        const UsersListScreen(role: Role.delivery)),
                    card(Icons.local_shipping_rounded, 'Colis',
                        const ColisGridList()),
                    card(Icons.people_rounded, 'Client',
                        const ClientListScreen()),
                  ],
                ),
                const Gap(80)
              ],
            )),
      ),
    );
  }
}

Widget card(IconData icon, String title, Widget screen) {
  return Builder(builder: (context) {
    return SizedBox(
      width: context.w * .5 - 30,
      height: context.w * .5 - 30,
      child: InkWell(
        onTap: () => context.moveTo(screen),
        child: Card(
          color: context.bgcolor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(bigRadius),
                      color: context.primaryColor.withOpacity(.1)),
                  child: Icon(icon, color: context.iconColor, size: 25),
                ),
              ),
              const Gap(10),
              Txt(title, bold: true)
            ],
          ),
        ),
      ),
    );
  });
}
