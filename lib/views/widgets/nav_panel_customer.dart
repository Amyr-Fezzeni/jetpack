import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/expeditor_payment.dart';
import 'package:jetpack/services/shared_data.dart';
import 'package:jetpack/views/agency/agency_list.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/auth/login.dart';
import 'package:jetpack/views/payment/delivery_payment_screen.dart';
import 'package:jetpack/views/sector/sector_list.dart';
import 'package:jetpack/views/users/expeditor_tracking.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/default_screen.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:provider/provider.dart';
import '../../constants/fixed_messages.dart';
import '../../providers/user_provider.dart';
import '../../services/util/language.dart';
import '../../services/util/navigation_service.dart';
import '../settings/settings.dart';

class NavPanel extends StatelessWidget {
  const NavPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w * .7,
      margin: const EdgeInsets.only(),
      decoration: BoxDecoration(
          color: context.bgcolor,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10), bottomRight: Radius.circular(10))),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(children: [
                profileIcon(size: 50, url: context.currentUser.photo),
                Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Txt(context.currentUser.getFullName(),
                                bold: true)),
                        Flexible(
                          child: Txt(
                              "${context.currentUser.role == Role.admin ? 'Admin' : context.currentUser.role == Role.expeditor ? 'Expeditor' : 'Delivery'} account",
                              color: context.iconColor),
                        ),
                      ],
                    ))
              ]),
              divider(bottom: 5, top: 5),
              if ([Role.admin].contains(context.currentUser.role))
                buildMenuTile(
                    title: txt('Agency'),
                    icon: Icons.apartment_rounded,
                    screen: const AgencyListScreen()),
              if ([Role.admin].contains(context.currentUser.role))
                buildMenuTile(
                    title: txt('Sector'),
                    icon: Icons.location_on,
                    screen: const SectorListScreen()),
              if ([Role.delivery].contains(context.currentUser.role))
                buildMenuTile(
                    title: txt('Payment'),
                    icon: Icons.payments_outlined,
                    screen: const DeliveryPaymentHistoryScreen()),
              if ([Role.expeditor].contains(context.currentUser.role))
                buildMenuTile(
                    title: txt('Payment'),
                    icon: Icons.payments_outlined,
                    screen: ExpeditorTrackingScreen(user: context.currentUser)),
              buildMenuTile(
                  title: txt('Settings'),
                  icon: Icons.settings,
                  screen: const SettingsScreen()),
              buildMenuTile(
                  title: txt('Help & Support'),
                  icon: Icons.contact_support_outlined,
                  screen: const DefaultScreen(
                      title: 'Helps & support', leading: true)),
              const Accounts(),
              const Spacer(),
              Builder(builder: (context) {
                return InkWell(
                  onTap: () async {
                    Scaffold.of(context).closeDrawer();
                    Future.delayed(const Duration(milliseconds: 100)).then(
                        (value) => popup(
                            NavigationService.navigatorKey.currentContext!,
                            confirmFunction: () => NavigationService
                                .navigatorKey.currentContext!
                                .read<UserProvider>()
                                .logOut(NavigationService
                                    .navigatorKey.currentContext!),
                            description: '${txt(logoutMessage)}?'));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.logout_rounded,
                          color: context.invertedColor.withOpacity(.7),
                          size: 25,
                        ),
                      ),
                      Txt("Log Out")
                    ],
                  ),
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  bool expand = false;
  late List<String> accounts;
  @override
  void initState() {
    super.initState();
    accounts = DataPrefrences.getAccounts();
    log(accounts.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          color: context.bgcolor,
          child: InkWell(
            onTap: () => setState(() => expand = !expand),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: context.iconColor,
                    size: 20,
                  ),
                  const Gap(5),
                  Txt('Accounts'),
                  const Spacer(),
                  Icon(
                    expand
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: context.iconColor,
                    size: 25,
                  )
                ],
              ),
            ),
          ),
        ),
        if (expand) ...[
          ...accounts.map((e) => Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(.1),
                    borderRadius: defaultSmallRadius),
                child: InkWell(
                  onTap: () async {
                    final account = DataPrefrences.getAccount(accountName: e);
                    if (account != null && account.isNotEmpty) {
                      context.userprovider.login(
                          context, account.first, account.last,
                          saveLogin: true);
                    }
                  },
                  child: Row(
                    children: [
                      profileIcon(size: 25),
                      const Gap(5),
                      Txt(e, bold: true),
                      const Spacer(),
                      deleteButton(function: () async {
                        DataPrefrences.removeAccount(accountName: e)
                            .then((value) => setState(() {
                                  accounts = DataPrefrences.getAccounts();
                                }));
                      })
                    ],
                  ),
                ),
              )),
          borderButton(
              text: "Add acount",
              function: () => context.moveTo(const LoginScreen()),
              textColor: context.primaryColor,
              opacity: 0)
        ]
      ],
    );
  }
}
