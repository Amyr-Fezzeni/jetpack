// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:jetpack/models/colis.dart';

class ReturnColis {
  String id;
  String agencyName;
  String agencyId;
  String governorate;
  String city;
  String region;
  String address;
  String expeditorName;
  String expeditorId;
  String expeditorPhoneNumber;
  List<Colis> colis;
  DateTime date;
  bool isClosed;
  ReturnColis({
    required this.id,
    required this.agencyName,
    required this.agencyId,
    required this.governorate,
    required this.city,
    required this.region,
    required this.address,
    required this.expeditorName,
    required this.expeditorId,
    required this.expeditorPhoneNumber,
    required this.colis,
    required this.date,
    required this.isClosed,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'agencyName': agencyName,
      'agencyId': agencyId,
      'governorate': governorate,
      'city': city,
      'region': region,
      'address': address,
      'expeditorName': expeditorName,
      'expeditorId': expeditorId,
      'expeditorPhoneNumber': expeditorPhoneNumber,
      'colis': colis.map((x) => x.toMap()).toList(),
      'date': date.millisecondsSinceEpoch,
      'isClosed': isClosed,
    };
  }

  factory ReturnColis.fromMap(Map<String, dynamic> map) {
    return ReturnColis(
      id: map['id'] as String,
      agencyName: map['agencyName'] as String,
      agencyId: map['agencyId'] as String,
      governorate: map['governorate'] as String,
      city: map['city'] as String,
      region: map['region'] as String,
      address: map['address'] as String,
      expeditorName: map['expeditorName'] as String,
      expeditorId: map['expeditorId'] as String,
      expeditorPhoneNumber: map['expeditorPhoneNumber'] as String,
      colis: List<Colis>.from(
        (map['colis'] ?? []).map<Colis>(
          (x) => Colis.fromMap(x as Map<String, dynamic>),
        ),
      ),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      isClosed: map['isClosed'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReturnColis.fromJson(String source) =>
      ReturnColis.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ReturnColis(id: $id, agencyName: $agencyName, agencyId: $agencyId, governorate: $governorate, city: $city, region: $region, address: $address, expeditorName: $expeditorName, expeditorId: $expeditorId, expeditorPhoneNumber: $expeditorPhoneNumber, colis: $colis, date: $date, isClosed: $isClosed)';
  }
}
