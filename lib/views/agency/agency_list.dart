import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/agency.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/agency/add_agency.dart';
import 'package:jetpack/views/agency/agency_card.dart';
import 'package:jetpack/views/widgets/appbar.dart';

class AgencyListScreen extends StatefulWidget {
  const AgencyListScreen({super.key});

  @override
  State<AgencyListScreen> createState() => _AgencyListScreenState();
}

class _AgencyListScreenState extends State<AgencyListScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> function;

  @override
  void initState() {
    super.initState();
    function = FirebaseFirestore.instance.collection('agency').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Agency List'),
      backgroundColor: context.bgcolor,
      floatingActionButton: FloatingActionButton(
          backgroundColor: context.primaryColor,
          child:
              const Icon(Icons.assignment_add, color: Colors.white, size: 25),
          onPressed: () => context.moveTo(const AddAgency())),
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
                              .map((e) => Agency.fromMap(e.data()))
                              .map((agency) => AgencyCard(agency: agency))
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
