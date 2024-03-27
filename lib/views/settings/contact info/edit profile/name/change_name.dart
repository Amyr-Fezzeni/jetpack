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

class ChangeName extends StatefulWidget {
  const ChangeName({super.key});

  @override
  State<ChangeName> createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  late TextEditingController name;
  late TextEditingController lastName;
  FocusNode nameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    name = TextEditingController(
        text: context.read<UserProvider>().currentUser!.firstName.toString());
    lastName = TextEditingController(
        text: context.read<UserProvider>().currentUser!.lastName.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(''),
      backgroundColor: context.bgcolor,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Gap(30),
            CustomTextField(
                hint: "",
                label: txt("First name"),
                controller: name,
                validator: nameValidator,
                focus: nameFocus),
            CustomTextField(
                hint: "",
                controller: lastName,
                validator: nameValidator,
                focus: lastNameFocus,
                label: txt("Last name")),
            const Gap(20),
            gradientButton(
                w: context.w - 30,
                text: txt("Change"),
                function: () => (name.text.isEmpty || lastName.text.isEmpty)
                    ? null
                    : context
                        .read<UserProvider>()
                        .changeName(context, name.text, lastName.text)),
          ],
        ),
      ),
    );
  }
}
