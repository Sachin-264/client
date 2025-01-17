import 'package:client/TargetDashboard/accessories_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:excel/excel.dart'; // For Excel export
import 'package:pdf/pdf.dart'; // For PDF export
import 'package:pdf/widgets.dart' as pw; // For PDF export
import 'package:path_provider/path_provider.dart'; // For file storage
import 'dart:io'; // For file operations
import 'dart:html' as html; // For HTML operations
import 'selectpage_bloc.dart'; // Import your SelectPageBloc

class SelectPage extends StatelessWidget {
  final String fromDate;
  final String toDate;

  const SelectPage({
    super.key,
    required this.fromDate,
    required this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectPageBloc()
        ..add(FetchSalesManData(fromDate: fromDate, toDate: toDate)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Salesman Report',
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlocBuilder<SelectPageBloc, SelectPageState>(
                    builder: (context, state) {
                      if (state is SalesManDataLoaded) {
                        return ElevatedButton(
                          onPressed: () => _exportToExcel(context, state.data),
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
                  BlocBuilder<SelectPageBloc, SelectPageState>(
                    builder: (context, state) {
                      if (state is SalesManDataLoaded) {
                        return ElevatedButton(
                          onPressed: () => _exportToPDF(context, state.data),
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
            // PlutoGrid
            Expanded(
              child: BlocBuilder<SelectPageBloc, SelectPageState>(
                builder: (context, state) {
                  if (state is SalesManDataLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is SalesManDataError) {
                    return Center(child: Text(state.message));
                  } else if (state is SalesManDataLoaded) {
                    final data = state.data;

                    final filteredData = data.where((item) {
                      final targetValue = double.tryParse(item.targeValue) ?? 0;
                      final saleValue = double.tryParse(item.saleValue) ?? 0;
                      return targetValue != 0 || saleValue != 0;
                    }).toList();

                    final columns = [
                      PlutoColumn(
                        title: 'Executive Name',
                        field: 'SalesManName',
                        type: PlutoColumnType.text(),
                      ),
                      PlutoColumn(
                        title: 'HQ Name',
                        field: 'HQName',
                        type: PlutoColumnType.text(),
                      ),
                      PlutoColumn(
                        title: 'Designation',
                        field: 'SalesManDesignation',
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
                      ),
                      PlutoColumn(
                        title: 'Action',
                        field: 'Action',
                        type: PlutoColumnType.text(),
                        renderer: (rendererContext) {
                          return TextButton(
                            onPressed: () {
                              final salesmanRecNo = rendererContext
                                  .row.cells['SalesManRecNo']?.value
                                  .toString();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemPage(
                                    fromDate: fromDate,
                                    toDate: toDate,
                                    salesmanId: '157.0',
                                    salesmanRecNo: salesmanRecNo ?? '0',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Select',
                              style: TextStyle(color: Colors.blue),
                            ),
                          );
                        },
                      ),
                    ];

                    final rows = filteredData.map((item) {
                      return PlutoRow(
                        cells: {
                          'SalesManName': PlutoCell(value: item.salesManName),
                          'HQName': PlutoCell(value: item.hqName),
                          'SalesManDesignation':
                              PlutoCell(value: item.salesManDesignation),
                          'TargeValue': PlutoCell(value: item.targeValue),
                          'SaleValue': PlutoCell(value: item.saleValue),
                          'ValuePer': PlutoCell(value: item.valuePer),
                          'SalesManRecNo': PlutoCell(value: item.salesManRecNo),
                          'Action': PlutoCell(value: 'Select'),
                        },
                      );
                    }).toList();

                    return PlutoGrid(
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
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Export to Excel logic
Future<void> _exportToExcel(
    BuildContext context, List<SalesManData> salesManData) async {
  try {
    // Create an Excel file
    var excel = Excel.createExcel();
    excel.delete('flutter'); // Remove the default "flutter" sheet
    var sheet = excel['Sheet1'];

    // Add headers
    sheet.appendRow([
      'Executive Name',
      'HQ Name',
      'Designation',
      'Target Value',
      'Sale Value',
      '%Achieved',
    ].map((header) => TextCellValue(header)).toList());

    // Add data rows
    for (var data in salesManData) {
      sheet.appendRow([
        data.salesManName ?? 'N/A',
        data.hqName ?? 'N/A',
        data.salesManDesignation ?? 'N/A',
        data.targeValue ?? 'N/A',
        data.saleValue ?? 'N/A',
        data.valuePer ?? 'N/A',
      ].map((value) => TextCellValue(value)).toList());
    }

    // Save the file
    var fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/salesman_report.xlsx');
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
    BuildContext context, List<SalesManData> salesManData) async {
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
                'Salesman Report',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: [
                  'Executive Name',
                  'HQ Name',
                  'Designation',
                  'Target Value',
                  'Sale Value',
                  '%Achieved',
                ],
                data: salesManData.map((data) {
                  return [
                    data.salesManName ?? 'N/A',
                    data.hqName ?? 'N/A',
                    data.salesManDesignation ?? 'N/A',
                    data.targeValue ?? 'N/A',
                    data.saleValue ?? 'N/A',
                    data.valuePer ?? 'N/A',
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
      ..setAttribute('download', 'salesman_report.pdf')
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
