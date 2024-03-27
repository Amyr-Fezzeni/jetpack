import 'package:flutter/material.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/providers/user_provider.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/validators.dart';
import 'package:jetpack/views/widgets/bottuns.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final formkey = GlobalKey<FormState>();
  TextEditingController oldPassword = TextEditingController(text: "");
  TextEditingController newPassword = TextEditingController(text: "");
  TextEditingController newPasswordConfirmed = TextEditingController(text: "");
  bool isObscureOld = true;
  bool isObscure = true;
  bool isObscureConfirmed = true;
  FocusNode oldPasswordFocus = FocusNode();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode newPasswordConfirmedFocus = FocusNode();
  bool submitted = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar("Password"),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: context.bgcolor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  hint: txt("Old Password"),
                  controller: oldPassword,
                  validator: (value) => value.toString().isEmpty
                      ? txt('Old password is required')
                      : value.toString().length < 8
                          ? txt('Too short. Use at least 8 characters')
                          : null,
                  focus: oldPasswordFocus,
                  isPassword: true,
                  submitted: submitted,
                  marginH: 0,
                ),
                CustomTextField(
                  hint: txt("New Password (8 or more characters)"),
                  controller: newPassword,
                  validator: passwordValidator,
                  focus: newPasswordFocus,
                  isPassword: true,
                  submitted: submitted,
                  marginH: 0,
                ),
                CustomTextField(
                  hint: txt("Confirm password"),
                  controller: newPasswordConfirmed,
                  validator: (value) {
                    return value.toString().isEmpty
                        ? txt('Password is required')
                        : value == newPassword.text
                            ? null
                            : txt("The new password does not match.");
                  },
                  focus: newPasswordConfirmedFocus,
                  isPassword: true,
                  submitted: submitted,
                  marginH: 0,
                ),
                gradientButton(
                    raduis: 20,
                    h: 35,
                    text: txt("Change"),
                    function: () {
                      setState(() {
                        submitted = true;
                      });

                      if (formkey.currentState != null &&
                          formkey.currentState!.validate()) {
                        context.read<UserProvider>().changePassword(
                            context,
                            oldPassword.text,
                            newPassword.text,
                            newPasswordConfirmed.text);
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
