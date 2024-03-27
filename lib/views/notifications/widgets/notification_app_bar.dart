import 'package:flutter/material.dart';
import 'package:jetpack/services/util/ext.dart';

class NotificationAppBar extends StatelessWidget {
  const NotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    int count = context
        .watchNotification.notifications
        .where((element) => !element.seen)
        .toList()
        .length;
    return SizedBox(
      height: 80,
      // color: Colors.red,
      child: Stack(
        children: [
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                    offset: Offset(0, 3), blurRadius: 10, color: Colors.black38)
              ],
              color: context.panelColor,
            ),
            child: Center(
              child: Text(
                "Notifications ${count > 0 ? "($count)" : ""}",
                style: context.text.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 20,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Hero(
                tag: "notification",
                child: Container(
                  padding: const EdgeInsets.only(right: 5),
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: context.bgcolor,
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(0, 3),
                          blurRadius: 10,
                          color: Colors.black38)
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: context.invertedColor,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
