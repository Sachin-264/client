import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'orderAllocation_bloc.dart';
import 'orderAllocation_list.dart';

class orderAllocationPage extends StatefulWidget {
  final Map<String, String> filters;
  const orderAllocationPage({super.key, required this.filters});

  @override
  State<orderAllocationPage> createState() => _orderAllocationPageState();
}

class _orderAllocationPageState extends State<orderAllocationPage> {
  late orderAllocationBloc _orderAllocationBloc;

  @override
  void initState() {
    super.initState();
    _orderAllocationBloc = orderAllocationBloc();
    _orderAllocationBloc.add(FetchorderAllocationEvent(filters: widget.filters));
  }

  @override
  void dispose() {
    _orderAllocationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _orderAllocationBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Order Allocation Report',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _exportToExcel(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Export to Excel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _exportToPDF(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              child: orderAllocationList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      final state = _orderAllocationBloc.state;
      if (state is orderAllocationLoaded) {
        final orderAllocations = state.orderAllocations;
        var excel = Excel.createExcel();
        excel.delete('Sheet1');
        var sheet = excel['OrderAllocations'];

        sheet.appendRow([
          'Sale Order No',
          'Sale Order Date',
          'Customer Name',
          'Item Code',
          'Item Name',
          'Closing Stock',
          'Order Qty',
          'Order Rate',
          'Item Value',
          'Stock Allocated On',
          'Qty Allocated',
          'Dispatch Qty',
          'Balance Qty to Dispatch',
          'Balance Qty to Mfg',
        ].map((header) => TextCellValue(header)).toList());

        for (var order in orderAllocations) {
          final qty = double.tryParse(order.qty) ?? 0.0;
          final qtyAllocated = double.tryParse(order.qtyAllocated) ?? 0.0;
          final dispatchQty = order.dispatchValue / order.netRate;

          sheet.appendRow([
            TextCellValue(order.orderNo),
            TextCellValue(order.orderDate),
            TextCellValue(order.accountName),
            TextCellValue(order.itemCode ?? ''), // Placeholder
            TextCellValue(order.itemName),
            TextCellValue(order.closingStock ?? ''), // Placeholder
            DoubleCellValue(qty),
            DoubleCellValue(order.netRate),
            DoubleCellValue(order.value),
            TextCellValue(order.allocatedOn),
            DoubleCellValue(qtyAllocated),
            DoubleCellValue(dispatchQty),
            DoubleCellValue(qty - dispatchQty),
            DoubleCellValue(qty - qtyAllocated - dispatchQty),
          ]);
        }

        var fileBytes = excel.save();
        if (fileBytes != null) {
          final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute('download', 'order_allocations_report.xlsx')
            ..click();
          html.Url.revokeObjectUrl(url);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported to Excel successfully!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export: ${e.toString()}')),
      );
    }
  }

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      final state = _orderAllocationBloc.state;
      if (state is orderAllocationLoaded) {
        final orderAllocations = state.orderAllocations;
        final pdf = pw.Document();

        // Define headers
        final headers = [
          'Sale Order No',
          'Sale Order Date',
          'Customer Name',
          'Item Code',
          'Item Name',
          'Closing Stock',
          'Order Qty',
          'Order Rate',
          'Item Value',
          'Stock Allocated On',
          'Qty Allocated',
          'Dispatch Qty',
          'Balance Qty to Dispatch',
          'Balance Qty to Mfg',
        ];

        // Prepare data
        final data = orderAllocations.map((order) {
          final qty = double.tryParse(order.qty) ?? 0.0;
          final qtyAllocated = double.tryParse(order.qtyAllocated) ?? 0.0;
          final dispatchQty = order.dispatchValue / order.netRate;

          return [
            order.orderNo,
            order.orderDate,
            order.accountName,
            order.itemCode ?? '',
            order.itemName,
            order.closingStock ?? '',
            qty.toStringAsFixed(2),
            order.netRate.toStringAsFixed(2),
            order.value.toStringAsFixed(2),
            order.allocatedOn,
            qtyAllocated.toStringAsFixed(2),
            dispatchQty.toStringAsFixed(2),
            (qty - dispatchQty).toStringAsFixed(2),
            (qty - qtyAllocated - dispatchQty).toStringAsFixed(2),
          ];
        }).toList();

        // Define column widths (adjust these values as needed)
        final columnWidths = {
          0: const pw.FixedColumnWidth(80),  // Sale Order No
          1: const pw.FixedColumnWidth(80),  // Sale Order Date
          2: const pw.FixedColumnWidth(100), // Customer Name
          3: const pw.FixedColumnWidth(60),  // Item Code
          4: const pw.FixedColumnWidth(100), // Item Name
          5: const pw.FixedColumnWidth(60),  // Closing Stock
          6: const pw.FixedColumnWidth(60),  // Order Qty
          7: const pw.FixedColumnWidth(60),  // Order Rate
          8: const pw.FixedColumnWidth(60),  // Item Value
          9: const pw.FixedColumnWidth(80),  // Stock Allocated On
          10: const pw.FixedColumnWidth(60), // Qty Allocated
          11: const pw.FixedColumnWidth(60), // Dispatch Qty
          12: const pw.FixedColumnWidth(80), // Balance Qty to Dispatch
          13: const pw.FixedColumnWidth(80), // Balance Qty to Mfg
        };

        // Chunk data for multiple pages (e.g., 20 rows per page)
        const int rowsPerPage = 20;
        final totalRows = data.length;
        int pageCount = (totalRows / rowsPerPage).ceil();

        for (int page = 0; page < pageCount; page++) {
          final startIndex = page * rowsPerPage;
          final endIndex = (startIndex + rowsPerPage) > totalRows ? totalRows : (startIndex + rowsPerPage);
          final pageData = data.sublist(startIndex, endIndex);

          pdf.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4.landscape, // Use landscape for more width
              margin: const pw.EdgeInsets.all(20),
              header: (pw.Context context) => pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Text(
                  'Order Allocation Report',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              footer: (pw.Context context) => pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: const pw.EdgeInsets.only(top: 10),
                child: pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              build: (pw.Context context) => [
                pw.Table.fromTextArray(
                  headers: headers,
                  data: pageData,
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  columnWidths: columnWidths,
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: const pw.EdgeInsets.all(4),
                ),
              ],
            ),
          );
        }

        final pdfBytes = await pdf.save();
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'order_allocations_report.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to PDF successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export: ${e.toString()}')),
      );
    }
  }
}
