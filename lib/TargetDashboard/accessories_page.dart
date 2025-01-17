import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:excel/excel.dart'; // For Excel export
import 'package:pdf/pdf.dart'; // For PDF export
import 'package:pdf/widgets.dart' as pw; // For PDF export
import 'package:path_provider/path_provider.dart'; // For file storage
import 'dart:io'; // For file operations
import 'dart:html' as html; // For HTML operations
import 'accessories_bloc.dart'; // Import the ItemBloc

class ItemPage extends StatelessWidget {
  final String fromDate;
  final String toDate;
  final String salesmanId;
  final String salesmanRecNo;

  const ItemPage({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.salesmanId,
    required this.salesmanRecNo,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemBloc()
        ..add(FetchItemData(
          fromDate: fromDate,
          toDate: toDate,
          salesmanId: salesmanId,
          salesmanRecNo: salesmanRecNo,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ItemWise Report',
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
        body: BlocBuilder<ItemBloc, ItemState>(
          builder: (context, state) {
            if (state is ItemLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ItemError) {
              return Center(child: Text(state.message));
            } else if (state is ItemLoaded) {
              final data = state.data;

              // Filter out rows where both TargetValue and SaleValue are zero
              final filteredData = data.where((item) {
                final targetValue =
                    double.tryParse(item['TargeValue'] ?? '0') ?? 0;
                final saleValue =
                    double.tryParse(item['SaleValue'] ?? '0') ?? 0;
                return targetValue != 0 || saleValue != 0;
              }).toList();

              // Define PlutoGrid columns
              final columns = [
                PlutoColumn(
                  title: 'Item Group Name',
                  field: 'ItemGroupName',
                  type: PlutoColumnType.text(),
                ),
                PlutoColumn(
                  title: 'Target Value',
                  field: 'TargeValue',
                  type: PlutoColumnType.text(),
                  textAlign: PlutoColumnTextAlign.right,
                ),
                PlutoColumn(
                  title: 'Sale Value',
                  field: 'SaleValue',
                  type: PlutoColumnType.text(),
                  textAlign: PlutoColumnTextAlign.right,
                ),
                PlutoColumn(
                  title: '%Achieved',
                  field: 'ValuePer',
                  type: PlutoColumnType.text(),
                  textAlign: PlutoColumnTextAlign.right,
                  renderer: (rendererContext) {
                    final value = rendererContext.cell.value.toString();
                    return Text(
                      '$value%',
                      textAlign: TextAlign.right,
                    );
                  },
                ),
              ];

              // Prepare PlutoGrid rows
              final rows = filteredData.map((item) {
                final targetValue =
                    double.tryParse(item['TargeValue'] ?? '0') ?? 0;
                final saleValue =
                    double.tryParse(item['SaleValue'] ?? '0') ?? 0;
                final valuePer = double.tryParse(item['ValuePer'] ?? '0') ?? 0;

                return PlutoRow(
                  cells: {
                    'ItemGroupName':
                        PlutoCell(value: item['ItemGroupName'] ?? 'N/A'),
                    'TargeValue':
                        PlutoCell(value: _formatNumber(targetValue.toString())),
                    'SaleValue':
                        PlutoCell(value: _formatNumber(saleValue.toString())),
                    'ValuePer':
                        PlutoCell(value: _formatNumber(valuePer.toString())),
                  },
                );
              }).toList();

              // Add a last row for totals
              double totalTargetValue = filteredData.fold(0, (sum, item) {
                return sum + (double.tryParse(item['TargeValue'] ?? '0') ?? 0);
              });
              double totalSaleValue = filteredData.fold(0, (sum, item) {
                return sum + (double.tryParse(item['SaleValue'] ?? '0') ?? 0);
              });
              double totalValuePer = filteredData.fold(0, (sum, item) {
                return sum + (double.tryParse(item['ValuePer'] ?? '0') ?? 0);
              });

              rows.add(
                PlutoRow(
                  cells: {
                    'ItemGroupName': PlutoCell(value: 'Total'),
                    'TargeValue': PlutoCell(
                        value: _formatNumber(totalTargetValue.toString())),
                    'SaleValue': PlutoCell(
                        value: _formatNumber(totalSaleValue.toString())),
                    'ValuePer': PlutoCell(
                        value: _formatNumber(totalValuePer.toString())),
                  },
                ),
              );

              return Column(
                children: [
                  // Export buttons
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              _exportToExcel(context, filteredData),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Export to Excel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _exportToPDF(context, filteredData),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Export to PDF',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // PlutoGrid
                  Expanded(
                    child: PlutoGrid(
                      columns: columns,
                      rows: rows,
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        event.stateManager.setShowColumnFilter(true);
                      },
                      configuration: PlutoGridConfiguration(
                        columnSize: PlutoGridColumnSizeConfig(
                          autoSizeMode: PlutoAutoSizeMode.scale,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Container(); // Initial state
          },
        ),
      ),
    );
  }

  // Helper method to format numbers with commas
  String _formatNumber(String number) {
    final parts = number.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final isNegative = integerPart.startsWith('-');
    final digits = isNegative ? integerPart.substring(1) : integerPart;

    final buffer = StringBuffer();
    int count = 0;

    for (int i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;

      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      } else if (count == 2 && i != 0 && buffer.toString().contains(',')) {
        buffer.write(',');
        count = 0;
      }
    }

    final reversed = buffer.toString().split('').reversed.join();
    return '${isNegative ? '-' : ''}$reversed$decimalPart';
  }

  // Export to Excel logic
  Future<void> _exportToExcel(
      BuildContext context, List<Map<String, dynamic>> data) async {
    try {
      var excel = Excel.createExcel();
      excel.delete('flutter'); // Remove the default "flutter" sheet
      var sheet = excel['Sheet1'];

      // Add headers
      sheet.appendRow([
        'Item Group Name',
        'Target Value',
        'Sale Value',
        '%Achieved',
      ].map((header) => TextCellValue(header)).toList());

      // Add data rows
      for (var item in data) {
        sheet.appendRow([
          item['ItemGroupName'] ?? 'N/A',
          item['TargeValue'] ?? 'N/A',
          item['SaleValue'] ?? 'N/A',
          item['ValuePer'] ?? 'N/A',
        ].map((value) => TextCellValue(value)).toList());
      }

      // Save the file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/item_report.xlsx');
        await file.writeAsBytes(fileBytes);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported to Excel successfully!')),
        );
      }
    } catch (e) {}
  }

  // Export to PDF logic
  Future<void> _exportToPDF(
      BuildContext context, List<Map<String, dynamic>> data) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  'ItemWise Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: [
                    'Item Group Name',
                    'Target Value',
                    'Sale Value',
                    '%Achieved',
                  ],
                  data: data.map((item) {
                    return [
                      item['ItemGroupName'] ?? 'N/A',
                      item['TargeValue'] ?? 'N/A',
                      item['SaleValue'] ?? 'N/A',
                      item['ValuePer'] ?? 'N/A',
                    ];
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'item_report.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported to PDF successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export to PDF: $e')),
      );
    }
  }
}
