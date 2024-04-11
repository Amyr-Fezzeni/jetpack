// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';


class StatData {
  double data;
  int index;
  String date;
  StatData({required this.data, required this.index, required this.date});

  @override
  String toString() => 'StatData(data: $data, index: $index, date: $date)';
}

class AllPaimentData {
  final String type;
  final int money;
  AllPaimentData({
    required this.type,
    required this.money,
  });
}

class AllUserPaimentData {
  final String type;
  final int count;
  AllUserPaimentData({
    required this.type,
    required this.count,
  });
}

enum Period { day, month, year }

class PaymentModel {
  String title;
  Period period;
  List<FlSpot> data;
  PaymentModel({
    required this.title,
    this.period = Period.day,
    required this.data,
  });

  @override
  String toString() =>
      'PaymentModel(title: $title, period: $period, data: $data)';
}

class GlobalPayment {
  double id;
  String date;
  double amount;
  GlobalPayment({
    required this.id,
    required this.date,
    required this.amount,
  });

  @override
  String toString() => 'GlobalPayment(id: $id, date: $date, amount: $amount)';
}

class Payment {
  double amount;
  DateTime date;
  String status;
  String receipUrl;
  String email;
  String description;
  Payment({
    required this.amount,
    required this.date,
    required this.status,
    required this.receipUrl,
    required this.email,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'status': status,
      'receipUrl': receipUrl,
      'email': email,
      'description': description,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      amount: (map['amount'] ?? 0) / 100,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] * 1000),
      status: map['status'] as String,
      receipUrl: map['receipt_url'] ?? '',
      email: map['customer_email'] ?? '',
      description: map['description'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Payment.fromJson(String source) =>
      Payment.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Payment(amount: $amount, date: $date, status: $status, receipUrl: $receipUrl, email: $email, description: $description)';
  }
}
