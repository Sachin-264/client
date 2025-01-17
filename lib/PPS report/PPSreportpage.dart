import 'dart:developer'; // For logging
import 'package:client/PPS%20report/PPSreportbloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:excel/excel.dart'; // For Excel export
import 'package:pdf/pdf.dart'; // For PDF export
import 'package:pdf/widgets.dart' as pw; // For PDF export
import 'package:path_provider/path_provider.dart'; // For file storage
import 'dart:io'; // For file operations
import 'dart:html' as html; // For HTML operations

class PpsReportPage extends StatelessWidget {
  final Map<String, String> filters;

  const PpsReportPage({super.key, required this.filters});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PpsReportBloc()..add(FetchPpsReport(filters: filters)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'PDS Report Filter',
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
                  BlocBuilder<PpsReportBloc, PpsReportState>(
                    builder: (context, state) {
                      if (state is PpsReportLoaded) {
                        return ElevatedButton(
                          onPressed: () =>
                              _exportToExcel(context, state.reports),
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
                  BlocBuilder<PpsReportBloc, PpsReportState>(
                    builder: (context, state) {
                      if (state is PpsReportLoaded) {
                        return ElevatedButton(
                          onPressed: () => _exportToPDF(context, state.reports),
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
              child: PpsReportGrid(),
            ),
          ],
        ),
      ),
    );
  }

  // Export to Excel logic
  Future<void> _exportToExcel(
      BuildContext context, List<Map<String, dynamic>> reports) async {
    try {
      // Create an Excel file
      var excel = Excel.createExcel();
      excel.delete('flutter'); // Remove the default "flutter" sheet
      var sheet = excel['Sheet1'];

      // Add headers
      sheet.appendRow([
        'S.No.',
        'Sale Order No',
        'Sale Order Date',
        'Customer Name',
        'Value',
        'Delivery Date',
        'Desired Date',
        'PDS1 Date',
        'Employee Name 1',
        'PDS1 Remarks',
        'PDS2 Date',
        'Employee Name 2',
        'PDS2 Remarks',
        'PDS3 Date',
        'Employee Name 3',
        'PDS3 Remarks',
        'Salesman Name',
        'Status',
      ].map((header) => TextCellValue(header)).toList());

      // Add data rows
      for (var report in reports) {
        sheet.appendRow([
          report['sno']?.toString() ?? 'N/A',
          report['saleOrderNo']?.toString() ?? 'N/A',
          report['saleOrderDate']?.toString() ?? 'N/A',
          report['customerName']?.toString() ?? 'N/A',
          report['grandTotal']?.toString() ?? 'N/A',
          report['deliveryDate']?.toString() ?? 'N/A',
          report['desiredDate']?.toString() ?? 'N/A',
          report['pds1Date']?.toString() ?? 'N/A',
          report['employeeName1']?.toString() ?? 'N/A',
          report['pds1Remarks']?.toString() ?? 'N/A',
          report['pds2Date']?.toString() ?? 'N/A',
          report['employeeName2']?.toString() ?? 'N/A',
          report['pds2Remarks']?.toString() ?? 'N/A',
          report['pds3Date']?.toString() ?? 'N/A',
          report['employeeName3']?.toString() ?? 'N/A',
          report['pds3Remarks']?.toString() ?? 'N/A',
          report['salesmanName']?.toString() ?? 'N/A',
          report['status']?.toString() ?? 'N/A',
        ].map((value) => TextCellValue(value)).toList());
      }

      // Save the file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/pps_report.xlsx');
        await file.writeAsBytes(fileBytes);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported to Excel successfully!')),
        );
      }
    } catch (e) {
      // Handle any errors that occur during the export process
    }
  }

  // Export to PDF logic
  Future<void> _exportToPDF(
      BuildContext context, List<Map<String, dynamic>> reports) async {
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
                  'PPS Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: [
                    'S.No.',
                    'Sale Order No',
                    'Sale Order Date',
                    'Customer Name',
                    'Value',
                    'Delivery Date',
                    'Desired Date',
                    'PDS1 Date',
                    'Employee Name 1',
                    'PDS1 Remarks',
                    'PDS2 Date',
                    'Employee Name 2',
                    'PDS2 Remarks',
                    'PDS3 Date',
                    'Employee Name 3',
                    'PDS3 Remarks',
                    'Salesman Name',
                    'Status',
                  ],
                  data: reports.map((report) {
                    return [
                      report['sno']?.toString() ?? 'N/A',
                      report['saleOrderNo']?.toString() ?? 'N/A',
                      report['saleOrderDate']?.toString() ?? 'N/A',
                      report['customerName']?.toString() ?? 'N/A',
                      report['grandTotal']?.toString() ?? 'N/A',
                      report['deliveryDate']?.toString() ?? 'N/A',
                      report['desiredDate']?.toString() ?? 'N/A',
                      report['pds1Date']?.toString() ?? 'N/A',
                      report['employeeName1']?.toString() ?? 'N/A',
                      report['pds1Remarks']?.toString() ?? 'N/A',
                      report['pds2Date']?.toString() ?? 'N/A',
                      report['employeeName2']?.toString() ?? 'N/A',
                      report['pds2Remarks']?.toString() ?? 'N/A',
                      report['pds3Date']?.toString() ?? 'N/A',
                      report['employeeName3']?.toString() ?? 'N/A',
                      report['pds3Remarks']?.toString() ?? 'N/A',
                      report['salesmanName']?.toString() ?? 'N/A',
                      report['status']?.toString() ?? 'N/A',
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
        ..setAttribute('download', 'sale_orders.pdf')
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

class PpsReportGrid extends StatelessWidget {
  const PpsReportGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PpsReportBloc, PpsReportState>(
      builder: (context, state) {
        log('Current state in PpsReportGrid: $state');
        if (state is PpsReportLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PpsReportError) {
          return Center(child: Text(state.message));
        } else if (state is PpsReportLoaded) {
          log('Reports data in PpsReportGrid: ${state.reports}');

          return PlutoGrid(
            columns: _buildColumns(),
            rows: _buildRows(state.reports),
            configuration: PlutoGridConfiguration(
              columnFilter: PlutoGridColumnFilterConfig(
                filters: const [
                  ...FilterHelper.defaultFilters,
                ],
              ),
            ),
            onLoaded: (PlutoGridOnLoadedEvent event) {
              event.stateManager.setShowColumnFilter(true);
            },
          );
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  // Define columns for PlutoGrid
  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'S.No.',
        field: 'sno',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Sale Order No',
        field: 'saleOrderNo',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Sale Order Date',
        field: 'saleOrderDate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Customer Name',
        field: 'customerName',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Value',
        field: 'grandTotal',
        type: PlutoColumnType.number(),
        textAlign: PlutoColumnTextAlign.right,
        renderer: (rendererContext) {
          final value = rendererContext.row.cells['grandTotal']?.value;
          final cleanedValue =
              value != null ? value.toString().replaceAll(',', '') : '0';
          final formattedValue = _formatNumber(cleanedValue);
          return Text(
            formattedValue,
            textAlign: TextAlign.right,
          );
        },
      ),
      PlutoColumn(
        title: 'Delivery Date',
        field: 'deliveryDate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Desired Date',
        field: 'desiredDate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS1 Date',
        field: 'pds1Date',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Employee Name 1',
        field: 'employeeName1',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS1 Remarks',
        field: 'pds1Remarks',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS2 Date',
        field: 'pds2Date',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Employee Name 2',
        field: 'employeeName2',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS2 Remarks',
        field: 'pds2Remarks',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS3 Date',
        field: 'pds3Date',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Employee Name 3',
        field: 'employeeName3',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS3 Remarks',
        field: 'pds3Remarks',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Salesman Name',
        field: 'salesmanName',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          return InkWell(
            onTap: () {
              final row = rendererContext.row;
              log('Selected Sale Order: ${row.cells['saleOrderNo']?.value}');
            },
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                ' Select',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  // Convert API data to PlutoRow format
  List<PlutoRow> _buildRows(List<Map<String, dynamic>> reports) {
    double totalValue = 0;
    for (var report in reports) {
      final value = report['GrandTotal'] ?? '0';
      final cleanedValue = value.toString().replaceAll(',', '');
      try {
        totalValue += double.parse(cleanedValue);
      } catch (e) {
        log('Error parsing GrandTotal: $cleanedValue');
      }
    }

    final rows = reports.asMap().entries.map((entry) {
      final index = entry.key;
      final report = entry.value;
      return PlutoRow(
        cells: {
          'sno': PlutoCell(value: (index + 1).toString()),
          'saleOrderNo': PlutoCell(value: report['SaleOrderNo'] ?? 'N/A'),
          'saleOrderDate': PlutoCell(value: report['AddDate'] ?? 'N/A'),
          'customerName': PlutoCell(value: report['AccountName'] ?? 'N/A'),
          'grandTotal': PlutoCell(value: report['GrandTotal'] ?? 'N/A'),
          'deliveryDate': PlutoCell(value: report['DeliveryDate'] ?? 'N/A'),
          'desiredDate': PlutoCell(value: report['DesiredDate'] ?? 'N/A'),
          'pds1Date': PlutoCell(value: report['PDS1Date'] ?? 'N/A'),
          'employeeName1': PlutoCell(value: report['EmployeeName1'] ?? 'N/A'),
          'pds1Remarks': PlutoCell(value: report['PDS1Remarks'] ?? 'N/A'),
          'pds2Date': PlutoCell(value: report['PDS2Date'] ?? 'N/A'),
          'employeeName2': PlutoCell(value: report['EmployeeName2'] ?? 'N/A'),
          'pds2Remarks': PlutoCell(value: report['PDS2Remarks'] ?? 'N/A'),
          'pds3Date': PlutoCell(value: report['PDS3Date'] ?? 'N/A'),
          'employeeName3': PlutoCell(value: report['EmployeeName3'] ?? 'N/A'),
          'pds3Remarks': PlutoCell(value: report['PDS3Remarks'] ?? 'N/A'),
          'salesmanName': PlutoCell(value: report['SalesManName'] ?? 'N/A'),
          'status': PlutoCell(value: 'Select'),
        },
      );
    }).toList();

    rows.add(
      PlutoRow(
        cells: {
          'sno': PlutoCell(value: 'Total'),
          'saleOrderNo': PlutoCell(value: ''),
          'saleOrderDate': PlutoCell(value: ''),
          'customerName': PlutoCell(value: ''),
          'grandTotal': PlutoCell(value: totalValue),
          'deliveryDate': PlutoCell(value: ''),
          'desiredDate': PlutoCell(value: ''),
          'pds1Date': PlutoCell(value: ''),
          'employeeName1': PlutoCell(value: ''),
          'pds1Remarks': PlutoCell(value: ''),
          'pds2Date': PlutoCell(value: ''),
          'employeeName2': PlutoCell(value: ''),
          'pds2Remarks': PlutoCell(value: ''),
          'pds3Date': PlutoCell(value: ''),
          'employeeName3': PlutoCell(value: ''),
          'pds3Remarks': PlutoCell(value: ''),
          'salesmanName': PlutoCell(value: ''),
          'status': PlutoCell(value: ''),
        },
      ),
    );

    return rows;
  }

  // Format number with commas
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
}
