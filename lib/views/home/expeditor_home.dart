import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/clients/clients_list.dart';
import 'package:jetpack/views/colis/colis_gtid_list.dart';
import 'package:jetpack/views/home/admin_home.dart';
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
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    card(Icons.local_shipping_rounded, 'Colis',
                        const ColisGridList()),
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
