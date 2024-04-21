import 'dart:convert';

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
      dateCreated: map['dateCreated'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] as int) : null,
      date: map['date'] as String,
      collectionDate: map['collectionDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['collectionDate'] as int) : null,
      colis: List<String>.from(map['colis'] ??[]),
      price: map['price'] as double,
      note: map['note'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory RunSheet.fromJson(String source) => RunSheet.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RunSheet(id: $id, agenceId: $agenceId, deliveryId: $deliveryId, dateCreated: $dateCreated, date: $date, collectionDate: $collectionDate, colis: $colis, price: $price, note: $note)';
  }
}
