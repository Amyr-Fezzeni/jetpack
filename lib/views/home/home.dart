import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/widgets/bottuns.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/text_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentFilter = "Runsheet";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgcolor,
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const Gap(40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Icon(
                        Icons.menu,
                        color: context.invertedColor.withOpacity(.7),
                        size: 30,
                      ),
                    ),
                    const Gap(10),
                    logoWidget(size: 100),
                    const Spacer(),
                    profileIcon()
                  ],
                ),
                const Gap(20),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hint: txt('Search'),
                        controller: TextEditingController(),
                        leadingIcon: Icon(Icons.search,
                            color: context.invertedColor.withOpacity(.7),
                            size: 25),
                        marginH: 0,
                        marginV: 0,
                        height: 50,
                      ),
                    ),
                    const Gap(10),
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          boxShadow: defaultShadow,
                          borderRadius: BorderRadius.circular(smallRadius),
                          color: context.bgcolor),
                      child: Container(
                          height: 45,
                          width: 45,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(smallRadius),
                              color: context.invertedColor.withOpacity(.1)),
                          child: svgImage(filter, size: 25, function: () {
                            context.showPopUpScreen(DraggableScrollableSheet(
                              initialChildSize: .5,
                              builder: (context, scrollController) => Container(
                                height: 200,
                                color: context.bgcolor,
                                child: const Center(),
                              ),
                            ));
                          })),
                    )
                  ],
                ),
                const Gap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...[
                      'Runsheet',
                      'Paiement',
                      'Retour',
                      'Pickup',
                    ].map((title) => Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: InkWell(
                            onTap: () => setState(() {
                              currentFilter = title;
                            }),
                            child: Txt(title,
                                color: title == currentFilter
                                    ? context.primaryColor
                                    : null),
                          ),
                        ))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
