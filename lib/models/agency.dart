import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Agency {
  final String id;
  String name;
  String adress;
  String governorate;
  List<String> citys;
  String agencyLead;
  String adminId;
  int employeesNumber;
  List<String> deliveryMen;
  Agency(
      {required this.id,
      required this.name,
      required this.adress,
      required this.governorate,
      required this.citys,
      required this.agencyLead,
      required this.employeesNumber,
      required this.deliveryMen,
      required this.adminId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'adress': adress,
      'governorate': governorate,
      'citys': citys,
      'agencyLead': agencyLead,
      'employeesNumber': employeesNumber,
      'deliveryMen': deliveryMen,
      'adminId': adminId
    };
  }

  factory Agency.fromMap(Map<String, dynamic> map) {
    return Agency(
        id: map['id'] as String,
        name: map['name'] as String,
        adress: map['adress'] as String,
        governorate: map['governorate'] ?? '',
        citys: List<String>.from(map['citys'] ?? []),
        agencyLead: map['agencyLead'] as String,
        employeesNumber: map['employeesNumber'] as int,
        deliveryMen: List<String>.from(map['deliveryMen'] ?? []),
        adminId: map['adminId'] ?? '');
  }

  String toJson() => json.encode(toMap());

  factory Agency.fromJson(String source) =>
      Agency.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Agency(id: $id, name: $name, adress: $adress, governorate: $governorate, citys: $citys, agencyLead: $agencyLead, adminId: $adminId, employeesNumber: $employeesNumber, deliveryMen: $deliveryMen)';
  }
}
