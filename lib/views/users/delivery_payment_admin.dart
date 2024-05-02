import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jetpack/models/delivery_paiment.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/payment_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/views/widgets/appbar.dart';

class DeliveryPaymentAdmin extends StatefulWidget {
  final UserModel user;
  const DeliveryPaymentAdmin({super.key, required this.user});

  @override
  State<DeliveryPaymentAdmin> createState() => _DeliveryPaymentAdminState();
}

class _DeliveryPaymentAdminState extends State<DeliveryPaymentAdmin> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> function;

  @override
  void initState() {
    super.initState();
    function = PaymentService.deliveryPaimentCollection
        .where('userId', isEqualTo: widget.user.id)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Delivery Payment List'),
      backgroundColor: context.bgcolor,
      body: SizedBox(
        width: context.w,
        height: context.h,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Gap(10),
                StreamBuilder(
                    stream: function,
                    builder: (context, data) {
                      if (data.connectionState == ConnectionState.active &&
                          data.data != null) {
                        return Column(
                          children: data.data!.docs.reversed
                              .map((e) => DeliveryPayment.fromMap(e.data()))
                              .map((payment) => userPaymentCard(payment))
                              .toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget userPaymentCard(DeliveryPayment payment) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
          child: Card(
            elevation: 0,
            color: payment.isPaid
                ? Colors.green.withOpacity(.25)
                : Colors.red.withOpacity(.15),
            surfaceTintColor: payment.isPaid ? Colors.green : Colors.red,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (DateTime.now().isBefore(payment.endTime))
                            Txt("Current Week", bold: true),
                          Txt("From ${getSimpleDate(payment.startTime)} to ${getSimpleDate(payment.endTime)} ",
                              bold: true),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                  Txt("Colis delivered: ${payment.nbDelivered}"),
                  Txt("Manifest picked: ${payment.nbPickup}"),
                  Txt("${(payment.nbDelivered * widget.user.price + payment.nbPickup * 1).toStringAsFixed(2)} TND",
                      color: payment.isPaid ? Colors.green : Colors.red,
                      bold: true),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Builder(builder: (context) {
                        late final Color color;

                        switch (payment.isPaid) {
                          case true:
                            color = Colors.green;
                            break;
                          case false:
                            color = Colors.red;
                            break;
                          default:
                            color = context.theme.invertedColor;
                        }

                        return PopupMenuButton(
                          onSelected: (value) {},
                          color: context.bgcolor,
                          child: Container(
                              // width: 120,
                              height: 35,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: color.withOpacity(.2),
                                border: Border.all(color: color),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0) //
                                    ),
                              ),
                              child: Center(
                                child: Text(
                                  txt(payment.isPaid ? "Paid" : "Not paid"),
                                  style: context.text
                                      .copyWith(fontSize: 14, color: color),
                                ),
                              )),
                          itemBuilder: (BuildContext c) {
                            return [true, false].map((bool status) {
                              switch (status) {
                                case true:
                                  return PopupMenuItem(
                                    onTap: () async {
                                      if (payment.isPaid == status) return;
                                      await PaymentService
                                          .deliveryPaimentCollection
                                          .doc(payment.id)
                                          .update({'isPaid': status});
                                    },
                                    value: 'Paid',
                                    child: Row(
                                      // mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check,
                                            color: Colors.green, size: 25),
                                        const Gap(10),
                                        Text(
                                          txt("Paid"),
                                          style: context.theme.text18,
                                        ),
                                      ],
                                    ),
                                  );

                                default:
                                  return PopupMenuItem(
                                    onTap: () async {
                                      if (payment.isPaid == status) return;
                                      await PaymentService
                                          .deliveryPaimentCollection
                                          .doc(payment.id)
                                          .update({'isPaid': status});
                                    },
                                    value: 'Not paid',
                                    child: Row(
                                      // mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.close,
                                            color: Colors.red, size: 25),
                                        const Gap(10),
                                        Text(
                                          txt("Not paid"),
                                          style: context.theme.text18,
                                        ),
                                      ],
                                    ),
                                  );
                              }
                            }).toList();
                          },
                        );
                      }))
                ],
              ),
            ),
          ),
        ),
      );
}
