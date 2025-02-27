import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:excel/excel.dart'; // For Excel export
import 'package:pdf/pdf.dart'; // For PDF export
import 'package:pdf/widgets.dart' as pw; // For PDF export
import 'package:universal_html/html.dart'
    as html; // For file downloads in the browser
import 'sale_status_bloc.dart';
import 'sale_status_list.dart';
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart';

class SaleOrderPage extends StatefulWidget {

  final Map<String, String> filters;
  const SaleOrderPage({super.key, required this.filters});

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
            'Sale Order Status Report',
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
        body: Column(
          children: [
            // Export Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _exportToExcel(context); // Export to Excel
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Green background
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Export to Excel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 20), // Add spacing between buttons
                  ElevatedButton(
                    onPressed: () {
                      _exportToPDF(context); // Export to PDF
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red background
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Export to PDF',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SaleOrderList(), // Your existing SaleOrderList widget
            ),
          ],
        ),
      ),
    );
  }


// Export to Excel for Sale Order List


  Future<void> _exportToExcel(BuildContext context) async {
    try {
      final state = _saleOrderBloc.state;
      if (state is SaleOrderLoaded) {
        final saleOrders = state.saleOrders;

        var excel = Excel.createExcel();
        excel.delete('SaleOrderStatus'); // Remove default sheet
        var sheet = excel['SaleOrderStatus'];

        // Add headers for all columns
        sheet.appendRow([
          'ORDER NO',
          'ORDER DATE',
          'SALES MANAGER',
          'SALES MAN NAME',
          'ORDER STATUS',
          'CUSTOMER',
          'CUSTOMER PO NO',
          'CUSTOMER PO DATE',
          'DEL DATE',
          'LD',
          'LD%',
          'ITEM NAME',
          'QTY',
          'VALUE',
          'SALES ORDER VALUE',
          'DISPATCH VALUE',
          'BALANCE',
          'EVA',
          'ESM',
          'AVA',
          'ASM',
          'AVA-EVA',
          'ASM-ESM',
          'QUOTATION',
          'INQ NO',
        ].map((header) => TextCellValue(header)).toList());

        // Add data rows
        for (var order in saleOrders) {
          final balance = order.grandTotal - order.dispatchValue;
          final qty = double.tryParse(order.qty) ?? 0.0; // Parse Qty
          sheet.appendRow([
            TextCellValue(order.orderNo),
            TextCellValue(order.orderDate),
            TextCellValue(order.saleManager),
            TextCellValue(order.salesManName),
            TextCellValue(order.resultStatus),
            TextCellValue(order.accountName),
            TextCellValue(order.customerPONo),
            TextCellValue(order.customerPODate),
            TextCellValue(order.deliveryDate),
            TextCellValue(order.ldyn),
            TextCellValue(order.ldPer),
            TextCellValue(order.itemName),
            DoubleCellValue(qty), // Use parsed Qty
            DoubleCellValue(order.value),
            DoubleCellValue(order.grandTotal),
            DoubleCellValue(order.dispatchValue),
            DoubleCellValue(balance),
            TextCellValue(order.eva),
            TextCellValue(order.esm),
            TextCellValue(order.ava),
            TextCellValue(order.asm),
            TextCellValue(''), // AVA-EVA (placeholder)
            TextCellValue(''), // ASM-ESM (placeholder)
            TextCellValue(order.quotationNo),
            TextCellValue(order.inquiryNo),
          ]);
        }

        // Save and download
        var fileBytes = excel.save();
        if (fileBytes != null) {
          final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute('download', 'sale_orders_report.xlsx')
            ..click();
          html.Url.revokeObjectUrl(url);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported to Excel successfully!')),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Excel Export Error: $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export: ${e.toString()}')),
      );
    }
  }

// Export to PDF

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      final state = _saleOrderBloc.state;
      if (state is SaleOrderLoaded) {
        final saleOrders = state.saleOrders;
        final pdf = pw.Document();

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Table.fromTextArray(
                headers: [
                  'ORDER NO',
                  'ORDER DATE',
                  'SALES MANAGER',
                  'SALES MAN NAME',
                  'ORDER STATUS',
                  'CUSTOMER',
                  'CUSTOMER PO NO',
                  'CUSTOMER PO DATE',
                  'DEL DATE',
                  'LD',
                  'LD%',
                  'ITEM NAME',
                  'QTY',
                  'VALUE',
                  'SALES ORDER VALUE',
                  'DISPATCH VALUE',
                  'BALANCE',
                  'EVA',
                  'ESM',
                  'AVA',
                  'ASM',
                  'AVA-EVA',
                  'ASM-ESM',
                  'QUOTATION',
                  'INQ NO',
                ],
                data: saleOrders.map((order) {
                  final balance = order.grandTotal - order.dispatchValue;
                  final qty = double.tryParse(order.qty) ?? 0.0; // Parse Qty
                  return [
                    order.orderNo,
                    order.orderDate,
                    order.saleManager,
                    order.salesManName,
                    order.resultStatus,
                    order.accountName,
                    order.customerPONo,
                    order.customerPODate,
                    order.deliveryDate,
                    order.ldyn,
                    order.ldPer,
                    order.itemName,
                    qty.toString(), // Use parsed Qty
                    order.value.toStringAsFixed(2),
                    order.grandTotal.toStringAsFixed(2),
                    order.dispatchValue.toStringAsFixed(2),
                    balance.toStringAsFixed(2),
                    order.eva,
                    order.esm,
                    order.ava,
                    order.asm,
                    '', // AVA-EVA
                    '', // ASM-ESM
                    order.quotationNo,
                    order.inquiryNo,
                  ];
                }).toList(),
              );
            },
          ),
        );

        final pdfBytes = await pdf.save();
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'SaleOrderStatus')
          ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to PDF successfully!')),
        );
      }
    } catch (e, stackTrace) {
      print('PDF Export Error: $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export: ${e.toString()}')),
      );
    }
  }
}
