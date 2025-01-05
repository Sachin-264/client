import 'package:client/saleorder/saleorderbloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'complaint_page.dart';
import 'invoice/invoice bloc.dart';


void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<InvoiceBloc>(create: (context) => InvoiceBloc()),
        BlocProvider<SaleOrderBloc>(create: (context) => SaleOrderBloc()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Complaint Entry App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ComplaintPage(),
    );
  }
}