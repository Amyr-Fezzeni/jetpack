import 'dart:convert';
import 'dart:developer';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class DeliveryPayment {
  final String id;
  final String userId;
  bool isPaid;
  int nbDelivered;
  int nbPickup;
  DateTime startTime;
  DateTime endTime;
  DeliveryPayment({
    required this.id,
    required this.userId,
    required this.isPaid,
    required this.nbDelivered,
    required this.nbPickup,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'isPaid': isPaid,
      'nbDelivered': nbDelivered,
      'nbPickup': nbPickup,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
    };
  }

  factory DeliveryPayment.fromMap(Map<String, dynamic> map) {
    final p = DeliveryPayment(
      id: map['id'] as String,
      userId: map['userId'] as String,
      isPaid: map['isPaid'] as bool,
      nbDelivered: map['nbDelivered'] as int,
      nbPickup: map['nbPickup'] as int,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
    );
    log(p.toString());
    return p;
  }

  String toJson() => json.encode(toMap());

  factory DeliveryPayment.fromJson(String source) =>
      DeliveryPayment.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DeliveryPayment(id: $id, userId: $userId, isPaid: $isPaid, nbDelivered: $nbDelivered, nbPickup: $nbPickup, startTime: $startTime, endTime: $endTime)';
  }
}
