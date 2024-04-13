import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Client {
  final String id;
  String firstName;
  String lastName;
  String phoneNumber;
  String secondaryPhoneNumber;
  String governorate;
  String city;
  String adress;
  Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.secondaryPhoneNumber,
    required this.governorate,
    required this.city,
    required this.adress,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'secondaryPhoneNumber': secondaryPhoneNumber,
      'state': governorate,
      'city': city,
      'adress': adress,
      'governorate': governorate
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      secondaryPhoneNumber: map['secondaryPhoneNumber'] as String,
      governorate: map['governorate'] as String,
      city: map['city'] as String,
      adress: map['adress'] as String,
    );
  }

  String toJson() => json.encode(toMap());
  String getFullName() => "$firstName $lastName";
  factory Client.fromJson(String source) =>
      Client.fromMap(json.decode(source) as Map<String, dynamic>);
}
