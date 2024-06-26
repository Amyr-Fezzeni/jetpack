import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/users/add_user.dart';
import 'package:jetpack/views/users/delivery_payment_admin.dart';
import 'package:jetpack/views/users/expeditor_tracking.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:url_launcher/url_launcher.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final Role role;
  const UserCard({super.key, required this.user, required this.role});

  @override
  Widget build(BuildContext context) {
    return role == Role.delivery
        ? DeliveryCard(user: user)
        : role == Role.expeditor
            ? ExpeditorCard(user: user)
            : Card(
                color: context.bgcolor,
                child: ListTile(
                  title: Txt(user.getFullName(),translate: false),
                  subtitle: Txt(user.email, size: 10, color: context.iconColor,translate: false),
                  leading: profileIcon(url: user.photo),
                  trailing: InkWell(
                    onTap: () =>
                        context.moveTo(AddUser(user: user, role: role)),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        color: context.iconColor, size: 25),
                  ),
                ),
              );
  }
}

class DeliveryCard extends StatelessWidget {
  final UserModel user;
  const DeliveryCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: context.bgcolor,
          boxShadow: defaultShadow,
          borderRadius: defaultSmallRadius),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profileIcon(url: user.photo),
          const Gap(5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(user.getFullName(), bold: true,translate: false),
                Txt(user.email, size: 10, color: context.iconColor,translate: false)
              ],
            ),
          ),
          const Gap(5),
          Column(
            children: [
              InkWell(
                onTap: () =>
                    context.moveTo(AddUser(user: user, role: Role.delivery)),
                child: Icon(Icons.edit_note_sharp,
                    color: context.iconColor, size: 25),
              ),
              const Gap(5),
              InkWell(
                onTap: () => context.moveTo(DeliveryPaymentAdmin(user: user)),
                child: Icon(Icons.payments_outlined,
                    color: context.iconColor, size: 25),
              ),
              const Gap(5),
              InkWell(
                onTap: () async {
                  if (user.location == null) {
                    popup(context,
                        description: "This user doesn't share location",
                        cancel: false);
                    return;
                  }
                  // customPopup(context, DeliveryTrackingMap(delivery: user));
                  final location = user.location!;
                  var uri = Uri.parse(
                      "https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}");

                  await launchUrl(uri);
                },
                child: Icon(Icons.location_on_outlined,
                    color: context.iconColor, size: 25),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ExpeditorCard extends StatelessWidget {
  final UserModel user;
  const ExpeditorCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: context.bgcolor,
          boxShadow: defaultShadow,
          borderRadius: defaultSmallRadius),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profileIcon(url: user.photo),
          const Gap(5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(user.getFullName(), bold: true,translate: false),
                Txt(user.email, size: 10, color: context.iconColor,translate: false)
              ],
            ),
          ),
          const Gap(5),
          Column(
            children: [
              InkWell(
                onTap: () =>
                    context.moveTo(AddUser(user: user, role: Role.expeditor)),
                child: Icon(Icons.edit_note_sharp,
                    color: context.iconColor, size: 25),
              ),
              InkWell(
                onTap: () =>
                    context.moveTo(ExpeditorTrackingScreen(user: user)),
                child: Icon(Icons.payments_outlined,
                    color: context.iconColor, size: 25),
              ),
            ],
          )
        ],
      ),
    );
  }
}
