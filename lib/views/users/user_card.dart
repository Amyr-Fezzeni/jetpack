import 'package:flutter/material.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/users/add_user.dart';
import 'package:jetpack/views/widgets/bottuns.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final Role role;
  const UserCard({super.key, required this.user, required this.role});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.bgcolor,
      child: ListTile(
        title: Txt(user.getFullName()),
        subtitle: Txt(user.email, size: 10, color: context.iconColor),
        leading: profileIcon(url: user.photo),
        trailing: InkWell(
          onTap: () => context.moveTo(AddUser(user: user, role: role)),
          child: Icon(Icons.arrow_forward_ios_rounded,
              color: context.iconColor, size: 25),
        ),
      ),
    );
  }
}
