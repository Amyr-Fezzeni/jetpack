import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/models/app_settings/theme.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
// import 'package:jetpack/views/settings/contact%20info/contact_info.dart';
// import 'package:jetpack/views/settings/password%20&%20security/password_security.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/default_screen.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/settings/language/language_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar('Settings', leading: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Txt('User settings', color: context.primaryColor),
              divider(bottom: 10),
              // buildMenuTile(
              //     title: 'Contact info',
              //     icon: Icons.contact_page_outlined,
              //     screen: const EditProfileScreen()),
              // Txt('Profile settings', color: context.primaryColor),
              // divider(bottom: 10),
              // buildMenuTile(
              //     title: 'Password & security',
              //     icon: Icons.lock_outline_rounded,
              //     screen: const PasswordSecurityScreen()),
              buildMenuTile(
                  title: 'Privacy preferences',
                  icon: Icons.privacy_tip_outlined,
                  screen: const DefaultScreen(
                    title: 'Privacy preferences',
                    appbar: true,
                  )),
              Txt('App Settings', color: context.primaryColor),
              divider(bottom: 10),
              buildMenuTile(
                  title: 'Language',
                  icon: Icons.language_rounded,
                  screen: const LanguageScreen()),
              ListTile(
                  title: Txt("App theme"),
                  trailing: CupertinoSwitch(
                      value: context.isDark,
                      activeColor: context.primaryColor,
                      onChanged: (value) {
                        context.theme.changeDarkMode(
                            value ? AppThemeModel.dark : AppThemeModel.light);
                      })),
              ListTile(
                  title: Txt("Notification"),
                  trailing: CupertinoSwitch(
                      value: context.currentUser.notificationStatus,
                      activeColor: context.primaryColor,
                      onChanged: (value) {
                        context.notificationProvider
                            .updateNotificationStatus(value);
                      })),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
