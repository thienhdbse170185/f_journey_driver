import 'package:f_journey_driver/core/utils/price_util.dart';
import 'package:f_journey_driver/model/dto/payment_dto.dart';
import 'package:f_journey_driver/viewmodel/transaction/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentHistoryWidget extends StatefulWidget {
  const PaymentHistoryWidget({super.key});

  @override
  State<PaymentHistoryWidget> createState() => _PaymentHistoryWidgetState();
}

class _PaymentHistoryWidgetState extends State<PaymentHistoryWidget> {
  List<PaymentDto> payments = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<TransactionCubit>().getTransactionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is GetAllTransactionSuccess) {
          setState(() {
            payments = state.payments;
          });
        } else if (state is GetAllTransactionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
            ),
          );
        } else if (state is TransactionLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loading...'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử thanh toán'),
        ),
        body: ListView.builder(
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            return ListTile(
              leading: Icon(
                payment.type == 'TripEarnings'
                    ? Icons.add_circle
                    : Icons.remove_circle,
                color:
                    payment.type == 'TripEarnings' ? Colors.green : Colors.red,
              ),
              title: Text(PriceUtil.formatPrice(payment.amount)),
              subtitle: Text('Date: ${payment.transactionDate}'),
              trailing: Text(payment.type),
            );
          },
        ),
      ),
    );
  }
}
