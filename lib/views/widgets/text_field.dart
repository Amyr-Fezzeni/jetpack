import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/providers/theme_notifier.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final String? label;
  final FocusNode? focus;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType? keybordType;
  final List<TextInputFormatter>? inputFormatters;
  final String? leading;
  final double marginH;
  final double marginV;
  final bool submitted;
  final bool editable;
  final int? maxLines;
  final double height;
  final double padding;
  final bool trailing;
  final Widget? icon;
  final Function()? onSubmit;
  final Widget? leadingIcon;
  const CustomTextField(
      {super.key,
      required this.hint,
      required this.controller,
      this.validator,
      this.label,
      this.leading,
      this.isPassword = false,
      this.keybordType,
      this.inputFormatters,
      this.marginH = 15,
      this.marginV = 10,
      this.height = 50,
      this.maxLines = 1,
      this.onSubmit,
      this.padding = 0,
      this.trailing = false,
      this.submitted = false,
      this.editable = true,
      this.icon,
      this.leadingIcon,
      this.focus});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isCorrect = false;
  bool showPassword = false;
  bool isEdited = false;
  @override
  void initState() {
    super.initState();
    isEdited = widget.submitted;
    log(widget.submitted.toString());
    widget.controller.addListener(() async {
      // if (widget.validator(widget.controller.text) == null) {
      //   if (isCorrect == true) {
      //     return;
      //   } else {
      //     isCorrect = true;
      //     Future.delayed(const Duration(milliseconds: 50))
      //         .then((value) => setState(() {}));
      //   }
      // } else {
      //   if (isCorrect == false) {
      //     return;
      //   } else {
      //     isCorrect = false;

      //     await Future.delayed(const Duration(milliseconds: 50))
      //         .then((value) => setState(() {}));
      //   }
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    var style = context.watch<ThemeNotifier>();
    isEdited = widget.submitted ? true : isEdited;
    if (widget.validator != null) {
      if (widget.validator!(widget.controller.text) == null) {
        isCorrect = true;
      } else {
        isCorrect = false;
      }
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.marginH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(widget.label!,
                style: style.text18.copyWith(
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(
              height: 5,
            ),
          ],
          SizedBox(
            height: widget.height,
            child: TextFormField(
              enabled: widget.editable,
              focusNode: widget.focus,
              maxLines: widget.maxLines,
              onFieldSubmitted: (val) {
                FocusScope.of(NavigationService.navigatorKey.currentContext!)
                    .nextFocus();
                if (widget.onSubmit != null) widget.onSubmit!();
              },
              onChanged: (val) => setState(() {
                isEdited = true;
              }),
              onSaved: (val) => setState(() => isEdited = true),
              controller: widget.controller,
              onEditingComplete: () {},
              // autovalidateMode: AutovalidateMode.disabled,
              autocorrect: false,
              // autofillHints: ,
              keyboardType: widget.keybordType,
              inputFormatters: widget.inputFormatters,
              style: style.text18.copyWith(fontSize: 14),
              obscureText: widget.isPassword ? !showPassword : false,
              decoration: InputDecoration(
                filled: true,
                fillColor: context.invertedColor.withOpacity(0.05),
                hintText: widget.hint,
                // prefix: widget.leading != null
                //     ? Container(
                //         color: Colors.amber,
                //         width: 30,
                //         height: 40,
                //         margin: const EdgeInsets.symmetric(
                //             horizontal: 5, vertical: 10),
                //         child: Center(
                //           child: Image.asset(
                //             widget.leading ?? "",
                //             fit: BoxFit.contain,
                //             width: 18,
                //           ),
                //         ),
                //       )
                //     : null,
                prefixIcon: widget.leadingIcon ??
                    (widget.leading != null
                        ? Container(
                            // color: Colors.amber,
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            child: Image.asset(
                              widget.leading ?? "",
                              fit: BoxFit.contain,
                              width: 10,
                            ),
                          )
                        : null),
                hintStyle: style.text18.copyWith(
                    color: style.invertedColor.withOpacity(0.4), fontSize: 14),
                contentPadding: EdgeInsets.only(
                    left: 15, bottom: widget.padding, top: widget.padding),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          !isCorrect && isEdited ? darkRed : Colors.transparent,
                      width: 1),
                  borderRadius: BorderRadius.circular(smallRadius),
                ),
                suffixIcon: widget.icon ??
                    (!widget.trailing
                        ? null
                        : widget.isPassword
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                child: Icon(
                                  showPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: style.invertedColor.withOpacity(.7),
                                ),
                              )
                            : isCorrect && isEdited
                                ? Icon(
                                    Icons.check,
                                    color: context.primaryColor,
                                  )
                                : const SizedBox()),
                disabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1),
                  borderRadius: BorderRadius.circular(smallRadius),
                ),

                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isCorrect
                          ? Colors.transparent
                          : isEdited
                              ? darkRed
                              : Colors.transparent,
                      width: 1),
                  borderRadius: BorderRadius.circular(smallRadius),
                ),
                border: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1),
                  borderRadius: BorderRadius.circular(smallRadius),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: darkRed, width: 1),
                  borderRadius: BorderRadius.circular(smallRadius),
                ),
                errorStyle:
                    textWhite.copyWith(fontSize: 14, color: Colors.redAccent),
              ),
            ),
          ),
          Builder(builder: (context) {
            var result = widget.validator == null
                ? null
                : widget.validator!(widget.controller.text);
            if (result == null || !isEdited) {
              isCorrect = true;
              return const SizedBox();
            } else {
              isCorrect = false;
              return Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.error,
                        color: darkRed,
                        size: 15,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      child: Text(
                        result.toString(),
                        style: context.text.copyWith(
                            color: darkRed, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
          SizedBox(
            height: widget.marginV,
          ),
        ],
      ),
    );
  }
}

class BankTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final String? label;
  final FocusNode focus;
  final bool isEnabled;
  final double width;
  final String? Function(String?) validator;
  final bool isFinal;
  final int numbers;
  final bool isObscure;
  final TextInputType? keybordType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? sufixIcon;
  const BankTextField(
      {super.key,
      required this.hint,
      required this.controller,
      required this.validator,
      required this.numbers,
      this.label,
      this.isEnabled = true,
      this.isFinal = false,
      this.isObscure = false,
      this.keybordType,
      this.width = double.infinity,
      this.inputFormatters,
      this.sufixIcon,
      required this.focus});

  @override
  State<BankTextField> createState() => _BankTextFieldState();
}

class _BankTextFieldState extends State<BankTextField> {
  bool isCorrect = false;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (widget.validator(widget.controller.text) == null) {
        if (isCorrect == true) {
          return;
        } else {
          setState(() {
            isCorrect = true;
          });
        }
      } else {
        if (isCorrect == false) {
          return;
        } else {
          setState(() {
            isCorrect = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Text(widget.label!,
                style: context.text.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          const Gap(5),
          SizedBox(
            width: widget.width,
            child: TextFormField(
              focusNode: widget.focus,
              onFieldSubmitted: (val) {
                log(widget.isFinal.toString());
                // FocusScope.of(context).nextFocus();

                if (widget.isFinal) {
                  FocusScope.of(context).unfocus();
                } else {
                  FocusScope.of(context).nextFocus();
                }
              },
              controller: widget.controller,
              enabled: widget.isEnabled,
              maxLength: widget.numbers,
              enableIMEPersonalizedLearning: false,
              onEditingComplete: () {},
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: widget.keybordType,
              inputFormatters: widget.inputFormatters,
              style: context.text,
              obscureText: widget.isObscure,
              decoration: InputDecoration(
                filled: true,
                counter: const Offstage(),
                fillColor: Colors.white.withOpacity(0.1),
                hintText: widget.hint,
                hintStyle: context.text
                    .copyWith(color: context.invertedColor.withOpacity(0.4)),
                contentPadding:
                    const EdgeInsets.only(left: 20, bottom: 0, top: 0),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: widget.sufixIcon,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isCorrect
                          ? context.primaryColor
                          : context.invertedColor.withOpacity(0.3),
                      width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: context.primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: context.invertedColor.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.redAccent, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                errorStyle:
                    textWhite.copyWith(fontSize: 14, color: Colors.redAccent),
              ),
              validator: (val) {
                var result = widget.validator(val);
                if (result == null) {
                  isCorrect = true;
                } else {
                  isCorrect = false;
                }
                return result;
              },
            ),
          ),
          const Gap(10),
        ],
      ),
    );
  }
}
