import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Sector {
  final String id;
  String name;
  String city;
  List<String> regions;
  Map<String, dynamic> delivery;
  Sector({
    required this.id,
    required this.name,
    required this.city,
    required this.regions,
    required this.delivery,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'city': city,
      'regions': regions,
      'delivery': delivery,
    };
  }

  factory Sector.fromMap(Map<String, dynamic> map) {
    return Sector(
      id: map['id'] as String,
      name: map['name'] as String,
      city: map['city'] ?? '',
      regions: List<String>.from((map['regions'] ?? [])),
      delivery:
          Map<String, dynamic>.from((map['delivery'] as Map<String, dynamic>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory Sector.fromJson(String source) =>
      Sector.fromMap(json.decode(source) as Map<String, dynamic>);
}
