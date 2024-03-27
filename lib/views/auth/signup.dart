import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/default_screen.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/providers/user_provider.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/validators.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/text_field.dart';
import '../../../constants/constants.dart';

class SignUpScreen extends StatefulWidget {
  final String email;
  final String displayName;
  final String photo;
  final bool isFreelancer;
  const SignUpScreen(
      {super.key,
      required this.isFreelancer,
      this.email = "",
      this.displayName = "",
      this.photo = ""});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formkey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool submitted = false;
  String photo = "";
  bool sendUpdates = false;
  bool terms = false;
  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    Future.delayed(const Duration(milliseconds: 50)).then((value) {
      setState(() {
        firstNameController.text = widget.displayName.split(" ").first;
        lastNameController.text = widget.displayName.split(" ").last;
        emailController.text = widget.email;
        photo = widget.photo;
        log("photo:$photo");
      });
    });
  }

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Form(
          key: formkey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const Gap(20),
                SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Hero(
                            tag: 'logo',
                            child: Row(
                              children: [
                                const Image(
                                  image: AssetImage('assets/icons/logo1.png'),
                                  width: 40,
                                ),
                                Txt('Les jetpacks'.toUpperCase(),
                                    style: context.title.copyWith(
                                        color: context.invertedColor
                                            .withOpacity(.7),
                                        fontSize: 15)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Center(
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Text(txt('Log In'),
                                    style: context.text.copyWith(
                                      color: context.primaryColor,
                                      fontWeight: FontWeight.w800,
                                    )),
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
                const Gap(10),
                Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: context.invertedColor.withOpacity(.2))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Txt(
                            widget.isFreelancer
                                ? 'Sign up to find work you love'
                                : 'Sign up to hire talent',
                            center: true,
                            style: context.title.copyWith(fontSize: 20)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      socialMediaButton(
                          function: () => {},
                          // context.read<UserProvider>().googleLogIn(context),
                          text: txt("Login with Google"),
                          image: googleLogo),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 1,
                            width: context.w * .4,
                            color: context.invertedColor.withOpacity(.4),
                          ),
                          Text(
                            txt('Or'),
                            style: context.text,
                          ),
                          Container(
                            height: 1,
                            width: context.w * .4,
                            color: context.invertedColor.withOpacity(.4),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        hint: txt("First name"),
                        controller: firstNameController,
                        validator: nameValidator,
                        focus: firstNameFocus,
                        keybordType: TextInputType.name,
                        submitted: submitted,
                        marginH: 0,
                      ),
                      CustomTextField(
                        hint: txt("Last name"),
                        controller: lastNameController,
                        marginH: 0,
                        validator: (value) {
                          bool nameValid =
                              RegExp(r"^[a-zA-Z]").hasMatch(value ?? " ") ||
                                  !RegExp("^[\u0000-\u007F]+\$")
                                      .hasMatch(value ?? " ");

                          return value.toString().isEmpty
                              ? txt("Please enter your Last name")
                              : value.toString().length < 3
                                  ? txt('Too short')
                                  : !nameValid
                                      ? txt('Wrong name format')
                                      : null;
                        },
                        focus: lastNameFocus,
                        keybordType: TextInputType.name,
                        submitted: submitted,
                      ),
                      CustomTextField(
                        hint: widget.isFreelancer
                            ? txt("Email")
                            : txt("Work email address"),
                        controller: emailController,
                        validator: emailValidator,
                        focus: emailFocus,
                        keybordType: TextInputType.emailAddress,
                        submitted: submitted,
                        marginH: 0,
                        // editable: false,
                      ),
                      CustomTextField(
                        hint: txt("Password (8 or more characters)"),
                        controller: passwordController,
                        validator: passwordValidator,
                        focus: passwordFocus,
                        isPassword: true,
                        submitted: submitted,
                        marginH: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 25,
                                  width: 25,
                                  margin: const EdgeInsets.only(right: 5),
                                  child: Checkbox(
                                    value: sendUpdates,
                                    checkColor: Colors.white,
                                    side: MaterialStateBorderSide.resolveWith(
                                      (states) => BorderSide(
                                          width: 1.0,
                                          color: context.primaryColor),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: context.primaryColor),
                                        borderRadius: BorderRadius.circular(4)),
                                    activeColor: context.primaryColor,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        sendUpdates = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: Txt(
                                      txt("Send me emails with tips on how to find talent that fits my needs."),
                                      size: 13),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 25,
                                  width: 25,
                                  margin: const EdgeInsets.only(right: 5),
                                  child: Checkbox(
                                    value: terms,
                                    checkColor: Colors.white,
                                    side: MaterialStateBorderSide.resolveWith(
                                      (states) => BorderSide(
                                          width: 1.0,
                                          color: context.primaryColor),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: context.primaryColor),
                                        borderRadius: BorderRadius.circular(4)),
                                    activeColor: context.primaryColor,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        terms = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                                Builder(builder: (context) {
                                  final textStyle =
                                      context.text.copyWith(fontSize: 13);
                                  return Flexible(
                                      child: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                "${txt("Yes, I understand and agree to the")}  ",
                                            style: textStyle),
                                        TextSpan(
                                            text: txt(
                                                "jetpack Terms of Services"),
                                            style: textStyle.copyWith(
                                              color: context.primaryColor,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const DefaultScreen(
                                                              title:
                                                                  'jetpack Terms of Services')))),
                                        TextSpan(
                                            text: ", ${txt("including the")} ",
                                            style: textStyle),
                                        TextSpan(
                                            text: txt("User Agreement"),
                                            style: textStyle.copyWith(
                                              color: context.primaryColor,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const DefaultScreen(
                                                              title:
                                                                  'User Agreement')))),
                                        TextSpan(
                                            text: " ${txt("and")} ",
                                            style: textStyle),
                                        TextSpan(
                                            text: txt("Privacy Policy"),
                                            style: textStyle.copyWith(
                                              color: context.primaryColor,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const DefaultScreen(
                                                              title:
                                                                  'Privacy Policy')))),
                                        TextSpan(text: ".", style: textStyle),
                                      ],
                                    ),
                                  ));
                                }),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      !terms && submitted
                          ? Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error,
                                    color: darkRed,
                                    size: 15,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Flexible(
                                    child: Txt(
                                      "Please accept the jetpack Terms of Service before continuing",
                                      style: context.text.copyWith(
                                          color: darkRed,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      context.watch<UserProvider>().isLoading
                          ? Center(
                              child: Container(
                                height: 50,
                                width: 50,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: context.primaryColor,
                                    borderRadius: BorderRadius.circular(80)),
                                child: cLoader(size: 40),
                              ),
                            )
                          : gradientButton(
                              text: txt("Create my account"),
                              raduis: 20,
                              h: 35,
                              function: () async {
                                setState(() {
                                  submitted = true;
                                });

                                if (formkey.currentState != null &&
                                    formkey.currentState!.validate()) {
                                  // await context.read<UserProvider>().signup(
                                  //     firstName: firstNameController.text,
                                  //     lastName: lastNameController.text,
                                  //     email: emailController.text,
                                  //     password: passwordController.text,
                                  //     role: widget.isFreelancer
                                  //         ? UserRole.freelance
                                  //         : UserRole.client,
                                  //     photo: photo);
                                }
                              },
                            ),
                      Center(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                      "${txt(widget.isFreelancer ? "Here to hire talent" : "Looking for work")} ?  ",
                                  style: context.text),
                              TextSpan(
                                  text: txt(widget.isFreelancer
                                      ? 'Join as a client'
                                      : 'Apply as talent'),
                                  style: context.text.copyWith(
                                    color: context.primaryColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SignUpScreen(
                                                isFreelancer:
                                                    !widget.isFreelancer)))),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                const Gap(30)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
