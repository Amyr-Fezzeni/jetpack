import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/providers/menu_provider.dart';
import 'package:jetpack/services/util/language.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    Widget iconBar(IconData icon, String title, int index, {String? url}) {
      return InkWell(
        onTap: () {
          context.read<MenuProvider>().updateCurrentPage(index);
          HapticFeedback.lightImpact();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: context.currentPage != index
              ? null
              : BoxDecoration(
                  color: context.primaryColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(smallRadius)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              url != null
                  ? pngIcon(url,
                      selected: context.currentPage == index, size: 20)
                  : Icon(
                      icon,
                      size: 20,
                      color: context.currentPage == index
                          ? context.primaryColor
                          : context.invertedColor.withOpacity(.7),
                    ),
              if (context.currentPage == index) ...[const Gap(5), Txt(title)]
            ],
          ),
        ),
      );
    }

    return Container(
      height: 60,
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          boxShadow: defaultShadow,
          color: context.isDark ? darknavBarColor : lightnavBarColor,
          borderRadius: BorderRadius.circular(smallRadius)),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            iconBar(Icons.home_filled, txt('Home'), 0),
            iconBar(Icons.person, txt('Profile'), 1),
            iconBar(Icons.notifications_none, txt('Notifications'), 2,
                url: notificationIcon),
            iconBar(Icons.bar_chart_rounded, txt('Dashboard'), 3),
          ]),
    );
  }
}
