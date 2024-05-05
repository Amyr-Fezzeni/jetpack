import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Manifest {
  final String id;

  String phoneNumber;
  String expeditorId;
  String expeditorName;
  String fiscalMatricule;
  String governorate;
  String city;
  String region;
  String adress;

  DateTime dateCreated;
  DateTime? datePicked;
  List<String> colis;
  double totalPrice;
  Manifest({
    required this.id,
    required this.phoneNumber,
    required this.expeditorId,
    required this.expeditorName,
    required this.fiscalMatricule,
    required this.governorate,
    required this.city,
    required this.region,
    required this.adress,
    required this.dateCreated,
    this.datePicked,
    required this.colis,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNumber': phoneNumber,
      'expeditorId': expeditorId,
      'expeditorName': expeditorName,
      'fiscalMatricule': fiscalMatricule,
      'governorate': governorate,
      'city': city,
      'region': region,
      'adress': adress,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'datePicked': datePicked?.millisecondsSinceEpoch,
      'colis': colis,
      'totalPrice': totalPrice,
    };
  }

  factory Manifest.fromMap(Map<String, dynamic> map) {
    return Manifest(
      id: map['id'] as String,
      phoneNumber: map['phoneNumber'] as String,
      expeditorId: map['expeditorId'] as String,
      expeditorName: map['expeditorName'] as String,
      fiscalMatricule: map['fiscalMatricule'] as String,
      governorate: map['governorate'] as String,
      city: map['city'] as String,
      region: map['region'] as String,
      adress: map['adress'] as String,
      dateCreated:
          DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] as int),
      datePicked: map['datePicked'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['datePicked'] as int)
          : null,
      colis: List<String>.from((map['colis'] ?? [])),
      totalPrice: map['totalPrice'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory Manifest.fromJson(String source) =>
      Manifest.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Manifest(id: $id, phoneNumber: $phoneNumber, expeditorId: $expeditorId, expeditorName: $expeditorName, fiscalMatricule: $fiscalMatricule, governorate: $governorate, city: $city, region: $region, adress: $adress, dateCreated: $dateCreated, datePicked: $datePicked, colis: $colis, totalPrice: $totalPrice)';
  }
}
