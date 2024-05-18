// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/clients/clients_list.dart';
import 'package:jetpack/views/colis/colis_details.dart';
import 'package:jetpack/views/colis/colis_gtid_list.dart';
import 'package:jetpack/views/users/admin_payments_tracking.dart';
import 'package:jetpack/views/users/users_list.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/buttom_navigation_bar.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/nav_panel_customer.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:jetpack/views/widgets/text_field.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: const NavPanel(),
      backgroundColor: context.bgcolor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.primaryColor,
        onPressed: () async {
          TextEditingController controller = TextEditingController();
          customPopup(
              context,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: CustomTextField(
                                marginH: 0,
                                marginV: 0,
                                hint: 'Code',
                                controller: controller)),
                        const Gap(5),
                        gradientButton(
                            function: () async {
                              final code = controller.text;
                              if (code.trim().isEmpty) return;
                              final colis = await ColisService.getColis([code]);
                              if (colis.isNotEmpty) {
                                await customPopup(
                                    context, ColisDetails(colis: colis.first));
                              }
                              context.pop();
                            },
                            text: "Confirm")
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: divider()),
                        Text(
                          'Or',
                          style: context.theme.text18,
                        ),
                        Expanded(child: divider())
                      ],
                    ),
                    gradientButton(
                        w: double.maxFinite,
                        function: () async {
                          final code = await scanQrcode();
                          if (code == null) return;
                          final colis = await ColisService.getColis([code]);
                          if (colis.isNotEmpty) {
                            await customPopup(
                                context, ColisDetails(colis: colis.first));
                          }
                          context.pop();
                        },
                        text: "Scan code")
                  ],
                ),
              ),
              maxWidth: false);
        },
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 25,
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const Gap(60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Builder(builder: (context) {
                      return InkWell(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Icon(
                          Icons.menu,
                          color: context.invertedColor.withOpacity(.7),
                          size: 30,
                        ),
                      );
                    }),
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
                    card(Icons.attach_money_rounded, 'Payments',
                        const AdminTrackingScreen()),
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
