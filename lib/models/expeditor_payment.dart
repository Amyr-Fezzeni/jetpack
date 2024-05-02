import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ExpeditorPayment {
  final String id;
  List<String> colis;
  String expeditorId;
  String expeditorName;
  String expeditorPhoneNumber;
  String deliveryId;
  String deliveryName;
  DateTime date;

  final double price;
  final double totalprice;
  final double deliveryPrice;
  final bool recived;
  String adress;
  String region;
  ExpeditorPayment(
      {required this.id,
      required this.colis,
      required this.expeditorId,
      required this.expeditorName,
      required this.expeditorPhoneNumber,
      required this.deliveryId,
      required this.deliveryName,
      required this.price,
      required this.totalprice,
      required this.deliveryPrice,
      required this.recived,
      required this.region,
      required this.adress,
      required this.date});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'colis': colis,
      'expeditorId': expeditorId,
      'expeditorName': expeditorName,
      'expeditorPhoneNumber': expeditorPhoneNumber,
      'deliveryId': deliveryId,
      'deliveryName': deliveryName,
      'date': date.millisecondsSinceEpoch,
      'price': price,
      'totalprice': totalprice,
      'deliveryPrice': deliveryPrice,
      'recived': recived,
      'region': region,
      'adress':adress
    };
  }

  factory ExpeditorPayment.fromMap(Map<String, dynamic> map) {
    return ExpeditorPayment(
      id: map['id'] as String,
      colis: List<String>.from((map['colis'] ?? [])),
      expeditorId: map['expeditorId'] as String,
      expeditorName: map['expeditorName'] as String,
      expeditorPhoneNumber: map['expeditorPhoneNumber'] as String,
      deliveryId: map['deliveryId'] as String,
      deliveryName: map['deliveryName'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      price: map['price'] as double,
      totalprice: map['totalprice'] as double,
      deliveryPrice: map['deliveryPrice'] as double,
      recived: map['recived'] as bool,
      region: map['region'] as String,
      adress: map['adress']??''
    );
  }

  String toJson() => json.encode(toMap());

  factory ExpeditorPayment.fromJson(String source) =>
      ExpeditorPayment.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ExpeditorPayment(id: $id, colis: $colis, expeditorId: $expeditorId, expeditorName: $expeditorName, expeditorPhoneNumber: $expeditorPhoneNumber, deliveryId: $deliveryId, deliveryName: $deliveryName, price: $price, totalprice: $totalprice, deliveryPrice: $deliveryPrice, recived: $recived, region: $region)';
  }
}
