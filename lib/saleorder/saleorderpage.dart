import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:excel/excel.dart'; // For Excel export
import 'package:pdf/pdf.dart'; // For PDF export
import 'package:pdf/widgets.dart' as pw; // For PDF export
import 'package:universal_html/html.dart'
    as html; // For file downloads in the browser
import 'saleorderbloc.dart';
import 'saleorderlist.dart';
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

  // Export to Excel
  // Export to Excel
// Export to Excel
  // Export to Excel
// Export to Excel
// For file storage

// Export to Excel for Sale Order List
  Future<void> _exportToExcel(BuildContext context) async {
    try {
      // Fetch data from the Bloc
      final state = _saleOrderBloc.state;
      if (state is SaleOrderLoaded) {
        final saleOrders = state.saleOrders;

        // Create an Excel file
        var excel = Excel.createExcel();

        // Remove the default "flutter" sheet
        excel.delete('flutter');

        // Create a new sheet
        var sheet = excel['Sheet1'];

        // Add headers (same as PlutoGrid columns)
        sheet.appendRow([
          TextCellValue('Sale Order Date'),
          TextCellValue('Sale Order No'),
          TextCellValue('Party Name'),
          TextCellValue('Value'),
          TextCellValue('Salesman'),
          TextCellValue('Created By'),
          TextCellValue('Created On'),
        ]);

        // Add data rows
        for (var order in saleOrders) {
          sheet.appendRow([
            TextCellValue(order['PostingDate'] ?? 'N/A'), // Sale Order Date
            TextCellValue(order['SaleOrderNo'] ?? 'N/A'), // Sale Order No
            TextCellValue(order['AccountName'] ?? 'N/A'), // Party Name
            TextCellValue(order['GrandTotal'] ?? 'N/A'), // Value
            TextCellValue(order['SalesManName'] ?? 'N/A'), // Salesman
            TextCellValue(order['CreatedBy'] ?? 'N/A'), // Created By
            TextCellValue(order['AddDate'] ?? 'N/A'), // Created On
          ]);
        }

        // Save the Excel file to bytes
        var fileBytes = excel.save();
        if (fileBytes != null) {
          // Get the application documents directory
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/sale_orders.xlsx');

          // Write the Excel file to the device's storage
          await file.writeAsBytes(fileBytes);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported to Excel successfully!')),
          );

          // Optional: Print the file path for debugging
          print('Excel file saved at: ${file.path}');
        }
      }
    } catch (e, stackTrace) {
      // Log the error and stack trace
      print('Error occurred during Excel export: $e');
      print('Stack trace: $stackTrace');

      // Show error message
    }
  }

// Export to PDF
  Future<void> _exportToPDF(BuildContext context) async {
    try {
      // Fetch data from the Bloc
      final state = _saleOrderBloc.state;
      if (state is SaleOrderLoaded) {
        final saleOrders = state.saleOrders;

        // Create a PDF document
        final pdf = pw.Document();

        // Add a page to the PDF
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Table.fromTextArray(
                headers: [
                  'Sale Order Date',
                  'Sale Order No',
                  'Party Name',
                  'Value',
                  'Salesman',
                  'Created By',
                  'Created On',
                ],
                data: saleOrders
                    .map((order) => [
                          order['PostingDate'] ?? 'N/A', // Sale Order Date
                          order['SaleOrderNo'] ?? 'N/A', // Sale Order No
                          order['AccountName'] ?? 'N/A', // Party Name
                          order['GrandTotal'] ?? 'N/A', // Value
                          order['SalesManName'] ?? 'N/A', // Salesman
                          order['CreatedBy'] ?? 'N/A', // Created By
                          order['AddDate'] ?? 'N/A', // Created On
                        ])
                    .toList(),
              );
            },
          ),
        );

        // Save the PDF to bytes
        final pdfBytes = await pdf.save();

        // Create a Blob from the PDF bytes
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);

        // Create an anchor element to trigger the download
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'sale_orders.pdf')
          ..click();

        // Revoke the object URL to free up memory
        html.Url.revokeObjectUrl(url);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to PDF successfully!')),
        );
      }
    } catch (e, stackTrace) {
      // Log the error and stack trace
      print('Error occurred during PDF export: $e');
      print('Stack trace: $stackTrace');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export to PDF: $e')),
      );
    }
  }
}
