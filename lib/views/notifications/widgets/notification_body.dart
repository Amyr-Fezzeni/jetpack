import 'package:flutter/material.dart';
import 'package:jetpack/services/util/ext.dart';
import '../../../services/util/language.dart';
import 'notification_card.dart';

class NotificationBody extends StatefulWidget {
  const NotificationBody({super.key});

  @override
  State<NotificationBody> createState() => _NotificationBodyState();
}

class _NotificationBodyState extends State<NotificationBody>
    with TickerProviderStateMixin {
  late TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, initialIndex: 0, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      width: size.width,
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
                          color: context.invertedColor.withOpacity(.7)),
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
                        .watchNotification
                        .notifications
                        .reversed
                        .map((e) => NotificationWidget(notification: e))
                        ,
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
