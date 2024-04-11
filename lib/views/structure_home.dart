import 'package:flutter/material.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/home/admin_home.dart';
import 'package:jetpack/views/home/banned_screen.dart';
import 'package:jetpack/views/home/delivery_home.dart';
import 'package:jetpack/views/home/expeditor_home.dart';
import 'package:jetpack/views/notifications/notifications.dart';
import 'package:jetpack/views/profile/profile.dart';
import 'package:jetpack/views/statistics/dashboard.dart';
import 'package:jetpack/views/widgets/buttom_navigation_bar.dart';
import 'package:jetpack/views/widgets/nav_panel_customer.dart';

class StructureHomeScreen extends StatefulWidget {
  const StructureHomeScreen({super.key});

  @override
  State<StructureHomeScreen> createState() => _StructureHomeScreenState();
}

class _StructureHomeScreenState extends State<StructureHomeScreen>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return (context.currentUser.status == UserStatus.banned)
        ? const BannedScreen()
        : Scaffold(
            extendBody: true,
            drawer: const NavPanel(),
            backgroundColor: context.bgcolor,
            body: [
              if (context.currentUser.role == Role.delivery)
                const DeliveryHomeScreen(),
              if (context.currentUser.role == Role.expeditor)
                const ExpeditorHomeScreen(),
              if (context.currentUser.role == Role.admin)
                const AdminHomeScreen(),
              const ProfileScreen(),
              const NotificationScreen(),
              const HomeStatsScreen()
            ][context.currentPage],
            bottomNavigationBar: const CustomBottomNavigationBar(),
          );
  }
}
