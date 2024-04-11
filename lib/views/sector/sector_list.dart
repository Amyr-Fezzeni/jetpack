import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/sector.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/views/sector/add_sector.dart';
import 'package:jetpack/views/sector/sector_card.dart';
import 'package:jetpack/views/widgets/appbar.dart';

class SectorListScreen extends StatefulWidget {
  const SectorListScreen({super.key});

  @override
  State<SectorListScreen> createState() => _SectorListScreenState();
}

class _SectorListScreenState extends State<SectorListScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> function;

  @override
  void initState() {
    super.initState();
    function = FirebaseFirestore.instance.collection('sector').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Sector List'),
      backgroundColor: context.bgcolor,
      floatingActionButton: FloatingActionButton(
          backgroundColor: context.primaryColor,
          child:
              const Icon(Icons.assignment_add, color: Colors.white, size: 25),
          onPressed: () => context.moveTo(const AddSector())),
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
                              .map((e) => Sector.fromMap(e.data()))
                              .map((sector) => SectorCard(sector: sector))
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
