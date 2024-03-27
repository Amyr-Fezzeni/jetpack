import 'package:flutter/material.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/buttom_navigation_bar.dart';
import 'package:jetpack/views/widgets/default_screen.dart';
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
        ? const DefaultScreen(title: '')
        : Scaffold(
            extendBody: true,
            drawer: const NavPanel(),
            backgroundColor: context.bgcolor,
            body: context.screens[context.currentPage]['screen'],
            bottomNavigationBar: const CustomBottomNavigationBar(),
          );
  }
}
