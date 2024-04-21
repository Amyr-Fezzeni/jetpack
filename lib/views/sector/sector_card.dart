import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/constants/style.dart';
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
        title: Row(
          children: [
            Flexible(child: Txt(sector.name)),
            const Gap(5),
            if (sector.delivery['id'].isEmpty)
              const Icon(Icons.person_remove_alt_1_rounded,
                  color: red, size: 20)
            
          ],
        ),
        subtitle: Txt(sector.regions.join(', '),
            size: 10, color: context.iconColor, maxLines: 2),
        trailing: InkWell(
          onTap: () => context.moveTo(AddSector(sector: sector)),
          child:
              Icon(Icons.edit_note_sharp, color: context.iconColor, size: 25),
        ),
      ),
    );
  }
}
