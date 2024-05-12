import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/statistics/admin_stat.dart';
import 'package:jetpack/views/statistics/delivery_stat.dart';
import 'package:jetpack/views/statistics/expeditor_stat.dart';
import 'package:jetpack/views/statistics/statistic_widget.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/buttom_navigation_bar.dart';

class HomeStatsScreen extends StatefulWidget {
  const HomeStatsScreen({super.key});

  @override
  State<HomeStatsScreen> createState() => _HomeStatsScreenState();
}

class _HomeStatsScreenState extends State<HomeStatsScreen> {
  int filter = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: context.bgcolor,
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (context.role == Role.admin) const AdminStat(),
              if (context.role == Role.expeditor) const ExpeditorStat(),
              if (context.role == Role.delivery) const DeliveryStat()
            ],
          ),
        ),
      ),
    );
  }
}
