// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum ColisStatus {
  inProgress,
  depot,
  delivery,
  confirmed,
  firstAttempt,
  secondAttempt,
  canceled,
  clientCanceled
}

class Colis {
  String id; // Auto-incremented by the database, not needed in Dart class
  String clientId;
  String name;
  String governorate;
  String city;
  String address;
  String phone1;
  String phone2; // Optional
  //String designation; // Default delivery, pickup, exchange
  int numberOfItems;
  double price;
  bool isFragile;
  bool exchange;
  String comment;
  DateTime? creationDate;
  DateTime? pickupDate;
  DateTime? deliveryDate;
  String status; // In progress, at the depot, final return
  String expeditorId;
  String deliveryId;
  String deliveryName;
  Colis({
    required this.id,
    required this.clientId,
    required this.name,
    required this.governorate,
    required this.city,
    required this.address,
    required this.phone1,
    required this.phone2,
    required this.numberOfItems,
    required this.price,
    required this.isFragile,
    required this.exchange,
    required this.comment,
    this.creationDate,
    this.pickupDate,
    this.deliveryDate,
    required this.status,
    required this.expeditorId,
    required this.deliveryId,
    required this.deliveryName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'clientId': clientId,
      'name': name,
      'governorate': governorate,
      'city': city,
      'address': address,
      'phone1': phone1,
      'phone2': phone2,
      'numberOfItems': numberOfItems,
      'price': price,
      'isFragile': isFragile,
      'exchange': exchange,
      'comment': comment,
      'creationDate': creationDate?.millisecondsSinceEpoch,
      'pickupDate': pickupDate?.millisecondsSinceEpoch,
      'deliveryDate': deliveryDate?.millisecondsSinceEpoch,
      'status': status,
      'expeditorId': expeditorId,
      'deliveryId': deliveryId,
      'deliveryName': deliveryName,
    };
  }

  factory Colis.fromMap(Map<String, dynamic> map) {
    return Colis(
      id: map['id'] as String,
      clientId: map['clientId'] as String,
      name: map['name'] as String,
      governorate: map['governorate'] as String,
      city: map['city'] as String,
      address: map['address'] as String,
      phone1: map['phone1'] as String,
      phone2: map['phone2'] as String,
      numberOfItems: map['numberOfItems'] as int,
      price: map['price'] as double,
      isFragile: map['isFragile'] as bool,
      exchange: map['exchange'] as bool,
      comment: map['comment'] as String,
      creationDate: map['creationDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['creationDate'] as int) : null,
      pickupDate: map['pickupDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['pickupDate'] as int) : null,
      deliveryDate: map['deliveryDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['deliveryDate'] as int) : null,
      status: map['status'] as String,
      expeditorId: map['expeditorId'] as String,
      deliveryId: map['deliveryId'] as String,
      deliveryName: map['deliveryName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Colis.fromJson(String source) =>
      Colis.fromMap(json.decode(source) as Map<String, dynamic>);
}
