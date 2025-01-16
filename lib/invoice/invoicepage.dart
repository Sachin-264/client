import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'invoice bloc.dart';
import 'invoicelist.dart';

class InvoicePage extends StatefulWidget {
  final Map<String, String> filters;

  InvoicePage({Key? key, required this.filters}) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  @override
  void initState() {
    super.initState();
    context.read<InvoiceBloc>().add(FetchInvoiceEvent(filters: widget.filters));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perform Invoice List',
          style: TextStyle(
            color: Colors.white, // White color for text
          ),
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
                Icon(Icons.arrow_back_ios, color: Colors.white), // Back icon
                SizedBox(width: 4), // Add spacing between icon and text
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white, // White color for text
                    fontSize: 16, // Adjust font size
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: InvoiceList(),
    );
  }
}
