// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jetpack/models/enum_classes.dart';
import 'package:jetpack/services/util/logic_service.dart';

class UserModel {
  final String id;
  String firstName;
  String lastName;
  String cin;
  String phoneNumber;
  Map<String, dynamic>? agency;
  Map<String, dynamic> sector;
  double price;
  String matricule;
  DateTime? birthday;
  String governorate;
  String city;
  String region;
  // exrat
  String photo;
  String email;
  String password;
  Gender gender;
  String adress;
  DateTime dateCreated;
  UserStatus status;
  bool notificationStatus;
  String? fcm;
  Role role;
  // expeditor
  String secondaryphoneNumber;
  String fiscalMatricule;
  double returnPrice;
  //
  GeoPoint? location;
  DateTime? lastUpdateLocation;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.cin,
    this.phoneNumber = '',
    this.agency,
    required this.sector,
    this.price = 0,
    this.matricule = '',
    this.birthday,
    this.photo = '',
    this.location,
    this.lastUpdateLocation,
    required this.email,
    required this.password,
    required this.gender,
    this.adress = '',
    required this.dateCreated,
    this.status = UserStatus.active,
    this.notificationStatus = true,
    this.fcm,
    required this.role,
    this.governorate = '',
    this.city = '',
    this.region = '',
    this.secondaryphoneNumber = '',
    this.fiscalMatricule = '',
    this.returnPrice = 0,
  });

  String getFullName() =>
      "${firstName.isEmpty ? '' : capitalize(firstName)} ${lastName.isEmpty ? '' : capitalize(lastName)}";

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'cin': cin,
      'phoneNumber': phoneNumber,
      'agency': agency,
      'sector': sector,
      'price': price,
      'matricule': matricule,
      'birthday': birthday?.millisecondsSinceEpoch,
      'photo': photo,
      'email': email,
      'password': password,
      'gender': gender.name,
      'adress': adress,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'status': status.name,
      'notificationStatus': notificationStatus,
      'fcm': fcm,
      'role': role.name,
      'governorate': governorate,
      'city': city,
      'region': region,
      'secondaryphoneNumber': secondaryphoneNumber,
      'fiscalMatricule': fiscalMatricule,
      'returnPrice': returnPrice,
      'location': location,
      'lastUpdateLocation': lastUpdateLocation?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // GeoPoint? gPoint = map['location'];
    return UserModel(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      cin: map['cin'] as String,
      phoneNumber: map['phoneNumber'] as String,
      agency: map['agency'],
      sector: map['sector'] is Map<String, dynamic>
          ? map['sector']
          : {"id": '', "name": ""},
      price: map['price'] as double,
      governorate: map['governorate'] ?? '',
      city: map['city'] ?? '',
      region: map['region'] ?? '',
      matricule: map['matricule'] as String,
      birthday: DateTime.fromMillisecondsSinceEpoch(map['birthday'] as int),
      photo: map['photo'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      gender: getUserGenderFromString(map['gender']),
      adress: map['adress'] as String,
      dateCreated:
          DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] as int),
      status: getUserStatusFromString(map['status']),
      notificationStatus: map['notificationStatus'] as bool,
      fcm: map['fcm'] != null ? map['fcm'] as String : null,
      role: getUserRoleFromString(map['role']),
      secondaryphoneNumber: map['secondaryphoneNumber'] as String,
      fiscalMatricule: map['fiscalMatricule'] as String,
      returnPrice: map['returnPrice'] as double,
      location:map['location'],
      lastUpdateLocation: map['lastUpdateLocation'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['lastUpdateLocation'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
