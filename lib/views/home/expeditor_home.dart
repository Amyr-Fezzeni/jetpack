import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/agency/agency_list.dart';
import 'package:jetpack/views/clients/clients_list.dart';
import 'package:jetpack/views/colis/colis_list.dart';
import 'package:jetpack/views/home/admin_home.dart';
import 'package:jetpack/views/users/users_list.dart';
import 'package:jetpack/views/widgets/bottuns.dart';

class ExpeditorHomeScreen extends StatefulWidget {
  const ExpeditorHomeScreen({super.key});

  @override
  State<ExpeditorHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ExpeditorHomeScreen> {
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
                const Gap(40),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 45,
                    width: 45,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        boxShadow: defaultShadow,
                        borderRadius: BorderRadius.circular(smallRadius),
                        color: context.bgcolor),
                    child: Icon(Icons.qr_code_scanner_rounded,
                        color: context.primaryColor, size: 25),
                  ),
                ),
                const Gap(10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    card(Icons.people_outline_outlined, 'Epeditor',
                        const UsersListScreen(role: Role.expeditor)),
                    card(Icons.people_outline, 'Delivery',
                        const UsersListScreen(role: Role.delivery)),
                    card(Icons.apartment_rounded, 'Agency',
                        const AgencyListScreen()),
                    card(Icons.local_shipping_rounded, 'Colis',
                        const ColisListScreen()),
                    card(Icons.people_rounded, 'Client',
                        const ClientListScreen()),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
