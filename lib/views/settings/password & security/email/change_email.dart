import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/providers/user_provider.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/validators.dart';
import 'package:jetpack/views/widgets/bottuns.dart';


class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  late TextEditingController email;
  late TextEditingController newEmail;
  FocusNode emailFocus = FocusNode();
  FocusNode newEmailFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    email = TextEditingController(
        text: context.read<UserProvider>().currentUser!.email.toString());
    newEmail = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Email'),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: context.bgcolor,
        ),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Gap(30),
            CustomTextField(
              hint: "",
              label: txt("Current Email"),
              controller: email,
              editable: false,
              validator: emailValidator,
              focus: emailFocus,
            ),
            CustomTextField(
              hint: "exemple@email.com",
              controller: newEmail,
              validator: emailValidator,
              focus: newEmailFocus,
              label: txt("New Email"),
            ),
            const SizedBox(
              height: 20,
            ),
            gradientButton(
                w: context.w - 30,
                text: txt("Change"),
                function: () => context
                    .read<UserProvider>()
                    .changeEmail(context, newEmail.text)),
          ],
        )),
      ),
    );
  }
}
