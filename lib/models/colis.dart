import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Colis {
  int id; // Auto-incremented by the database, not needed in Dart class
  String name;
  String governorate;
  String city;
  String address;
  String phone1;
  String? phone2; // Optional
  String designation; // Default delivery, pickup, exchange
  int numberOfItems;
  double price;
  bool isFragile;
  bool exchange;
  String comment;
  DateTime creationDate;
  DateTime pickupDate;
  DateTime deliveryDate;
  String status; // In progress, at the depot, final return
  String deliveryResponsible;
  String deliveryNumber;
  Colis({
    required this.id,
    required this.name,
    required this.governorate,
    required this.city,
    required this.address,
    required this.phone1,
    this.phone2,
    required this.designation,
    required this.numberOfItems,
    required this.price,
    required this.isFragile,
    required this.exchange,
    required this.comment,
    required this.creationDate,
    required this.pickupDate,
    required this.deliveryDate,
    required this.status,
    required this.deliveryResponsible,
    required this.deliveryNumber,
  });


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'governorate': governorate,
      'city': city,
      'address': address,
      'phone1': phone1,
      'phone2': phone2,
      'designation': designation,
      'numberOfItems': numberOfItems,
      'price': price,
      'isFragile': isFragile,
      'exchange': exchange,
      'comment': comment,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'pickupDate': pickupDate.millisecondsSinceEpoch,
      'deliveryDate': deliveryDate.millisecondsSinceEpoch,
      'status': status,
      'deliveryResponsible': deliveryResponsible,
      'deliveryNumber': deliveryNumber,
    };
  }

  factory Colis.fromMap(Map<String, dynamic> map) {
    return Colis(
      id: map['id'] as int,
      name: map['name'] as String,
      governorate: map['governorate'] as String,
      city: map['city'] as String,
      address: map['address'] as String,
      phone1: map['phone1'] as String,
      phone2: map['phone2'] != null ? map['phone2'] as String : null,
      designation: map['designation'] as String,
      numberOfItems: map['numberOfItems'] as int,
      price: map['price'] as double,
      isFragile: map['isFragile'] as bool,
      exchange: map['exchange'] as bool,
      comment: map['comment'] as String,
      creationDate: DateTime.fromMillisecondsSinceEpoch(map['creationDate'] as int),
      pickupDate: DateTime.fromMillisecondsSinceEpoch(map['pickupDate'] as int),
      deliveryDate: DateTime.fromMillisecondsSinceEpoch(map['deliveryDate'] as int),
      status: map['status'] as String,
      deliveryResponsible: map['deliveryResponsible'] as String,
      deliveryNumber: map['deliveryNumber'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Colis.fromJson(String source) => Colis.fromMap(json.decode(source) as Map<String, dynamic>);
}
