import 'package:flutter/material.dart';
import 'package:jetpack/providers/notification_provider.dart';
import 'package:jetpack/views/notifications/widgets/notification_body.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int count = context
        .watch<NotificationProvider>()
        .notifications
        .where((element) => !element.seen)
        .toList()
        .length;

    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar("Notifications ${count > 0 ? "($count)" : ""}",
          leading: false),
      body: const SizedBox(
        child: NotificationBody(),
      ),
    );
  }
}
