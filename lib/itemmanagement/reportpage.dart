import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart'; // Ensure this import is correct
import 'package:excel/excel.dart'; // For Excel export
import 'package:pdf/pdf.dart'; // For PDF export
import 'package:pdf/widgets.dart' as pw; // For PDF export
import 'package:universal_html/html.dart'
    as html; // For file downloads in the browser
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart'; // For file storage
import 'report_bloc.dart';

class ReportPage extends StatelessWidget {
  final String itemCode;
  final String quantity;

  const ReportPage({super.key, required this.itemCode, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: Colors.blue,
      ),
      body: BlocProvider(
        create: (context) => ReportBloc()
          ..add(FetchReport(itemCode: itemCode, quantity: quantity)),
        child: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            if (state is ReportLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ReportError) {
              return Center(child: Text(state.message));
            } else if (state is ReportLoaded) {
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
                            _exportToExcel(context); // Export to Excel
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Green background
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Export to Excel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                            width: 20), // Add spacing between buttons
                        ElevatedButton(
                          onPressed: () {
                            _exportToPDF(context); // Export to PDF
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Red background
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
                  Expanded(
                    child: _buildPlutoGrid(
                        state.reportData), // PlutoGrid with data
                  ),
                ],
              );
            }
            return const Center(child: Text('No data available'));
          },
        ),
      ),
    );
  }

  Widget _buildPlutoGrid(List<Map<String, dynamic>> reportData) {
    final columns = _buildColumns();
    final rows = _buildRows(reportData);

    return PlutoGrid(
      columns: columns,
      rows: rows,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        event.stateManager.setShowColumnFilter(true); // Enable filtering
      },
      configuration: const PlutoGridConfiguration(
        columnSize: PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
        ),
      ),
    );
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'Item Name',
        field: 'ItemName',
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          final cell = rendererContext.cell;
          final row = rendererContext.row;
          final viewLevel =
              row.cells['ViewLevel']?.value ?? "0"; // Default to "0" if null

          // Print ViewLevel for debugging
          print('ViewLevel: $viewLevel');

          // Convert ViewLevel to a double for padding calculation
          final viewLevelValue = double.tryParse(viewLevel.toString()) ?? 0.0;

          // Calculate padding based on ViewLevel
          final padding = EdgeInsets.all(8.0 * viewLevelValue);

          // Determine if ItemName should be bold
          final isBold = viewLevelValue == 0;

          return Padding(
            padding: padding,
            child: Text(
              cell.value.toString(),
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Our Item No',
        field: 'OurItemNo',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Qty',
        field: 'Qty',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Unit Name',
        field: 'UnitName',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Item Remarks',
        field: 'ItemRemarks',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Item File Name',
        field: 'ItemFileName',
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          final cell = rendererContext.cell;
          final imageUrl = cell.value.toString();

          // Print the image URL for debugging
          print('Image URL: $imageUrl');

          // Display the image if the URL is valid
          if (imageUrl.isNotEmpty &&
              Uri.tryParse(imageUrl)?.hasAbsolutePath == true) {
            return Image.network(
              imageUrl,
              width: 50, // Set the width of the image
              height: 50, // Set the height of the image
              fit: BoxFit.cover, // Adjust the image fit
              errorBuilder: (context, error, stackTrace) {
                // Handle errors (e.g., broken or invalid URLs)
                return Icon(Icons.broken_image,
                    color: Colors.red); // Show an error icon
              },
            );
          } else {
            // Show a placeholder if the URL is invalid or empty
            return Icon(Icons.image_not_supported, color: Colors.grey);
          }
        },
      ),
    ];
  }

  List<PlutoRow> _buildRows(List<Map<String, dynamic>> reportData) {
    return reportData.map((data) {
      return PlutoRow(
        cells: {
          'ViewLevel': PlutoCell(
              value: data['ViewLevel']), // Use ViewLevel instead of ValuePer
          'ItemName': PlutoCell(value: data['ItemName']),
          'OurItemNo': PlutoCell(value: data['OurItemNo']),
          'Qty': PlutoCell(value: data['Qty']),
          'UnitName': PlutoCell(value: data['UnitName']),
          'ItemRemarks': PlutoCell(value: data['ItemRemarks']),
          'ItemFileName': PlutoCell(value: data['ItemFileName']),
        },
      );
    }).toList();
  }

  // Export to Excel (without Blob)
  Future<void> _exportToExcel(BuildContext context) async {
    try {
      // Fetch data from the Bloc
      final state = context.read<ReportBloc>().state;
      if (state is ReportLoaded) {
        final reportData = state.reportData;

        // Create an Excel file
        var excel = Excel.createExcel();

        // Remove the default "flutter" sheet
        excel.delete('flutter');

        // Create a new sheet
        var sheet = excel['Sheet1'];

        // Add headers (wrap strings in TextCellValue)
        sheet.appendRow([
          TextCellValue('Item Name'),
          TextCellValue('Our Item No'),
          TextCellValue('Qty'),
          TextCellValue('Unit Name'),
          TextCellValue('Item Remarks'),
          TextCellValue('Item File Name'),
        ]);

        // Add data rows (wrap strings in TextCellValue)
        for (var data in reportData) {
          sheet.appendRow([
            TextCellValue(data['ItemName'] ?? 'N/A'),
            TextCellValue(data['OurItemNo'] ?? 'N/A'),
            TextCellValue(data['Qty'] ?? 'N/A'),
            TextCellValue(data['UnitName'] ?? 'N/A'),
            TextCellValue(data['ItemRemarks'] ?? 'N/A'),
            TextCellValue(data['ItemFileName'] ?? 'N/A'),
          ]);
        }

        // Save the Excel file to bytes
        var fileBytes = excel.save();
        if (fileBytes != null) {
          // Get the application documents directory
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/ReportPage.xlsx');

          // Write the Excel file to the device's storage
          await file.writeAsBytes(fileBytes);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exported to Excel successfully!')),
          );

          // Print the file path for debugging
          print('Excel file saved at: ${file.path}');
        }
      }
    } catch (e, stackTrace) {
      // Log the error and stack trace
      print('Error occurred during Excel export: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Export to PDF (with Blob)
  Future<void> _exportToPDF(BuildContext context) async {
    try {
      // Fetch data from the Bloc
      final state = context.read<ReportBloc>().state;
      if (state is ReportLoaded) {
        final reportData = state.reportData;

        // Create a PDF document
        final pdf = pw.Document();

        // Add a page to the PDF
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Table.fromTextArray(
                headers: [
                  'Item Name',
                  'Our Item No',
                  'Qty',
                  'Unit Name',
                  'Item Remarks',
                  'Item File Name',
                ],
                data: reportData
                    .map((data) => [
                          data['ItemName'] ?? 'N/A',
                          data['OurItemNo'] ?? 'N/A',
                          data['Qty'] ?? 'N/A',
                          data['UnitName'] ?? 'N/A',
                          data['ItemRemarks'] ?? 'N/A',
                          data['ItemFileName'] ?? 'N/A',
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
          ..setAttribute('download', 'ReportPage.pdf')
          ..click();

        // Revoke the object URL to free up memory
        html.Url.revokeObjectUrl(url);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported to PDF successfully!')),
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
