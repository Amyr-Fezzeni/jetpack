import 'package:flutter/material.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/services/util/ext.dart';

import '../../../models/notification/notification.dart';
import '../../../services/util/logic_service.dart';
import '../../../services/notification_service.dart';

class NotificationWidget extends StatelessWidget {
  final Notif notification;
  const NotificationWidget({super.key, required this.notification});

  Future<void> seen(String id) async {}
  Color getTypeColor(String type) {
    switch (type) {
      case "system":
        return Colors.amber;
      case "post":
        return pink;
      case "task":
        return red;
      default:
        return const Color.fromARGB(255, 255, 187, 85);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color = getTypeColor(notification.notificationType);
    // int id = notification.data!.data!.id!;
    var size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => NotificationService.seenNotification(notification.id),
      child: Container(
        width: size.width,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: context.bgcolor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(notification.seen ? .4 : 1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 1),
              blurRadius: 5,
              color: Colors.black.withOpacity(0.2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 1),
                        blurRadius: 5,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Center(
                    child: Text(
                      notification.notificationType.toUpperCase(),
                      style: context.text.copyWith(
                          fontSize: 14,
                          color: const Color(0xffFFFFFF),
                          fontFamily: 'LatoSemibold'),
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () =>
                      NotificationService.deleteNotification(notification.id),
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        color: color,
                        size: 25,
                      ),
                    ),
                  ),
                )
              ],
            ),
            // Container(
            //   margin: const EdgeInsets.only(top: 5),
            //   width: double.infinity,
            //   child: Text(
            //     notification.title.toUpperCase(),
            //     style: style.text18.copyWith(
            //         fontSize: 16.5, color: color, fontWeight: FontWeight.w400),
            //     // maxLines: 1,
            //   ),
            // ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 5),
              child: Text(
                notification.body,
                style: context.text
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w300),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                getTimeHistoryFr(notification.createdAt),
                style: context.text.copyWith(
                    color: context.invertedColor.withOpacity(.7), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
