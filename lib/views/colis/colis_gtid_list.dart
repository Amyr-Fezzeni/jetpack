import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/colis/add_colis.dart';
import 'package:jetpack/views/colis/colis_list.dart';
import 'package:jetpack/views/widgets/appbar.dart';

class ColisGridList extends StatefulWidget {
  const ColisGridList({super.key});

  @override
  State<ColisGridList> createState() => _ColisGridListState();
}

class _ColisGridListState extends State<ColisGridList> {
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
                        List<Colis> colis = data.data!.docs
                            .map((e) => Colis.fromMap(e.data()))
                            .toList();
                        return SizedBox(
                          width: context.w,
                          child: Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              gridData(
                                  "In progress",
                                  colis
                                      .where((c) =>
                                          c.status ==
                                          ColisStatus.inProgress.name)
                                      .toList()),
                              gridData(
                                  "At the depot",
                                  colis
                                      .where((c) =>
                                          c.status == ColisStatus.depot.name)
                                      .toList()),
                              gridData(
                                  "Return depot",
                                  colis
                                      .where((c) =>
                                          c.status ==
                                          ColisStatus.returnDepot.name)
                                      .toList()),
                              gridData(
                                  "In the process of delivery",
                                  colis
                                      .where((c) =>
                                          c.status ==
                                          ColisStatus.inDelivery.name)
                                      .toList()),
                              gridData(
                                  "Delivered",
                                  colis
                                      .where((c) =>
                                          c.status ==
                                          ColisStatus.delivered.name)
                                      .toList()),
                              gridData(
                                  "delivered Paid",
                                  colis
                                      .where((c) =>
                                          c.status ==
                                          ColisStatus.deliveredPaid.name)
                                      .toList()),
                            ],
                          ),
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

  Widget gridData(String title, List<Colis> colisData) =>
      Builder(builder: (context) {
        return SizedBox(
          width: context.w * .5 - 30,
          height: context.w * .5 - 30,
          child: InkWell(
            onTap: () =>
                context.moveTo(ColisList(title: title, colisData: colisData)),
            child: Card(
              color: context.bgcolor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 70,
                    width: 70,
                    // color: Colors.amber,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(bigRadius),
                            color: context.primaryColor.withOpacity(.1),
                          ),
                          child: Center(
                            child: Icon(Icons.grid_view_rounded,
                                color: context.iconColor, size: 35),
                          ),
                        ),
                        Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  color: context.primaryColor.withOpacity(.8),
                                  borderRadius:
                                      BorderRadius.circular(bigRadius)),
                              child: Center(
                                child: Txt(colisData.length.toString(),
                                    color: Colors.white),
                              ),
                            ))
                      ],
                    ),
                  ),
                  const Gap(10),
                  Txt(title, bold: true)
                ],
              ),
            ),
          ),
        );
      });
}
