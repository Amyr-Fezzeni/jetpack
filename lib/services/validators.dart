// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/providers/user_provider.dart';
import 'package:jetpack/services/user_service.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'util/language.dart';

String? Function(dynamic) phoneNumberValidator = (value) {
  return value.toString().length == 8
      ? null
      : value.toString().isEmpty
          ? txt('Phone number is required')
          : txt('Phone number invalid');
};

String? Function(dynamic) priceValidator = (value) {
  return value.toString().isNotEmpty &&
          double.tryParse(value.toString()) != null &&
          double.parse(value.toString()) > 0
      ? null
      : txt('Price should be greater than 0');
};

String? Function(dynamic) nameValidator = (value) {
  bool nameValid = RegExp(r"^[a-zA-Z]").hasMatch(value ?? " ") ||
      !RegExp("^[\u0000-\u007F]+\$").hasMatch(value ?? " ");

  return value.toString().isEmpty
      ? txt("Name is required")
      : value.toString().length < 3
          ? txt('Too short')
          : !nameValid
              ? txt('Wrong name format')
              : null;
};

String? Function(dynamic) emailValidator = (value) {
  bool emailValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(value ?? " ");
  return !emailValid ? txt('Email is required') : null;
};

String? Function(dynamic) passwordValidator = (value) {
  // String msg = "${txt('Password must include')}: \n";

  // msg += !RegExp(r'^(?=.*?[A-Z])').hasMatch(value ?? "")
  //     ? "${txt('An uppercase character')}\n"
  //     : "";
  // msg += !RegExp(r'^(?=.*?[a-z])').hasMatch(value ?? "")
  //     ? "${txt('A lowercase character')}\n"
  //     : "";
  // msg += !RegExp(r'^(?=.*?[0-9])').hasMatch(value ?? "")
  //     ? "${txt('A special character')}\n"
  //     : "";
  // msg += !RegExp(r'^(?=.*?[!@#\$&*~.])').hasMatch(value ?? "")
  //     ? "${txt('A special character')} (!@#\\\$&*~.)" "\n"
  //     : "";

  // msg += value.toString().length < 8
  //     ? txt('Too short. Use at least 8 characters')
  //     : "";

  // String pattern =
  //     r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~.]).{8,}$';
  // var result = RegExp(pattern).hasMatch(value ?? "");

  return value.toString().isEmpty
      ? txt('Password is required')
      : value.toString().length < 8
          ? txt('Too short. Use at least 8 characters')
          : null;
};

Future<void> validatorPhone(
    BuildContext context, String oldPhoneNumber, String phone) async {
  if (phone.isEmpty) {
    popup(context, "Ok",
        cancel: false, description: "${txt('Empty phone number')}!");
    return;
  }
  if (phone.length != 8) {
    popup(context, "Ok",
        cancel: false, description: "${txt('Invalid phone number')}!");
    return;
  }
  if (phone ==
      context.read<UserProvider>().currentUser?.phoneNumber.toString()) {
    popup(context, "Ok",
        cancel: false,
        description: "${txt('You cannot update the same phone number')}!");
    return;
  }
  if (await UserService.checkExistingPhone(phone)) {
    popup(context, "Ok",
        cancel: false,
        description: "${txt('The phone number already exists')}!");
    return;
  }

  await context.read<UserProvider>().changePhoneNumber(phone).then((result) {
    if (result) {
      popup(context, "Ok",
              cancel: false,
              description:
                  "${txt('The phone number has been changed successfully')}.")
          .then((value) => Navigator.pop(context));
    } else {
      popup(context, "Ok",
              cancel: false,
              description: txt('Connection error, please try again later'))
          .then((value) => Navigator.pop(context));
    }
  });
}

bool textFieldVerifications(List<TextEditingController> lst) {
  for (var t in lst) {
    if (t.text.isEmpty) return false;
  }
  return true;
}
