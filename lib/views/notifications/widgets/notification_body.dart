import 'package:flutter/material.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/report.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import '../../../services/util/language.dart';
import 'notification_card.dart';

class NotificationBody extends StatefulWidget {
  const NotificationBody({super.key});

  @override
  State<NotificationBody> createState() => _NotificationBodyState();
}

class _NotificationBodyState extends State<NotificationBody> {
  List<String> options = ["Notifications", "Reports", "Relaunch"];
  String filter = "Notifications";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (context.role == Role.admin)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: options
                .map((e) => Builder(builder: (context) {
                      int count = 0;

                      switch (e) {
                        case "Notifications":
                          count = context.watchNotification.notifications
                              .where((element) => !element.seen)
                              .toList()
                              .length;
                          break;
                        case "Relaunch":
                          count = context.watchNotification.relaunches
                              .where((element) =>
                                  element.status == ReportStatus.review.name)
                              .toList()
                              .length;
                          break;
                        default:
                          count = context.watchNotification.reports
                              .where((element) =>
                                  element.status == ReportStatus.review.name)
                              .toList()
                              .length;
                      }
                      return borderButton(
                          border: 0,
                          opacity: 0,
                          textColor: filter == e
                              ? context.primaryColor
                              : context.iconColor,
                          text: "$e${count > 0 ? " ($count)" : ''}",
                          function: () => setState(() => filter = e));
                    }))
                .toList(),
          ),
        Expanded(
          child: Column(
            children: [
              if (filter == "Notifications")
                Expanded(
                  child: context.watchNotification.notifications.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Spacer(
                                flex: 1,
                              ),
                              Icon(
                                Icons.notifications,
                                color: context.invertedColor.withOpacity(.5),
                                size: 120,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  txt("No notifications yet"),
                                  style: context.title.copyWith(fontSize: 20),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  txt("We'll notify you when something arrives"),
                                  textAlign: TextAlign.center,
                                  style: context.text.copyWith(
                                      color: context.invertedColor
                                          .withOpacity(.7)),
                                ),
                              ),
                              const Spacer(
                                flex: 2,
                              )
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Column(
                              children: [
                                ...context
                                    .watchNotification.notifications.reversed
                                    .map((e) =>
                                        NotificationWidget(notification: e)),
                                const SizedBox(
                                  height: 50,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              //reports
              if (filter == "Reports")
                Expanded(
                  child: context.watchNotification.reports.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Spacer(
                                flex: 1,
                              ),
                              Icon(
                                Icons.notifications,
                                color: context.invertedColor.withOpacity(.5),
                                size: 120,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  txt("No notifications yet"),
                                  style: context.title.copyWith(fontSize: 20),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  txt("We'll notify you when something arrives"),
                                  textAlign: TextAlign.center,
                                  style: context.text.copyWith(
                                      color: context.invertedColor
                                          .withOpacity(.7)),
                                ),
                              ),
                              const Spacer(
                                flex: 2,
                              )
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Column(
                              children: [
                                ...context.watchNotification.reports.reversed
                                    .map((e) => reportWidget(e)),
                                const SizedBox(
                                  height: 50,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              //relaunch
              if (filter == "Relaunch")
                Expanded(
                  child: context.watchNotification.relaunches.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Spacer(
                                flex: 1,
                              ),
                              Icon(
                                Icons.notifications,
                                color: context.invertedColor.withOpacity(.5),
                                size: 120,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  txt("No notifications yet"),
                                  style: context.title.copyWith(fontSize: 20),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  txt("We'll notify you when something arrives"),
                                  textAlign: TextAlign.center,
                                  style: context.text.copyWith(
                                      color: context.invertedColor
                                          .withOpacity(.7)),
                                ),
                              ),
                              const Spacer(
                                flex: 2,
                              )
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Column(
                              children: [
                                ...context.watchNotification.relaunches.reversed
                                    .map((e) => relaunchWidget(e)),
                                const SizedBox(
                                  height: 50,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
