import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/report.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/colis/colis_card.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/custom_drop_down.dart';
import 'package:jetpack/views/widgets/loader.dart';

class ReportReview extends StatefulWidget {
  final Report report;
  const ReportReview({super.key, required this.report});

  @override
  State<ReportReview> createState() => _ReportReviewState();
}

class _ReportReviewState extends State<ReportReview> {
  late Report report;
  @override
  void initState() {
    super.initState();
    report = widget.report;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar('Report'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
              Row(
                children: [
                  Txt(widget.report.expeditorName, bold: true,translate: false),
                  const Spacer(),
                  phoneWidget(widget.report.expeditorPhone, 1)
                ],
              ),
              divider(top: 10),
              Txt(widget.report.reportMessage,translate: false),
              divider(top: 10, bottom: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 150,
                    child: SimpleDropDown(
                        selectedValue: report.status,
                        values: ReportStatus.values.map((e) => e.name).toList(),
                        onChanged: (value) {
                          setState(() {
                            report.status = value;
                          });
                          FirebaseFirestore.instance
                              .collection('reports')
                              .doc(report.id)
                              .update(report.toMap());
                        },
                        hint: txt('Status')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
