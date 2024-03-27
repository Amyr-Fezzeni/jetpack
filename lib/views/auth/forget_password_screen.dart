import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/splash%20screen/custom_splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/providers/theme_notifier.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/services/validators.dart';
import 'package:jetpack/views/widgets/settings_text_field.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/popup.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController controller = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController newPassword = TextEditingController(text: "");
  TextEditingController newPasswordConfirmed = TextEditingController(text: "");
  FocusNode newPasswordFocus = FocusNode();
  FocusNode newPasswordConfirmedFocus = FocusNode();
  bool isObscure = true;
  bool isObscureConfirmed = true;

  FocusNode focus = FocusNode();
  bool isRequested = false;
  bool isValidated = false;
  String? currentCode;
  late String userId;
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 1);
  @override
  void initState() {
    super.initState();
  }

  sendOTP() async {
    resetTimer();
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(controller.text)) {
      return;
    }
    setState(() {
      isRequested = true;
    });
    String email = controller.text;

    log(email);
    // final data = await UserService.requestOTP(email);
    // if (data != null) {
    //   setState(() {
    //     isRequested = true;
    //     currentCode = data.first;
    //     userId = data.last;
    //   });
    // }
  }

  validateOTP() {
    if (codeController.text == currentCode) {
      log("Otp code validation true");
      setState(() {
        isValidated = true;
      });
    } else {
      log("Otp code validation false, ${codeController.text} == $currentCode");
      popup(
        context,
        "Ok",
        cancel: false,
        description: "Le code saisi est incorrect ou expiré",
        title: "Alerte",
      );
    }
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void resetTimer() {
    setState(() {
      if (countdownTimer == null) {
        countdownTimer =
            Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
      } else {
        countdownTimer!.cancel();
        myDuration = const Duration(seconds: 60);
      }
    });
    startTimer();
  }

  void setCountDown() {
    const int reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var style = context.watch<ThemeNotifier>();
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: style.bgColor,
      extendBody: true,
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: style.invertedColor,
            size: 25,
          ),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: isRequested
              ? SizedBox(
                  height: size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        // color: const Color.fromARGB(255, 57, 111, 176),
                        child: Center(
                          child: Image(
                            image: AssetImage(logo),
                            height: 200,
                          ),
                        ),
                      ),
                      if (!isValidated) ...[
                        SizedBox(
                          width: size.width * 0.9,
                          child: Text(
                            txt("Reset Password"),
                            textAlign: TextAlign.center,
                            style: style.text18.copyWith(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: size.width * 0.9,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                  text:
                                      '${txt('Please provide the code sent to')} ',
                                  style: context.text.copyWith(fontSize: 15)),
                              TextSpan(
                                  text: controller.text,
                                  style: style.text18
                                      .copyWith(fontSize: 15, color: context.primaryColor)),
                            ]),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                            height: 90,
                            width: size.width * .5,
                            child: TextField(
                              controller: codeController,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontSize: 20),
                              onChanged: (number) async {},
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6)
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1.5,
                                        color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(
                                        width: 1.5, color: context.primaryColor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  fillColor: Colors.grey.shade200,
                                  filled: true,
                                  hintText: "|"),
                            )),
                        Builder(builder: (context) {
                          log(myDuration.toString());
                          if (myDuration.inSeconds > 0) {
                            return Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: context.primaryColor, width: 2)),
                              child: Center(
                                child: Text(
                                  "${myDuration.inSeconds}",
                                  style: style.text18,
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              Text(
                                "${txt('You have not received your verification code')} ? ",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              InkWell(
                                onTap: () {
                                  sendOTP();
                                },
                                child: Text(
                                  txt("Receive a new code"),
                                  style: style.text18.copyWith(
                                      fontSize: 17,
                                      color: context.primaryColor,
                                      decoration: TextDecoration.underline),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(
                          height: 50,
                        ),
                        SizedBox(
                          height: 55,
                          width: size.width * .5,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(context.primaryColor),
                                  shape: MaterialStateProperty.resolveWith(
                                      (states) => RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ))),
                              onPressed: validateOTP,
                              child: Center(
                                child: Text(
                                  txt("Validate"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          fontSize: 18, color: Colors.white),
                                ),
                              )),
                        ),
                      ],
                      if (isValidated) ...[
                        SettingTextField(
                            hint: txt("New Password"),
                            controller: newPassword,
                            isObscure: isObscure,
                            isFinal: false,
                            validator: passwordValidator,
                            sufixIcon: IconButton(
                                onPressed: () => setState(() {
                                      isObscure = !isObscure;
                                    }),
                                icon: Icon(
                                  !isObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: context.primaryColor,
                                )),
                            focus: newPasswordFocus),
                        SettingTextField(
                            hint: txt("Confirm password"),
                            controller: newPasswordConfirmed,
                            isObscure: isObscureConfirmed,
                            isFinal: true,
                            validator: (value) {
                              return value == newPassword.text
                                  ? null
                                  : txt("The new password does not match.");
                            },
                            sufixIcon: IconButton(
                                onPressed: () => setState(() {
                                      isObscureConfirmed = !isObscureConfirmed;
                                    }),
                                icon: Icon(
                                  !isObscureConfirmed
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: context.primaryColor,
                                )),
                            focus: newPasswordConfirmedFocus),
                        gradientButton(
                            h: 60,
                            w: size.width - 30,
                            text: txt("Change"),
                            function: () => UserService.changePassword(
                                        userId, newPasswordConfirmed.text)
                                    .then((value) {
                                  if (value) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CustomSplashScreen()));
                                  } else {}
                                })),
                      ]
                    ],
                  ),
                )
              : Container(
                  width: size.width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        // color: const Color.fromARGB(255, 57, 111, 176),
                        child: Center(
                          child: Image(
                            image: AssetImage(logo),
                            width: 200,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                        txt("Forgot your password"),
                        style: style.text18.copyWith(fontSize: 25),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            txt("Email"),
                            style: style.text18
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SettingTextField(
                        hint: "exemple@email.com",
                        controller: controller,
                        validator: emailValidator,
                        focus: focus,
                        isFinal: true,
                        keybordType: TextInputType.emailAddress,
                      ),
                      gradientButton(
                          function: sendOTP,
                          w: size.width - 30,
                          text: txt("Send code")),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
