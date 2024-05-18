// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/relaunch_colis.dart';
import 'package:jetpack/models/report.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/services.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/colis/relaunch_colis_review.dart';
import 'package:jetpack/views/report/report_review.dart';
import 'package:jetpack/views/widgets/bottuns.dart';

import '../../../models/notification/notification.dart';
import '../../../services/util/logic_service.dart';
import '../../../services/notification_service.dart';

class NotificationWidget extends StatelessWidget {
  final Notif notification;
  const NotificationWidget({super.key, required this.notification});

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

Widget reportWidget(Report report) => Builder(builder: (context) {
      Color color = report.status == ReportStatus.review.name
          ? Colors.red
          : context.invertedColor;
      return InkWell(
        onTap: () => context.moveTo(ReportReview(report: report)),
        child: Container(
          width: context.w,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: context.bgcolor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withOpacity(.4),
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
                children: [
                  Txt(report.expeditorName, bold: true),
                  const Spacer(),
                  deleteButton(function: () {
                    FirebaseFirestore.instance
                        .collection('reports')
                        .doc(report.id)
                        .delete();
                  })
                ],
              ),
              Txt(report.reportMessage, maxLines: 2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  getTimeHistoryFr(report.dateCreated),
                  style: context.text.copyWith(
                      color: context.invertedColor.withOpacity(.7),
                      fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    });

Widget relaunchWidget(RelaunchColis relaunch) => Builder(builder: (context) {
      Color color = relaunch.status == ReportStatus.review.name
          ? Colors.red
          : context.invertedColor;
      return InkWell(
        onTap: () async {
          final colis = Colis.fromMap(
              (await ColisService.colisCollection.doc(relaunch.colisId).get())
                  .data()!);

          context.moveTo(RelaunchColisReview(
            relaunch: relaunch,
            colis: colis,
          ));
        },
        child: Container(
          width: context.w,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: context.bgcolor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withOpacity(.4),
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
                children: [
                  Txt(relaunch.expeditorName, bold: true,translate: false),
                  const Spacer(),
                  deleteButton(function: () {
                    RelaunchColisService.colisCollection
                        .doc(relaunch.id)
                        .delete();
                  })
                ],
              ),
              Txt(relaunch.colisId, color: context.primaryColor,translate: false),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  getTimeHistoryFr(relaunch.dateCreated),
                  style: context.text.copyWith(
                      color: context.invertedColor.withOpacity(.7),
                      fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    });
