import 'dart:convert';

import 'package:jetpack/models/report.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class RelaunchColis {
  final String id;
  String colisId;
  String expeditorId;
  String expeditorPhone;
  String expeditorName;
  String agencyId;
  String status;
  DateTime dateCreated;
  RelaunchColis({
    required this.id,
    required this.colisId,
    required this.expeditorId,
    required this.expeditorPhone,
    required this.expeditorName,
    required this.agencyId,
    required this.status,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'colisId': colisId,
      'expeditorId': expeditorId,
      'expeditorPhone': expeditorPhone,
      'expeditorName': expeditorName,
      'agencyId': agencyId,
      'status': status,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
    };
  }

  factory RelaunchColis.fromMap(Map<String, dynamic> map) {
    return RelaunchColis(
      id: map['id'] as String,
      colisId: map['colisId'] as String,
      expeditorId: map['expeditorId'] as String,
      expeditorPhone: map['expeditorPhone'] as String,
      expeditorName: map['expeditorName'] as String,
      agencyId: map['agencyId'] as String,
      status: map['status'] ?? ReportStatus.review.name,
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory RelaunchColis.fromJson(String source) =>
      RelaunchColis.fromMap(json.decode(source) as Map<String, dynamic>);
}
