import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/popup.dart';
import 'package:provider/provider.dart';

import '../../../../providers/theme_notifier.dart';
import '../../constants/fixed_messages.dart';
import '../../models/report.dart';
import '../../providers/user_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  TextEditingController controller = TextEditingController(text: "");
  FocusNode focus = FocusNode();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var style = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: style.bgColor,
      appBar: appBar('Report'),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 70, bottom: 20),
                height: 200,
                // color: Colors.amber,
                child: Image.asset(
                  "assets/images/support.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(
                width: size.width / 1.5,
                child: Text(
                  txt("Submit a ticket and our Support team will assist you shortly"),
                  textAlign: TextAlign.center,
                  style: style.text18,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  width: size.width,
                  height: 200,
                  child: TextFormField(
                    focusNode: FocusNode(),
                    onFieldSubmitted: (val) {},
                    controller: controller,
                    maxLength: 50,
                    maxLines: 20,
                    enableIMEPersonalizedLearning: false,
                    onEditingComplete: () {},
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: style.text18,
                    decoration: InputDecoration(
                      filled: true,
                      counter: const Offstage(),
                      fillColor: Colors.white.withOpacity(0.1),
                      hintText: txt("Message"),
                      hintStyle: style.text18.copyWith(
                          color: style.invertedColor.withOpacity(0.4)),
                      contentPadding:
                          const EdgeInsets.only(left: 20, bottom: 16, top: 16),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: red, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // suffixIcon: widget.sufixIcon,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: style.invertedColor.withOpacity(0.3),
                            width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: red, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: style.invertedColor.withOpacity(0.3),
                            width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.redAccent, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorStyle: context.text
                          .copyWith(fontSize: 14, color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              gradientButton(
                  function: () {
                    if (controller.text.length > 5) {
                      final user = context.userprovider.currentUser!;

                      Report report = Report(
                          id: generateId(),
                          dateCreated: DateTime.now(),
                          expeditorId: user.id,
                          expeditorName: user.getFullName(),
                          expeditorPhone: user.phoneNumber,
                          reportMessage: controller.text,
                          status: ReportStatus.review.name,
                          agencyId: user.agency?['id']);

                      FirebaseFirestore.instance
                          .collection("reports")
                          .doc(report.id)
                          .set(report.toMap())
                          .then((value) => popup(context,
                              title: txt("Report"),
                              cancel: false,
                              confirmFunction: () => context.pop(),
                              description: txt(reportMessage)));
                    }
                  },
                  w: size.width * .7,
                  text: txt("Send"))
            ],
          ),
        ),
      ),
    );
  }
}
