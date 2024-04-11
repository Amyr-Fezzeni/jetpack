import 'package:flutter/material.dart';
import 'package:jetpack/models/sector.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/sector/add_sector.dart';

class SectorCard extends StatelessWidget {
  final Sector sector;
  const SectorCard({super.key, required this.sector});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.bgcolor,
      child: ListTile(
        title: Txt(sector.name),
        subtitle:
            Txt(sector.regions.join(', '), size: 10, color: context.iconColor),
        trailing: InkWell(
          onTap: () => context.moveTo(AddSector(sector: sector)),
          child:
              Icon(Icons.edit_note_sharp, color: context.iconColor, size: 25),
        ),
      ),
    );
  }
}
