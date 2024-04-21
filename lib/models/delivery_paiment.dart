import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class DeliveryPayment {
  final String id;
  int nbDelivered;
  int nbPickup;
  DateTime startTime;
  DateTime endTime;
  DeliveryPayment({
    required this.id,
    required this.nbDelivered,
    required this.nbPickup,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nbDelivered': nbDelivered,
      'nbPickup': nbPickup,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
    };
  }

  factory DeliveryPayment.fromMap(Map<String, dynamic> map) {
    return DeliveryPayment(
      id: map['id'] as String,
      nbDelivered: map['nbDelivered'] as int,
      nbPickup: map['nbPickup'] as int,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory DeliveryPayment.fromJson(String source) => DeliveryPayment.fromMap(json.decode(source) as Map<String, dynamic>);
}
