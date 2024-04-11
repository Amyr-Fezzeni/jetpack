import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:provider/provider.dart';

import '../../../../providers/user_provider.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.withOpacity(.3),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: context.h,
        width: context.w,
        child: Column(
          children: [
            const Spacer(),
            SizedBox(height: 200, child: Image.asset("assets/icons/alert.png")),
            const Gap(20),
            Text(txt("Account banned"), style: context.title),
            const Gap(20),
            Text(txt("Due to your recent actions\nyou have been banned"),
                textAlign: TextAlign.center,
                style: context.text.copyWith(fontSize: 18)),
            const Spacer(),
            gradientButton(
                function: () => context.read<UserProvider>().logOut(context),
                colors: [darkBgColor, darkBgColor],
                text: txt("Log out")),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
