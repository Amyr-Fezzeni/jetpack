// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/services/validators.dart';
import 'package:jetpack/views/auth/forget_password_screen.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/text_field.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/widgets/popup.dart';
import '../../../../providers/user_provider.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  bool isObscure = true;
  bool saveLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      body: SizedBox(
        height: context.h,
        width: context.w,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(context.h * .2),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20)
                      .copyWith(right: 30),
                  child: Center(
                    child: Hero(
                      tag: 'logo',
                      child: logoWidget(size: 200),
                    ),
                  ),
                ),
                Gap(context.h * .1),
                CustomTextField(
                    hint: txt('Email'),
                    controller: emailController,
                    validator: emailValidator,
                    leadingIcon: Icon(Icons.person_outline_rounded,
                        size: 25,
                        color: context.invertedColor.withOpacity(.4)),
                    focus: emailFocus),
                CustomTextField(
                    hint: txt('Password'),
                    controller: passwordController,
                    validator: passwordValidator,
                    leadingIcon: Icon(Icons.lock_outline_rounded,
                        size: 25,
                        color: context.invertedColor.withOpacity(.4)),
                    isPassword: true,
                    focus: passwordFocus),
                Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 25,
                        width: 25,
                        margin: const EdgeInsets.only(right: 5),
                        child: Checkbox(
                          value: saveLogin,
                          checkColor: Colors.white,
                          side: MaterialStateBorderSide.resolveWith(
                            (states) => BorderSide(
                                width: 1.0, color: context.primaryColor),
                          ),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: context.primaryColor),
                              borderRadius: BorderRadius.circular(4)),
                          activeColor: context.primaryColor,
                          onChanged: (bool? value) {
                            setState(() {
                              saveLogin = value ?? false;
                            });
                          },
                        ),
                      ),
                      Flexible(
                        child: Txt(txt("Keep me logged in"), size: 13),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: context.watch<UserProvider>().isLoading
                      ? Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: context.primaryColor,
                                borderRadius: BorderRadius.circular(80)),
                            child: cLoader(),
                          ),
                        )
                      : gradientButton(
                          text: txt("Login"),
                          w: double.infinity,
                           color:context.primaryColor,
                          function: () async {
                            final validateEmail =
                                emailValidator(emailController.text);
                            if (validateEmail != null) {
                              popup(context,
                                  cancel: false,
                                  title: txt("Worning"),
                                  description: validateEmail);
                              return;
                            }
                            final validatePassword =
                                passwordValidator(passwordController.text);
                            if (validatePassword != null) {
                              popup(context,
                                  cancel: false,
                                  title: txt("Worning"),
                                  description: validatePassword);
                              return;
                            }
                            
                            context.userprovider.login(
                                context,
                                emailController.text.trim(),
                                passwordController.text.trim(),
                                saveLogin: saveLogin);
                          }),
                ),
                Center(
                  child: SizedBox(
                    height: 40,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ForgetPasswordScreen())),
                      child: Text(
                        '${txt('Forgot password')} ?',
                        style: context.text.copyWith(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Gap(context.h * .1)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
