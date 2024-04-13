import 'package:flutter/material.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/colis/add_colis.dart';

class ColisCard extends StatelessWidget {
  final Colis colis;
  const ColisCard({super.key, required this.colis});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.bgcolor,
      child: ListTile(
        title: Txt(capitalize(colis.name), bold: true),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Txt(colis.id, size: 10, color: context.primaryColor, bold: true),
            Txt("${colis.price.toStringAsFixed(2)} Dt",
                size: 10, color: context.iconColor),
          ],
        ),
        trailing: InkWell(
          onTap: () => context.moveTo(AddColis(colis: colis)),
          child: Icon(Icons.arrow_forward_ios_rounded,
              color: context.iconColor, size: 25),
        ),
      ),
    );
  }
}
