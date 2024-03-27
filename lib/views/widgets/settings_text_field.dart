import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/providers/theme_notifier.dart';

class SettingTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final String? label;
  final FocusNode focus;
  final bool isEnabled;
  final String? Function(String?) validator;
  final bool isFinal;
  final bool isObscure;
  final Function(String)? onChanged;
  final TextInputType? keybordType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? sufixIcon;
  const SettingTextField(
      {super.key,
      required this.hint,
      required this.controller,
      required this.validator,
      this.onChanged,
      this.label,
      this.isEnabled = true,
      this.isFinal = false,
      this.isObscure = false,
      this.keybordType,
      this.inputFormatters,
      this.sufixIcon,
      required this.focus});

  @override
  State<SettingTextField> createState() => _SettingTextFieldState();
}

class _SettingTextFieldState extends State<SettingTextField> {
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
    var style = context.watch<ThemeNotifier>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Text(widget.label!,
                style: style.text18.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            focusNode: widget.focus,
            onFieldSubmitted: (val) {
              log(widget.isFinal.toString());
              FocusScope.of(context).nextFocus();

              if (widget.isFinal) {
                FocusScope.of(context).unfocus();
              } else {
                FocusScope.of(context).nextFocus();
              }
            },
            onChanged: widget.onChanged,
            controller: widget.controller,
            enabled: widget.isEnabled,
            onEditingComplete: () {},
            autovalidateMode: AutovalidateMode.disabled,
            keyboardType: widget.keybordType,
            inputFormatters: widget.inputFormatters,
            style: style.text18,
            obscureText: widget.isObscure,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              hintText: widget.hint,
              hintStyle: style.text18
                  .copyWith(color: style.invertedColor.withOpacity(0.4)),
              contentPadding:
                  const EdgeInsets.only(left: 20, bottom: 16, top: 16),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: context.primaryColor, width: 1),
                borderRadius: BorderRadius.circular(smallRadius),
              ),
              suffixIcon: widget.sufixIcon,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isCorrect
                        ? context.primaryColor
                        : style.invertedColor.withOpacity(0.3),
                    width: 1),
                borderRadius: BorderRadius.circular(smallRadius),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: context.primaryColor, width: 1),
                borderRadius: BorderRadius.circular(smallRadius),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: style.invertedColor.withOpacity(0.3), width: 1),
                borderRadius: BorderRadius.circular(smallRadius),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                borderRadius: BorderRadius.circular(smallRadius),
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
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
