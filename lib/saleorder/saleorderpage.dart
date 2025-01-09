import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'saleorderbloc.dart';
import 'saleorderlist.dart';

class SaleOrderPage extends StatefulWidget {
  final Map<String, String> filters;
  const SaleOrderPage({Key? key, required this.filters}) : super(key: key);

  @override
  State<SaleOrderPage> createState() => _SaleOrderPageState();
}

class _SaleOrderPageState extends State<SaleOrderPage> {
  late SaleOrderBloc _saleOrderBloc;

  @override
  void initState() {
    super.initState();
    _saleOrderBloc = SaleOrderBloc();
    _saleOrderBloc.add(FetchSaleOrderEvent(filters: widget.filters));
  }

  @override
  void dispose() {
    _saleOrderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _saleOrderBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sale Orders',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: false, // Remove default back button
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back
              },
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Back',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SaleOrderList(),
      ),
    );
  }
}