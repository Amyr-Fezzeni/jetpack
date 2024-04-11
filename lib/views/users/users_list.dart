import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/users/add_user.dart';
import 'package:jetpack/views/users/user_card.dart';
import 'package:jetpack/views/widgets/appbar.dart';

class UsersListScreen extends StatefulWidget {
  final Role role;
  const UsersListScreen({super.key, required this.role});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> function;

  @override
  void initState() {
    super.initState();
    function = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: widget.role.name)
        .snapshots();
    log(widget.role.name.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
          '${widget.role == Role.admin ? 'Admin' : widget.role == Role.expeditor ? 'Expeditor' : 'Delivery'} List'),
      backgroundColor: context.bgcolor,
      floatingActionButton: FloatingActionButton(
          backgroundColor: context.primaryColor,
          child: const Icon(Icons.person_add_alt_rounded,
              color: Colors.white, size: 25),
          onPressed: () => context.moveTo(AddUser(
                role: widget.role,
              ))),
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
                              .where((user) => user.id != context.userId)
                              .map((user) =>
                                  UserCard(user: user, role: widget.role))
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
}
