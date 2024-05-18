import 'package:flutter/material.dart';
import 'package:jetpack/models/client.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/clients/add_client.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  const ClientCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.bgcolor,
      child: ListTile(
        title: Txt('${client.firstName} ${client.lastName}',translate: false),
        subtitle: Txt(client.phoneNumber, size: 10, color: context.iconColor,translate: false),
        trailing: InkWell(
          onTap: () => context.moveTo(AddClient(client: client)),
          child: Icon(Icons.arrow_forward_ios_rounded,
              color: context.iconColor, size: 25),
        ),
      ),
    );
  }
}
