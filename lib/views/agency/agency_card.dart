import 'package:flutter/material.dart';
import 'package:jetpack/models/agency.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/agency/add_agency.dart';

class AgencyCard extends StatelessWidget {
  final Agency agency;
  const AgencyCard({super.key, required this.agency});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.bgcolor,
      child: ListTile(
        title: Txt(agency.name,translate: false),
        subtitle: Txt(agency.agencyLead, size: 10, color: context.iconColor,translate: false),
        trailing: InkWell(
          onTap: () => context.moveTo(AddAgency(agency: agency)),
          child:
              Icon(Icons.edit_note_sharp, color: context.iconColor, size: 25),
        ),
      ),
    );
  }
}
