import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/navigation_service.dart';

Widget cLoader({double size = 50}) {
  return SizedBox(
    height: size,
    width: size,
    child: Center(
        child: Image.asset(
      loaderImg,
      fit: BoxFit.contain,
    )),
  );
}

Widget divider({double bottom = 0, double top = 0}) => Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom),
      child: Divider(
        height: 5,
        color: red.withOpacity(.1),
      ),
    );

Widget buildMenuTile(
    {required String title,
    String subtitle = '',
    required IconData icon,
    Widget? screen,
    Function()? onClick}) {
  return Builder(builder: (context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      height: 40,
      child: InkWell(
        onTap: () async {
          Scaffold.of(context).closeDrawer();
          await Future.delayed(const Duration(milliseconds: 100))
              .then((value) => {if (screen != null) context.moveTo(screen)});
          if (onClick != null) {
            onClick();
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(icon, color: context.invertedColor.withOpacity(.7)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Txt(title),
                if (subtitle.isNotEmpty)
                  Txt(subtitle,
                      style: context.text.copyWith(
                          fontSize: 12,
                          color: context.invertedColor.withOpacity(.7))),
              ],
            ),
          ],
        ),
      ),
    );
  });
}

Widget svgImage(String url,
        {double size = 25,
        bool selected = false,
        Color? color,
        Function()? function}) =>
    InkWell(
      onTap: function,
      child: SizedBox(
        height: size,
        width: size,
        child: Center(
          child: SvgPicture.asset(
            url,
            height: size,
            width: size,
            // ignore: deprecated_member_use
            color: color ??
                (selected
                    ? NavigationService
                        .navigatorKey.currentContext!.primaryColor
                    : NavigationService
                        .navigatorKey.currentContext!.invertedColor
                        .withOpacity(.7)),
          ),
        ),
      ),
    );

Widget pngIcon(String url,
        {double size = 25,
        bool selected = false,
        Color? color = pink,
        Function()? function}) =>
    InkWell(
      onTap: function,
      child: SizedBox(
        height: size,
        width: size,
        child: Center(
          child: Image.asset(
            url,
            height: size,
            width: size,
            color: color == null
                ? null
                : (selected
                    ? NavigationService
                        .navigatorKey.currentContext!.primaryColor
                    : NavigationService
                        .navigatorKey.currentContext!.invertedColor
                        .withOpacity(.7)),
          ),
        ),
      ),
    );




    