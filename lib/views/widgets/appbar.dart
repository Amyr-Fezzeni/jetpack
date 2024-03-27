import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/app_settings/theme.dart';
import 'package:jetpack/providers/theme_notifier.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:provider/provider.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final double height;
//   final bool action;

//   const CustomAppBar(
//       {super.key,
//       this.height = kToolbarHeight,
//       this.action = false,
//       String title = ''});

//   @override
//   Size get preferredSize => Size.fromHeight(height);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               profileIcon(),
//               if (action)
//                 InkWell(
//                   onTap: () {
//                     Scaffold.of(context).openDrawer();
//                   },
//                   child: Icon(
//                     Icons.more_vert,
//                     size: 35,
//                     color: context.invertedColor.withOpacity(.7),
//                   ),
//                 )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

AppBar appBar(String title,
    {leading = true, Widget? action, bool leadingProfile = false}) {
  var context = NavigationService.navigatorKey.currentContext!;
  return AppBar(
    backgroundColor: context.bgcolor,
    surfaceTintColor: context.bgcolor,
    shadowColor: Colors.black45,
    elevation: 0,
    title: Txt(title,
        style:
            context.text.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
    centerTitle: true,
    leading: leadingProfile
        ? Builder(
            builder: (ctx) => Padding(
                padding: const EdgeInsets.only(left: 15),
                child: profileIcon(ontap: () => Scaffold.of(ctx).openDrawer())))
        : SizedBox(
            child: leading
                ? InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 25, color: context.invertedColor.withOpacity(.7)))
                : null),
    actions: action != null
        ? [action]
        : [
            InkWell(
                onTap: () {
                  bool isDark = NavigationService.navigatorKey.currentContext!
                      .read<ThemeNotifier>()
                      .isDark;
                  NavigationService.navigatorKey.currentContext!
                      .read<ThemeNotifier>()
                      .changeDarkMode(
                          isDark ? AppThemeModel.light : AppThemeModel.dark);
                },
                child: Icon(Icons.dark_mode,
                    size: 25, color: context.invertedColor.withOpacity(.7))),
            const Gap(20)
          ],
  );
}

// AppBar defaultAppBar(title,
//     {bool leading = true,
//     Widget? actions,
//     bool balanceWidget = false,
//     bool transparent = false}) {
//   var style =
//       NavigationService.navigatorKey.currentContext!.watch<ThemeNotifier>();
//   return AppBar(
//     backgroundColor: transparent ? Colors.transparent : style.bgColor,
//     elevation: 0,
//     title: Text(
//       txt(title),
//       style: style.title.copyWith(fontSize: 18, color: style.invertedColor),
//     ),
//     centerTitle: true,
//     actions: [
//       if (actions != null) actions,
//       const SizedBox(
//         width: 10,
//       )
//     ],
//     leading: leading
//         ? InkWell(
//             onTap: () =>
//                 Navigator.pop(NavigationService.navigatorKey.currentContext!),
//             child: Icon(
//               Icons.arrow_back_ios_new_outlined,
//               color: style.invertedColor.withOpacity(.7),
//               size: 25,
//             ),
//           )
//         : const SizedBox(),
//   );
// }
