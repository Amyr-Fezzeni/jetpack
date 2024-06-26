import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

enum ReportStatus { review, accepted, rejected }

class Report {
  final String id;
  String expeditorId;
  String expeditorName;
  String expeditorPhone;
  String reportMessage;
  String status;
  String agencyId;
  DateTime dateCreated;

  Report({
    required this.id,
    required this.expeditorId,
    required this.expeditorName,
    required this.expeditorPhone,
    required this.reportMessage,
    required this.status,
    required this.agencyId,
    required this.dateCreated,
  });
  //admin ?

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'expeditorId': expeditorId,
      'expeditorName': expeditorName,
      'expeditorPhone': expeditorPhone,
      'reportMessage': reportMessage,
      'status': status,
      'agencyId': agencyId,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] as String,
      expeditorId: map['expeditorId'] as String,
      expeditorName: map['expeditorName'] as String,
      expeditorPhone: map['expeditorPhone'] as String,
      reportMessage: map['reportMessage'] as String,
      status: map['status'] as String,
      agencyId: map['agencyId'] as String,
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Report.fromJson(String source) =>
      Report.fromMap(json.decode(source) as Map<String, dynamic>);
}
