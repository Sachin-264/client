import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:excel/excel.dart'; // For Excel export
import 'package:pdf/pdf.dart'; // For PDF export
import 'package:pdf/widgets.dart' as pw; // For PDF export
import 'package:universal_html/html.dart'
    as html; // For file downloads in the browser
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart'; // For file storage
import 'package:client/TargetDashboard/targetDashboardBloc.dart';
import 'Targetsalepage.dart'; // Import the TargetSalePage

class TargetDashboardPage extends StatelessWidget {
  const TargetDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Target Dashboard For the Month Of Jan-2025',
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
                Icon(Icons.arrow_back_ios,
                    color: Colors.white), // Blue back icon
                SizedBox(width: 4), // Add spacing between icon and text
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white, // Blue color for text
                    fontSize: 16, // Adjust font size
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => TargetDashboardBloc()..add(FetchTargetDashboard()),
        child: BlocBuilder<TargetDashboardBloc, TargetDashboardState>(
          builder: (context, state) {
            if (state is TargetDashboardLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TargetDashboardError) {
              return Center(child: Text(state.message));
            } else if (state is TargetDashboardLoaded) {
              return Column(
                children: [
                  // Export Buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _exportToExcel(
                                context, state.data); // Export to Excel
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Green background
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'Export to Excel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 20), // Add spacing between buttons
                        ElevatedButton(
                          onPressed: () {
                            _exportToPDF(context, state.data); // Export to PDF
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Red background
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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
                    child: _buildPlutoGrid(
                        context, state.data), // PlutoGrid with data
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildPlutoGrid(
      BuildContext context, List<Map<String, dynamic>> data) {
    // Define PlutoGrid columns
    final columns = [
      PlutoColumn(
        title: 'Name',
        field: 'SalesManName',
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          // Get the ViewLevel value from the row
          final viewLevel = int.tryParse(
                  rendererContext.row.cells['ViewLevel']?.value.toString() ??
                      '1') ??
              1;

          // Calculate padding based on ViewLevel
          final padding = EdgeInsets.only(left: 16.0 * (viewLevel - 1));

          return Padding(
            padding: padding,
            child: Text(
              rendererContext.row.cells['SalesManName']?.value.toString() ??
                  'N/A',
              style: TextStyle(
                fontWeight: FontWeight.bold, // Optional: Add styling
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Designation',
        field: 'SalesManDesignation',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: '% Achieved',
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
              // Get the selected row's data
              final selectedRow = rendererContext.row.cells;

              // Extract the required values
              final salesmanRecNo =
                  selectedRow['SalesManRecNo']?.value.toString() ?? 'N/A';

              print("Accessing data");
              print("Salesman RecNo: $salesmanRecNo");

              // Navigate to TargetSalePage with the selected row's data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TargetSalePage(
                    salesmanRecNo: salesmanRecNo,
                  ),
                ),
              );
            },
            child: Text(
              'Select',
              style: TextStyle(color: Colors.blue),
            ),
          );
        },
      ),
    ];

    // Prepare PlutoGrid rows, skipping rows where SalesManName is missing or empty
    final rows = data
        .where((item) =>
            item['SalesManName'] != null &&
            item['SalesManName'].toString().isNotEmpty)
        .map((item) {
      // Format ValuePer to ensure it has a leading zero if necessary
      final valuePer = _formatValuePer(item['ValuePer']?.toString() ?? '0.00');

      return PlutoRow(
        cells: {
          'SalesManName': PlutoCell(value: item['SalesManName'] ?? 'N/A'),
          'SalesManDesignation':
              PlutoCell(value: item['SalesManDesignation'] ?? 'N/A'),
          'ValuePer': PlutoCell(value: '$valuePer%'), // Use formatted ValuePer
          'SalesManRecNo': PlutoCell(
              value: item['SalesManRecNo'] ?? 'N/A'), // Add SalesManRecNo
          'ViewLevel':
              PlutoCell(value: item['ViewLevel'] ?? '1'), // Add ViewLevel
          'Action': PlutoCell(
              value: 'Select'), // This value is not used due to custom renderer
        },
      );
    }).toList();

    return PlutoGrid(
      columns: columns,
      rows: rows,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        event.stateManager.setShowColumnFilter(true); // Enable filtering
      },
      configuration: PlutoGridConfiguration(
        columnSize: PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
        ),
      ),
    );
  }

  // Helper function to format ValuePer (e.g., .78 → 0.78)
  String _formatValuePer(String value) {
    if (value.startsWith('-.')) {
      return '-0${value.substring(1)}'; // Add leading zero after the negative sign
    } else if (value.startsWith('.')) {
      return '0$value'; // Add leading zero if the value starts with a dot
    }
    return value; // Return the original value if it's already formatted
  }

  // Export to Excel (without Blob)
  Future<void> _exportToExcel(
      BuildContext context, List<Map<String, dynamic>> data) async {
    try {
      // Create an Excel file
      var excel = Excel.createExcel();

      // Remove the default "flutter" sheet
      excel.delete('flutter');

      // Create a new sheet
      var sheet = excel['Sheet1'];

      // Add headers (wrap strings in TextCellValue)
      sheet.appendRow([
        TextCellValue('Name'),
        TextCellValue('Designation'),
        TextCellValue('% Achieved'),
      ]);

      // Add data rows (wrap strings in TextCellValue)
      for (var item in data) {
        sheet.appendRow([
          TextCellValue(item['SalesManName'] ?? 'N/A'),
          TextCellValue(item['SalesManDesignation'] ?? 'N/A'),
          TextCellValue(
              '${_formatValuePer(item['ValuePer']?.toString() ?? '0.00')}%'),
        ]);
      }

      // Save the Excel file to bytes
      var fileBytes = excel.save();
      if (fileBytes != null) {
        // Get the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/TargetDashboardPage.xlsx');

        // Write the Excel file to the device's storage
        await file.writeAsBytes(fileBytes);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported to Excel successfully!')),
        );

        // Print the file path for debugging
        print('Excel file saved at: ${file.path}');
      }
    } catch (e, stackTrace) {
      // Log the error and stack trace
      print('Error occurred during Excel export: $e');
      print('Stack trace: $stackTrace');

      // Show error message
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to export to Excel: $e')),
      // );
    }
  }

  // Export to PDF (with Blob)
  Future<void> _exportToPDF(
      BuildContext context, List<Map<String, dynamic>> data) async {
    try {
      // Create a PDF document
      final pdf = pw.Document();

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Table.fromTextArray(
              headers: [
                'Name',
                'Designation',
                '% Achieved',
              ],
              data: data
                  .map((item) => [
                        item['SalesManName'] ?? 'N/A',
                        item['SalesManDesignation'] ?? 'N/A',
                        '${_formatValuePer(item['ValuePer']?.toString() ?? '0.00')}%',
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
        ..setAttribute('download', 'TargetDashboardPage.pdf')
        ..click();

      // Revoke the object URL to free up memory
      html.Url.revokeObjectUrl(url);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported to PDF successfully!')),
      );
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
