import 'package:flutter/material.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/auth/login.dart';
import 'package:jetpack/views/widgets/bottuns.dart';

class StarterScreen extends StatelessWidget {
  const StarterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      body: Column(
        children: [
          const Spacer(),
          SizedBox(
            child: Center(
              child: Image.asset(introImage),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Txt("Fastest delivery throughout Tunisia",
                size: 20,
                bold: true,
                center: true,
                color: context.invertedColor.withOpacity(.7)),
          ),
          const Spacer(),
          gradientButton(
              function: () => context.moveTo(const LoginScreen()),
              text: txt("Continue")),
          const Spacer()
        ],
      ),
    );
  }
}
