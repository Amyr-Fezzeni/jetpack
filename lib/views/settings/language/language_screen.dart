import 'package:flutter/material.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/widgets/appbar.dart';
import 'package:jetpack/services/util/language.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int index = LanguageModel.values.indexOf(context.currentLanguage);
    Widget card(LanguageModel lang) => InkWell(
          onTap: () => context.userprovider.setDefaultLanguage(lang),
          child: Container(
            decoration: const BoxDecoration(),
            padding: const EdgeInsets.symmetric(vertical: 5).copyWith(left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Txt(capitalize(lang.name),
                    style: context.text.copyWith(fontWeight: FontWeight.bold)),
                Radio(
                    value: LanguageModel.values.indexOf(lang),
                    groupValue: index,
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return context.primaryColor;
                      }
                      return context.invertedColor.withOpacity(.7);
                    }),
                    onChanged: (value) =>
                        context.userprovider.setDefaultLanguage(lang))
              ],
            ),
          ),
        );
    return Scaffold(
      backgroundColor: context.bgcolor,
      appBar: appBar("Language"),
      body: Column(children: LanguageModel.values.map((e) => card(e)).toList()),
    );
  }
}
