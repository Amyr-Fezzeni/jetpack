import 'package:flutter/material.dart';
import 'package:jetpack/views/profile/payment_history.dart';
import 'package:jetpack/views/widgets/appbar.dart';

class DeliveryPaymentHistoryScreen extends StatefulWidget {
  const DeliveryPaymentHistoryScreen({super.key});

  @override
  State<DeliveryPaymentHistoryScreen> createState() =>
      _DeliveryPaymentHistoryScreenState();
}

class _DeliveryPaymentHistoryScreenState
    extends State<DeliveryPaymentHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Payment history'),
      body: const SingleChildScrollView(
        child: PaymentHistoryWidget(),
      ),
    );
  }
}
