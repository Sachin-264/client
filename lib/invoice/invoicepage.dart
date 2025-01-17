import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:excel/excel.dart'; // For Excel export
import 'package:pdf/pdf.dart'; // For PDF export
import 'package:pdf/widgets.dart' as pw; // For PDF export
import 'package:path_provider/path_provider.dart'; // For file storage
import 'dart:io'; // For file operations
import 'dart:html' as html; // For HTML operations

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
        title: const Text(
          'Perform Invoice List',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Export buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<InvoiceBloc, InvoiceState>(
                  builder: (context, state) {
                    if (state is InvoiceLoaded) {
                      // Convert List<Invoice> to List<Map<String, dynamic>>
                      final invoiceMaps = state.invoices
                          .map((invoice) => invoice.toMap())
                          .toList();

                      return ElevatedButton(
                        onPressed: () => _exportToExcel(context, invoiceMaps),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Green background
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Export to Excel',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed:
                            null, // Disable the button if data is not loaded
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, // Grey background
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Export to Excel',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 20),
                BlocBuilder<InvoiceBloc, InvoiceState>(
                  builder: (context, state) {
                    if (state is InvoiceLoaded) {
                      // Convert List<Invoice> to List<Map<String, dynamic>>
                      final invoiceMaps = state.invoices
                          .map((invoice) => invoice.toMap())
                          .toList();

                      return ElevatedButton(
                        onPressed: () => _exportToPDF(context, invoiceMaps),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Red background
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Export to PDF',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed:
                            null, // Disable the button if data is not loaded
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, // Grey background
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Export to PDF',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: InvoiceList(),
          ),
        ],
      ),
    );
  }

  // Export to Excel logic
  Future<void> _exportToExcel(
      BuildContext context, List<Map<String, dynamic>> invoices) async {
    try {
      // Create an Excel file
      var excel = Excel.createExcel();
      excel.delete('flutter'); // Remove the default "flutter" sheet
      var sheet = excel['Sheet1'];

      // Add headers
      sheet.appendRow([
        'Rec No',
        'Branch Code',
        'Invoice No',
        'Invoice Date',
        'Customer Name',
        'Grand Total',
        'LC',
        'Salesman Name',
        'Added By',
        'Added Date',
      ].map((header) => TextCellValue(header)).toList());

      // Add data rows
      for (var invoice in invoices) {
        sheet.appendRow([
          invoice['recNo']?.toString() ?? 'N/A',
          invoice['branchCode']?.toString() ?? 'N/A',
          invoice['invoiceNo']?.toString() ?? 'N/A',
          invoice['invoiceDate']?.toString() ?? 'N/A',
          invoice['accountName']?.toString() ?? 'N/A',
          invoice['grandTotal']?.toString() ?? 'N/A',
          invoice['lc']?.toString() ?? 'N/A',
          invoice['salesManName']?.toString() ?? 'N/A',
          invoice['addUserName']?.toString() ?? 'N/A',
          invoice['addDate']?.toString() ?? 'N/A',
        ].map((value) => TextCellValue(value)).toList());
      }

      // Save the file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/invoice_report.xlsx');
        await file.writeAsBytes(fileBytes);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported to Excel successfully!')),
        );
      }
    } catch (e) {
      // Handle any errors that occur during the export process
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to export to Excel: $e')),
      // );
    }
  }

  // Export to PDF logic
  Future<void> _exportToPDF(
      BuildContext context, List<Map<String, dynamic>> invoices) async {
    try {
      // Create a PDF document
      final pdf = pw.Document();

      // Add a page with a table to the PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  'Invoice Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: [
                    'Rec No',
                    'Branch Code',
                    'Invoice No',
                    'Invoice Date',
                    'Customer Name',
                    'Grand Total',
                    'LC',
                    'Salesman Name',
                    'Added By',
                    'Added Date',
                  ],
                  data: invoices.map((invoice) {
                    return [
                      invoice['recNo']?.toString() ?? 'N/A',
                      invoice['branchCode']?.toString() ?? 'N/A',
                      invoice['invoiceNo']?.toString() ?? 'N/A',
                      invoice['invoiceDate']?.toString() ?? 'N/A',
                      invoice['accountName']?.toString() ?? 'N/A',
                      invoice['grandTotal']?.toString() ?? 'N/A',
                      invoice['lc']?.toString() ?? 'N/A',
                      invoice['salesManName']?.toString() ?? 'N/A',
                      invoice['addUserName']?.toString() ?? 'N/A',
                      invoice['addDate']?.toString() ?? 'N/A',
                    ];
                  }).toList(),
                ),
              ],
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
        ..setAttribute('download', 'invoice_report.pdf')
        ..click();

      // Revoke the object URL to free up memory
      html.Url.revokeObjectUrl(url);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported to PDF successfully!')),
      );
    } catch (e) {
      // Handle any errors that occur during the export process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export to PDF: $e')),
      );
    }
  }
}
