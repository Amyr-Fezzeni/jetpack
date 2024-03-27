import 'package:flutter/material.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/settings/password%20&%20security/email/change_email.dart';
import 'package:jetpack/views/settings/password%20&%20security/password/change_password.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/loader.dart';

class PasswordSecurityScreen extends StatelessWidget {
  const PasswordSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar("Password & security", leading: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            buildMenuTile(
                title: "Email",
                subtitle: "change your Email",
                icon: Icons.email_outlined,
                onClick: () => context.moveTo(const ChangeEmail())),
            buildMenuTile(
                title: "Password",
                subtitle: "change your password",
                icon: Icons.lock_outline_rounded,
                onClick: () => context.moveTo(const ChangePassword())),
          ],
        ),
      ),
    );
  }
}
