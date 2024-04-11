import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class RunSheet {
  final String id;
  String agenceId;
  String deliveryId;
  String expeditorId;
  DateTime? dateCreated;
  DateTime? date;
  DateTime? collectionDate;
  List<String> colis;
  List<String> exchangeColis;
  int tentative;
  double price;
  String note;
  RunSheet({
    required this.id,
    required this.agenceId,
    required this.deliveryId,
    required this.expeditorId,
    required this.dateCreated,
    required this.date,
    required this.collectionDate,
    required this.colis,
    required this.exchangeColis,
    required this.tentative,
    required this.price,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'agenceId': agenceId,
      'deliveryId': deliveryId,
      'expeditorId': expeditorId,
      'dateCreated': dateCreated?.millisecondsSinceEpoch,
      'date': date?.millisecondsSinceEpoch,
      'collectionDate': collectionDate?.millisecondsSinceEpoch,
      'colis': colis,
      'exchangeColis': exchangeColis,
      'tentative': tentative,
      'price': price,
      'note': note,
    };
  }

  factory RunSheet.fromMap(Map<String, dynamic> map) {
    return RunSheet(
      id: map['id'] as String,
      agenceId: map['agenceId'] as String,
      deliveryId: map['deliveryId'] as String,
      expeditorId: map['expeditorId'] as String,
      dateCreated: map['dateCreated'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] as int) : null,
      date: map['date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['date'] as int) : null,
      collectionDate: map['collectionDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['collectionDate'] as int) : null,
      colis: List<String>.from(map['colis'] ??[]),
      exchangeColis: List<String>.from(map['exchangeColis'] ??[]),
      tentative: map['tentative'] as int,
      price: map['price'] as double,
      note: map['note'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory RunSheet.fromJson(String source) => RunSheet.fromMap(json.decode(source) as Map<String, dynamic>);
}
