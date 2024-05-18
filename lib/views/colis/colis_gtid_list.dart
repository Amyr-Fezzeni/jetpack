import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/colis/add_colis.dart';
import 'package:jetpack/views/colis/colis_list.dart';
import 'package:jetpack/views/colis/confirmed_return.dart';
import 'package:jetpack/views/colis/magnifest_screen.dart';
import 'package:jetpack/views/colis/retrun_colis_admin.dart';
import 'package:jetpack/views/colis/retrun_colis_expeditor.dart';
import 'package:jetpack/views/widgets/appbar.dart';

class ColisGridList extends StatefulWidget {
  const ColisGridList({super.key});

  @override
  State<ColisGridList> createState() => _ColisGridListState();
}

class _ColisGridListState extends State<ColisGridList> {
  List<Colis> colis = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    colis = context.role == Role.admin
        ? context.adminWatch.allColis
        : context.expeditorWatch.allColis;
    return Scaffold(
      appBar: appBar('Colis List'),
      backgroundColor: context.bgcolor,
      floatingActionButton: context.currentUser.role != Role.expeditor
          ? null
          : FloatingActionButton(
              backgroundColor: context.primaryColor,
              child: const Icon(Icons.assignment_add,
                  color: Colors.white, size: 25),
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
                SizedBox(
                  width: context.w,
                  child: Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      if (context.currentUser.role == Role.expeditor)
                        gridData(
                            "In progress", colis, [ColisStatus.inProgress]),
                      if (context.currentUser.role == Role.expeditor)
                        SizedBox(
                          width: context.w * .5 - 30,
                          height: context.w * .5 - 30,
                          child: InkWell(
                            onTap: () => context.moveTo(const ManifestScreen()),
                            child: Card(
                              color: context.bgcolor,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 70,
                                    width: 70,
                                    child: Stack(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                bigRadius),
                                            color: context.primaryColor
                                                .withOpacity(.1),
                                          ),
                                          child: Center(
                                            child: Icon(Icons.note_alt_rounded,
                                                color: context.iconColor,
                                                size: 35),
                                          ),
                                        ),
                                        // Positioned(
                                        //     top: 0,
                                        //     right: 0,
                                        //     child: Container(
                                        //       height: 30,
                                        //       width: 30,
                                        //       decoration: BoxDecoration(
                                        //           color: context
                                        //               .primaryColor
                                        //               .withOpacity(.8),
                                        //           borderRadius:
                                        //               BorderRadius
                                        //                   .circular(
                                        //                       bigRadius)),
                                        //       child: Center(
                                        //         child: Txt(
                                        //             colis
                                        //                 .where((c) =>
                                        //                     c.status ==
                                        //                     status.name)
                                        //                 .length
                                        //                 .toString(),
                                        //             color: Colors.white),
                                        //       ),
                                        //     ))
                                      ],
                                    ),
                                  ),
                                  const Gap(10),
                                  Txt("List Manifest", bold: true)
                                ],
                              ),
                            ),
                          ),
                        ),
                      gridData(
                          "Ready for delivery", colis, [ColisStatus.ready]),
                      if (context.role == Role.admin)
                        gridData("Pickup", colis, [ColisStatus.pickup]),
                      gridData("At the depot", colis, [ColisStatus.depot]),
                      gridData(
                          "Return depot", colis, [ColisStatus.returnDepot]),
                      gridData("In the process of delivery", colis,
                          [ColisStatus.inDelivery, ColisStatus.confirmed]),
                      gridData("Delivered", colis, [ColisStatus.delivered]),
                      gridData("Appointment", colis, [ColisStatus.appointment]),
                      if (context.role == Role.expeditor)
                        gridData(
                            "Colis canceled",
                            colis,
                            [
                              ColisStatus.canceled,
                              ColisStatus.returnConfirmed,
                              ColisStatus.returnExpeditor,
                            ],
                            screen: const ReturnColisExpeditor()),
                      if (context.role == Role.admin)
                        gridData(
                            "Colis canceled",
                            colis,
                            [
                              ColisStatus.canceled,
                              ColisStatus.returnConfirmed,
                              ColisStatus.returnExpeditor,
                            ],
                            screen: const ReturnColisAdmin()),
                      if (context.role == Role.admin)
                        gridData(
                            "Confirmed return",
                            colis,
                            [
                              ColisStatus.returnConfirmed,
                            ],
                            screen: const ConfirmedReturnScreen()),
                    ],
                  ),
                ),
                const Gap(50)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget gridData(String title, List<Colis> colis, List<ColisStatus> status,
          {Widget? screen}) =>
      Builder(builder: (context) {
        return SizedBox(
          width: context.w * .5 - 30,
          height: context.w * .5 - 30,
          child: InkWell(
            onTap: () => context
                .moveTo(screen ?? ColisList(title: title, status: status)),
            child: Card(
              color: context.bgcolor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 70,
                    width: 70,
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
                                child: Txt(
                                    colis
                                        .where((c) => status
                                            .map((e) => e.name)
                                            .contains(c.status))
                                        .length
                                        .toString(),
                                    color: Colors.white,
                                    translate: false),
                              ),
                            ))
                      ],
                    ),
                  ),
                  const Gap(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child:
                        Txt(title, bold: true, center: true, translate: false),
                  )
                ],
              ),
            ),
          ),
        );
      });
}
