import 'dart:convert';

import 'package:jetpack/models/colis.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class RunSheet {
  final String id;
  String agenceId;
  String deliveryId;
  DateTime? dateCreated;
  String date;
  DateTime? collectionDate;
  List<String> colis;

  double price;
  String note;
  RunSheet({
    required this.id,
    required this.agenceId,
    required this.deliveryId,
    required this.dateCreated,
    required this.date,
    required this.collectionDate,
    required this.colis,
    required this.price,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'agenceId': agenceId,
      'deliveryId': deliveryId,
      'dateCreated': dateCreated?.millisecondsSinceEpoch,
      'date': date,
      'collectionDate': collectionDate?.millisecondsSinceEpoch,
      'colis': colis,
      'price': price,
      'note': note,
    };
  }

  factory RunSheet.fromMap(Map<String, dynamic> map) {
    return RunSheet(
      id: map['id'] as String,
      agenceId: map['agenceId'] as String,
      deliveryId: map['deliveryId'] as String,
      dateCreated: map['dateCreated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] as int)
          : null,
      date: map['date'] as String,
      collectionDate: map['collectionDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['collectionDate'] as int)
          : null,
      colis: List<String>.from(map['colis'] ?? []),
      price: map['price'] as double,
      note: map['note'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory RunSheet.fromJson(String source) =>
      RunSheet.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RunSheet(id: $id, agenceId: $agenceId, deliveryId: $deliveryId, dateCreated: $dateCreated, date: $date, collectionDate: $collectionDate, colis: $colis, price: $price, note: $note)';
  }
}

class RunsheetPdf {
  final String id;
  String agenceName;
  String deliveryName;
  String deliveryCin;
  String matricule;
  String date;
  List<Colis> colis;
  double price;
  String note;
  RunsheetPdf({
    required this.id,
    required this.agenceName,
    required this.deliveryName,
    required this.deliveryCin,
    required this.matricule,
    required this.date,
    required this.colis,
    required this.price,
    required this.note,
  });
}

class EndOfDayReport {
  final String id;
  String agenceId;
  String agenceName;
  String sectorId;
  String sectorName;
  String deliveryId;
  DateTime dateCreated;
  String date;
  DateTime collectionDate;
  List<Map<String, dynamic>> colis;
  EndOfDayReport({
    required this.id,
    required this.agenceId,
    required this.agenceName,
    required this.sectorId,
    required this.sectorName,
    required this.deliveryId,
    required this.dateCreated,
    required this.date,
    required this.collectionDate,
    required this.colis,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'agenceId': agenceId,
      'agenceName': agenceName,
      'sectorId': sectorId,
      'sectorName': sectorName,
      'deliveryId': deliveryId,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'date': date,
      'collectionDate': collectionDate.millisecondsSinceEpoch,
      'colis': colis,
    };
  }

  factory EndOfDayReport.fromMap(Map<String, dynamic> map) {
    return EndOfDayReport(
      id: map['id'] as String,
      agenceId: map['agenceId'] as String,
      agenceName: map['agenceName'] as String,
      sectorId: map['sectorId'] as String,
      sectorName: map['sectorName'] as String,
      deliveryId: map['deliveryId'] as String,
      dateCreated:
          DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] as int),
      date: map['date'] as String,
      collectionDate:
          DateTime.fromMillisecondsSinceEpoch(map['collectionDate'] as int),
      colis: List<Map<String, dynamic>>.from(
        (map['colis'] as List<dynamic>).map<Map<String, dynamic>>((x) => x),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory EndOfDayReport.fromJson(String source) =>
      EndOfDayReport.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EndOfDayReport(id: $id, agenceId: $agenceId, agenceName: $agenceName, sectorId: $sectorId, sectorName: $sectorName, deliveryId: $deliveryId, dateCreated: $dateCreated, date: $date, collectionDate: $collectionDate, colis: $colis)';
  }
}
