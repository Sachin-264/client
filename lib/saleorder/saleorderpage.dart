import 'package:client/saleorder/saleorderbloc.dart';
import 'package:client/saleorder/saleorderlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaleOrderPage extends StatefulWidget {
  const SaleOrderPage({Key? key}) : super(key: key);

  @override
  State<SaleOrderPage> createState() => _SaleOrderPageState();
}

class _SaleOrderPageState extends State<SaleOrderPage> {
  @override
  void initState() {
    super.initState();
    context.read<SaleOrderBloc>().add(FetchSaleOrderEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sale Orders',
          style: TextStyle(
            color: Colors.white, // White color for text

          ),),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Remove default back button
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Navigate back
            },
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.white), // Blue back icon
                SizedBox(width: 4), // Add spacing between icon and text
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white, // Blue color for text
                    fontSize: 16, // Adjust font size
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SaleOrderList(),
    );
  }
}