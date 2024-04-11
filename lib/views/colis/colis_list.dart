import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/colis/add_colis.dart';
import 'package:jetpack/views/colis/colis_card.dart';
import 'package:jetpack/views/widgets/appbar.dart';

class ColisListScreen extends StatefulWidget {
  const ColisListScreen({super.key});

  @override
  State<ColisListScreen> createState() => _ColisListScreenState();
}

class _ColisListScreenState extends State<ColisListScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> function;

  @override
  void initState() {
    super.initState();
    function = FirebaseFirestore.instance.collection('colis').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Colis List'),
      backgroundColor: context.bgcolor,
      floatingActionButton: FloatingActionButton(
          backgroundColor: context.primaryColor,
          child:
              const Icon(Icons.assignment_add, color: Colors.white, size: 25),
          onPressed: () => context.moveTo(const AddColis())),
      body: SizedBox(
        width: context.w,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Gap(10),
                StreamBuilder(
                    stream: function,
                    builder: (context, data) {
                      if (data.connectionState == ConnectionState.active &&
                          data.data != null) {
                        return Column(
                          children: data.data!.docs
                              .map((e) => Colis.fromMap(e.data()))
                              .map((colis) => ColisCard(colis: colis))
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
