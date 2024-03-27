import 'package:flutter/material.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:provider/provider.dart';
import 'package:jetpack/providers/theme_notifier.dart';

class Gender {
  String name;
  IconData icon;
  bool isSelected;

  Gender(this.name, this.icon, this.isSelected);
}

class GenderRadio extends StatelessWidget {
  final Gender _gender;

  const GenderRadio(this._gender, {super.key});

  @override
  Widget build(BuildContext context) {
    var style = context.watch<ThemeNotifier>();
    return Card(
      color: _gender.isSelected
          ? context.invertedColor.withOpacity(.9)
          : style.bgColor,
      child: Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(
            // color: style.invertedColor.withOpacity(.1),
            border: Border.all(
                color: _gender.isSelected
                    ? context.primaryColor
                    : style.invertedColor.withOpacity(.2)),
            borderRadius: BorderRadius.circular(4)),
        alignment: Alignment.center,
        // margin: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _gender.icon,
              color: _gender.isSelected ? context.primaryColor : style.invertedColor,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              _gender.name,
              style: style.text18.copyWith(
                color: _gender.isSelected ? context.primaryColor : style.invertedColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
