import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/widgets/appbar.dart';

class DeliveryPaymentAdmin extends StatefulWidget {
  final UserModel user;
  const DeliveryPaymentAdmin({super.key, required this.user});

  @override
  State<DeliveryPaymentAdmin> createState() => _DeliveryPaymentAdminState();
}

class _DeliveryPaymentAdminState extends State<DeliveryPaymentAdmin> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> function;

  @override
  void initState() {
    super.initState();
    function = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: Role.delivery.name)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Delivery Payment List'),
      backgroundColor: context.bgcolor,
      body: SizedBox(
        width: context.w,
        height: context.h,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Gap(10),
                StreamBuilder(
                    stream: function,
                    builder: (context, data) {
                      if (data.connectionState == ConnectionState.active &&
                          data.data != null) {
                        return Column(
                          children: data.data!.docs
                              .map((e) => UserModel.fromMap(e.data()))
                              .map((user) => userPaymentCard(user))
                              .toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget userPaymentCard(UserModel user) => Container();
}
