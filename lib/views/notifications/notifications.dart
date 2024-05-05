import 'package:flutter/material.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/report.dart';
import 'package:jetpack/views/notifications/widgets/notification_body.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/buttom_navigation_bar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int count = context.watchNotification.notifications
        .where((element) => !element.seen)
        .toList()
        .length;
    if (context.role == Role.admin) {
      count += context.watchNotification.reports
              .where((element) => element.status == ReportStatus.review.name)
              .toList()
              .length +
          context.watchNotification.relaunches
              .where((element) => element.status == ReportStatus.review.name)
              .toList()
              .length;
    }
    return Scaffold(
      extendBody: true,
      backgroundColor: context.bgcolor,
      bottomNavigationBar: const CustomBottomNavigationBar(),
      appBar: appBar("Notifications ${count > 0 ? "($count)" : ""}",
          leading: false),
      body: SizedBox(
        width: context.w,
        child: const NotificationBody(),
      ),
    );
  }
}
