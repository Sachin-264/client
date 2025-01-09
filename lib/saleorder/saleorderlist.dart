import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'saleorderbloc.dart';

class SaleOrderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaleOrderBloc, SaleOrderState>(
      builder: (context, state) {
        if (state is SaleOrderLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is SaleOrderLoaded) {
          return ListView.builder(
            itemCount: state.saleOrders.length,
            itemBuilder: (context, index) {
              final saleOrder = state.saleOrders[index];
              return ListTile(
                title: Text(saleOrder['SaleOrderNo'] ?? 'No Order Number'),
                subtitle: Text(saleOrder['AccountName'] ?? 'No Customer Name'),
                trailing: Text(saleOrder['GrandTotal'] ?? 'No Total'),
              );
            },
          );
        } else if (state is SaleOrderError) {
          return Center(child: Text(state.errorMessage));
        }
        return Center(child: Text('No data available'));
      },
    );
  }
}