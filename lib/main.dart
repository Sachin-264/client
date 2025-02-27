import 'package:client/sale_status_Report/sale_status_bloc.dart';
import 'package:client/sale_status_Report/sale_status_draft_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import Bloc Files
import 'package:client/invoice/invoice%20bloc.dart';
import 'package:client/PPS%20report/PPSreportbloc.dart';
import 'package:client/PPS%20report/ppsdraftbloc.dart';
import 'package:client/QualtyChecks/qualityFilterbloc.dart';
import 'package:client/Search_box/filter_bloc.dart';
import 'package:client/TargetDashboard/selectpage_bloc.dart';
import 'package:client/invoice/invoice_draft_bloc.dart';
import 'package:client/itemmanagement/itemrealbloc.dart';

import 'package:client/TargetDashboard/accessories_bloc.dart';
import 'package:client/TargetDashboard/targetDashboardBloc.dart'; // ✅ Fixed import
import 'package:client/itemmanagement/itembloc.dart';

// Import Pages
import 'complaint_page.dart';

String companyCode = '101';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<InvoiceDraftPageBloc>(
            create: (context) => InvoiceDraftPageBloc()),
        BlocProvider<InvoiceBloc>(create: (context) => InvoiceBloc()),
        BlocProvider<SaleOrderDraftBloc>(
            create: (context) => SaleOrderDraftBloc()),
        BlocProvider<TargetDashboardBloc>(
            create: (context) => TargetDashboardBloc()),
        BlocProvider<SaleOrderBloc>(create: (context) => SaleOrderBloc()),
        BlocProvider<ItemDraftPageBloc>(
            create: (context) => ItemDraftPageBloc()),
        BlocProvider<PPSDraftPageBloc>(create: (context) => PPSDraftPageBloc()),
        BlocProvider<PpsReportBloc>(create: (context) => PpsReportBloc()),
        BlocProvider<SelectPageBloc>(create: (context) => SelectPageBloc()),
        BlocProvider<UserGroupBloc>(
            create: (context) => UserGroupBloc(companyCode)),
        BlocProvider<BranchBloc>(create: (context) => BranchBloc()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
