import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/providers/theme_notifier.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:provider/provider.dart';

Widget gradientButton(
        {required Function? function,
        required String text,
        Widget? widget,
        Color? color,
        double? w,
        double raduis = smallRadius,
        double h = 50}) =>
    Builder(builder: (context) {
      return Container(
        width: w,
        constraints: BoxConstraints(minHeight: h),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: color ?? context.primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(raduis)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: InkWell(
          onTap: () async {
            if (function != null) {
              function();
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: context.text.copyWith(fontSize: 14, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              if (widget != null) ...[
                const SizedBox(
                  width: 0,
                ),
                widget,
              ]
            ],
          ),
        ),
      );
    });

Widget socialMediaButton(
    {required Function? function,
    required String text,
    String? image,
    List<Color> colors = primaryGradient,
    double w = double.infinity,
    double h = 35}) {
  var style =
      NavigationService.navigatorKey.currentContext!.watch<ThemeNotifier>();
  return Container(
    width: w,
    height: h,
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
    child: GestureDetector(
      onTap: () async {
        if (function != null) {
          function();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),

        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 66, 134, 244),
            border: Border.all(color: style.invertedColor.withOpacity(.2)),
            borderRadius: BorderRadius.circular(
                bigRadius)), // min sizes for Material buttons
        alignment: Alignment.center,
        child: Row(
          children: [
            if (image != null)
              Container(
                height: h - 5,
                width: h - 5,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(bigRadius)),
                child: Center(
                  child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(
                        image,
                      )),
                ),
              ),
            const Spacer(),
            Text(
              text,
              style: style.text18.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w200,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
          ],
        ),
      ),
    ),
  );
}

Widget logoWidget({void Function()? ontap, double size = 60}) {
  return Builder(builder: (context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
          color: context.isDark ? Colors.white : null,
          borderRadius: BorderRadius.circular(smallRadius)),
      child: InkWell(
        onTap: ontap,
        child: Image.asset(logo, width: size),
      ),
    );
  });
}

Widget profileIcon(
    {void Function()? ontap,
    double size = 40,
    double radius = 100,
    String url = '',
    bool shadow = true}) {
  return Builder(builder: (context) {
    return SizedBox(
      height: size,
      width: size,
      child: Center(
        child: InkWell(
          onTap: ontap,
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
                boxShadow: shadow ? defaultShadow : null,
                border: Border.all(
                    width: 2, color: context.primaryColor.withOpacity(.7)),
                color: context.bgcolor,
                borderRadius: BorderRadius.circular(radius)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: url.isNotEmpty
                  ? Image.network(url, fit: BoxFit.cover)
                  : Image.asset(profileImg, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  });
}

Widget borderButton(
    {String text = '',
    Function? function,
    Color? color,
    double h = 35,
    double opacity = 1,
    Widget? leading,
    Color? textColor,
    double radius = bigRadius,
    Widget? trailing,
    bool bold = false,
    double border = 1,
    double? w}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: InkWell(
      onTap: () async {
        if (function != null) {
          function();
        }
      },
      child: Container(
        height: h,
        width: w,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
                color: color ??
                    NavigationService.navigatorKey.currentContext!.primaryColor
                        .withOpacity(opacity),
                width: border)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: leading,
              ),
            Txt(text, color: textColor, bold: bold),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: trailing,
              ),
          ],
        ),
      ),
    ),
  );
}

GestureDetector transparentButton(
    {required BuildContext context,
    required double height,
    required double width,
    required Widget widget,
    Function? function,
    BorderRadius? borderRadius,
    Color? color,
    Border? border}) {
  return GestureDetector(
    onTap: () async {
      if (function != null) {
        function();
      }
    },
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: border,
        color: Colors.white.withOpacity(0.1),
        borderRadius: borderRadius,
      ),
      child: Center(child: widget),
    ),
  );
}

Widget deleteButton({Function? function, double opacity = 1}) => InkWell(
    onTap: () {
      if (function != null) {
        function();
      }
    },
    child: SizedBox(
      height: 30,
      width: 30,
      child: Center(
        child: svgImage(deleteIcon, color: darkRed),
      ),
    ));

Widget checkBox(bool value, String title, Function() function,
        {String? description}) =>
    InkWell(
      onTap: function,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
              value: value,
              checkColor: Colors.white,
              side: MaterialStateBorderSide.resolveWith(
                (states) => BorderSide(
                    width: 1.0,
                    color: NavigationService
                        .navigatorKey.currentContext!.primaryColor),
              ),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: NavigationService
                          .navigatorKey.currentContext!.primaryColor),
                  borderRadius: BorderRadius.circular(4)),
              activeColor:
                  NavigationService.navigatorKey.currentContext!.primaryColor,
              onChanged: (value) {
                function();
              },
            ),
          ),
          if (title.isNotEmpty) ...[
            const Gap(10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Txt(title),
                  if (description != null)
                    Txt(description,
                        color: NavigationService
                            .navigatorKey.currentContext!.invertedColor
                            .withOpacity(.7)),
                ],
              ),
            ),
          ],
          const Gap(5)
        ],
      ),
    );

Widget phoneWidgetId(String phone, {required String id, double size = 30}) =>
    Builder(builder: (context) {
      return InkWell(
        onTap: () {},
        child: Container(
          height: size,
          width: size * 2,
          decoration: BoxDecoration(
              boxShadow: defaultShadow,
              color: Colors.green,
              borderRadius: BorderRadius.circular(smallRadius)),
          child:
              Center(child: Icon(Icons.phone, color: Colors.white, size: size)),
        ),
      );
    });
