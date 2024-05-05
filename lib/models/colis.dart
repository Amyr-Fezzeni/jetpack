// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

enum ColisStatus {
  inProgress,
  ready,
  pickup,
  depot,
  inDelivery,
  confirmed,
  delivered,
  appointment,
  canceled,
  returnDepot,
  returnConfirmed,
  returnExpeditor,
  closed,
  closedReturn
}

class Colis {
  String id; // Auto-incremented by the database, not needed in Dart class
  String clientId;
  String name;
  String governorate;
  String city;
  String region;
  String address;
  String phone1;
  String phone2;

  String agenceId;
  String agenceName;

  int numberOfItems;
  double price;
  bool isFragile;
  bool exchange;
  bool openable;
  String comment;
  String deliveryComment;
  DateTime creationDate;
  DateTime? pickupDate;
  DateTime? appointmentDate;
  DateTime? deliveryDate;
  String status; // In progress, at the depot, final return
  String expeditorId;
  String expeditorName;
  String expeditorPhone;
  String deliveryId;
  String deliveryName;
  String sectorId;
  String sectorName;
  int tentative;
  Colis(
      {required this.id,
      required this.clientId,
      required this.name,
      required this.governorate,
      required this.city,
      required this.region,
      required this.address,
      required this.phone1,
      required this.phone2,
      this.numberOfItems = 1,
      required this.expeditorName,
      required this.expeditorPhone,
      this.tentative = 1,
      this.price = 0,
      this.isFragile = true,
      this.exchange = false,
      required this.comment,
      this.deliveryComment = '',
      required this.creationDate,
      this.pickupDate,
      this.deliveryDate,
      required this.status,
      required this.expeditorId,
      required this.agenceId,
      required this.agenceName,
      this.deliveryId = '',
      this.deliveryName = '',
      this.sectorId = '',
      this.sectorName = '',
      this.appointmentDate,
      this.openable = true});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'clientId': clientId,
      'name': name,
      'governorate': governorate,
      'city': city,
      'region': region,
      'address': address,
      'phone1': phone1,
      'deliveryComment': deliveryComment,
      'phone2': phone2,
      'numberOfItems': numberOfItems,
      'expeditorPhone': expeditorPhone,
      'price': price,
      'isFragile': isFragile,
      'exchange': exchange,
      'comment': comment,
      'tentative': tentative,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'pickupDate': pickupDate?.millisecondsSinceEpoch,
      'deliveryDate': deliveryDate?.millisecondsSinceEpoch,
      'status': status,
      'expeditorId': expeditorId,
      'deliveryId': deliveryId,
      'deliveryName': deliveryName,
      'openable': openable,
      'sectorId': sectorId,
      'sectorName': sectorName,
      'expeditorName': expeditorName,
      'appointmentDate': appointmentDate?.millisecondsSinceEpoch,
      'agenceId': agenceId,
      'agenceName': agenceName
    };
  }

  factory Colis.fromMap(Map<String, dynamic> map) {
    return Colis(
        id: map['id'] as String,
        clientId: map['clientId'] as String,
        name: map['name'] as String,
        governorate: map['governorate'] as String,
        city: map['city'] as String,
        region: map['region'] ?? '',
        address: map['address'] as String,
        phone1: map['phone1'] as String,
        phone2: map['phone2'] as String,
        numberOfItems: map['numberOfItems'] as int,
        price: map['price'] as double,
        isFragile: map['isFragile'] as bool,
        openable: map['openable'] ?? false,
        exchange: map['exchange'] as bool,
        comment: map['comment'] as String,
        expeditorPhone: map['expeditorPhone'] ?? '',
        deliveryComment: map['deliveryComment'] ?? '',
        tentative: map['tentative'] ?? 1,
        sectorId: map['sectorId'] ?? '',
        sectorName: map['sectorName'] ?? '',
        creationDate:
            DateTime.fromMillisecondsSinceEpoch(map['creationDate'] as int),
        appointmentDate: map['appointmentDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['appointmentDate'] as int)
            : null,
        pickupDate: map['pickupDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['pickupDate'] as int)
            : null,
        deliveryDate: map['deliveryDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['deliveryDate'] as int)
            : null,
        status: map['status'] as String,
        expeditorId: map['expeditorId'] as String,
        expeditorName: map['expeditorName'] ?? '',
        deliveryId: map['deliveryId'] as String,
        deliveryName: map['deliveryName'] as String,
        agenceId: map['agenceId'] ?? '',
        agenceName: map['agenceName'] ?? '');
  }

  String toJson() => json.encode(toMap());

  factory Colis.fromJson(String source) =>
      Colis.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Colis(id: $id, clientId: $clientId, name: $name, governorate: $governorate, city: $city, address: $address, phone1: $phone1, phone2: $phone2, numberOfItems: $numberOfItems, price: $price, isFragile: $isFragile, exchange: $exchange, openable: $openable, comment: $comment, creationDate: $creationDate, pickupDate: $pickupDate, deliveryDate: $deliveryDate, expeditorId: $expeditorId, deliveryId: $deliveryId, deliveryName: $deliveryName)';
  }
}

getColor(String status) {
  switch (status) {
    case "confirmed":
      return Colors.blue;

    case "delivered":
      return Colors.green;

    case "returnDepot":
      return Colors.orange;

    case "canceled":
      return Colors.red;

    case "appointment":
      return Colors.orange;

    default:
      return Colors.grey;
  }
}

getText(String status) {
  log(ColisStatus.values.toString());

  switch (status) {
    case "confirmed":
      return 'Client confirmed';
    case "delivered":
      return 'Colis delivered';
    case "returnDepot":
      return 'Client not availble';
    case "canceled":
      return 'Colis canceled';
    case "appointment":
      return 'Appointment';
    case "depot":
      return 'At depot';
    case "returnExpeditor":
      return 'Retour expeditor';
    case "inProgress":
      return 'in progress';
    case "ready":
      return 'ready for pickup';
    case "pickup":
      return 'pickup';
    case "closedReturn":
      return 'Annuler';

    case "returnConfirmed":
      return 'Confirmed return';
    case "closed":
      return 'closed';

    default:
      return 'In delivery';
  }
}
// ColisStatus.inProgress, 
// ColisStatus.ready, 
// ColisStatus.pickup, 
// ColisStatus.depot,
//  ColisStatus.inDelivery, 
//  ColisStatus.confirmed, 
//  ColisStatus.delivered, 
//  ColisStatus.appointment, 
//  ColisStatus.canceled, 
//  ColisStatus.returnDepot, 
//  ColisStatus.returnExpeditor, 
//  ColisStatus.closed, 
//  ColisStatus.closedReturn