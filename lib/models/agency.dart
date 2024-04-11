import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Agency {
  final String id;
  String name;
  String adress;
  String agencyLead;
  int employeesNumber;
  List<String> deliveryMen;
  Agency({
    required this.id,
    required this.name,
    required this.adress,
    required this.agencyLead,
    required this.employeesNumber,
    required this.deliveryMen,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'adress': adress,
      'agencyLead': agencyLead,
      'employeesNumber': employeesNumber,
      'deliveryMen': deliveryMen,
    };
  }

  factory Agency.fromMap(Map<String, dynamic> map) {
    return Agency(
      id: map['id'] as String,
      name: map['name'] as String,
      adress: map['adress'] as String,
      agencyLead: map['agencyLead'] as String,
      employeesNumber: map['employeesNumber'] as int,
      deliveryMen: List<String>.from((map['deliveryMen'] ??[])),
    );
  }

  String toJson() => json.encode(toMap());

  factory Agency.fromJson(String source) => Agency.fromMap(json.decode(source) as Map<String, dynamic>);
}
