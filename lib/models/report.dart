import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Report {
  final String id;
  String expeditorId;
  String phonenUmber;
  String colisId;
  String deliveryFullName;
  String deliveryPhoneNumber;
  Report({
    required this.id,
    required this.expeditorId,
    required this.phonenUmber,
    required this.colisId,
    required this.deliveryFullName,
    required this.deliveryPhoneNumber,
  });
  //admin ?

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'expeditorId': expeditorId,
      'phonenUmber': phonenUmber,
      'colisId': colisId,
      'deliveryFullName': deliveryFullName,
      'deliveryPhoneNumber': deliveryPhoneNumber,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] as String,
      expeditorId: map['expeditorId'] as String,
      phonenUmber: map['phonenUmber'] as String,
      colisId: map['colisId'] as String,
      deliveryFullName: map['deliveryFullName'] as String,
      deliveryPhoneNumber: map['deliveryPhoneNumber'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Report.fromJson(String source) => Report.fromMap(json.decode(source) as Map<String, dynamic>);
}
