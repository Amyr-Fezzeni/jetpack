import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/providers/user_provider.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/validators.dart';
import 'package:jetpack/views/widgets/bottuns.dart';

class ChangePhone extends StatefulWidget {
  const ChangePhone({super.key});

  @override
  State<ChangePhone> createState() => _ChangePhoneState();
}

class _ChangePhoneState extends State<ChangePhone> {
  late TextEditingController phone;
  late TextEditingController newPhone;
  FocusNode phoneFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    phone = TextEditingController(
        text: context.read<UserProvider>().currentUser!.phoneNumber.toString());
    newPhone = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(''),
      backgroundColor: context.bgcolor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Gap(30),
          CustomTextField(
              hint: "",
              label: txt("Current phone number"),
              controller: phone,
              editable: false,
              keybordType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                return null;
              },
              focus: FocusNode()),
          CustomTextField(
              hint: "1234567890",
              controller: newPhone,
              validator: phoneNumberValidator,
              focus: phoneFocus,
              label: txt("New phone number"),
              keybordType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const Gap(20),
          gradientButton(
              w: context.w - 30,
              text: txt("Change"),
              function: () =>
                  validatorPhone(context, phone.text, newPhone.text))
        ],
      ),
    );
  }
}
