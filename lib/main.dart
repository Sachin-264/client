import 'package:client/saleorder/saleorderbloc.dart';
import 'package:client/saleorder/saleorderdraft_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'TargetDashboard/accessories_bloc.dart';
import 'TargetDashboard/targetDashboardBloc.dart';
import 'complaint_page.dart';
import 'invoice/invoice bloc.dart';
import 'itemmanagement/itembloc.dart';


void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<InvoiceBloc>(create: (context) => InvoiceBloc()),
        BlocProvider<SaleOrderDraftBloc>(create: (context) => SaleOrderDraftBloc()),
        BlocProvider<TargetDashboardBloc>(create: (context) => TargetDashboardBloc()),
        BlocProvider<SaleOrderBloc>(create: (context) => SaleOrderBloc()),
        BlocProvider<ItemManagementBloc>(create: (context) => ItemManagementBloc()),  // ItemBloc is provided here
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