import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart'; // Ensure this import is correct
import 'package:syncfusion_flutter_xlsio/xlsio.dart'
    as xlsio; // For Excel export
import 'package:pdf/pdf.dart'; // For PDF export
import 'package:pdf/widgets.dart' as pw; // For PDF export
import 'package:universal_html/html.dart'
    as html; // For file downloads in the browser
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart'; // For file storage
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:open_file/open_file.dart'; // For opening files
import 'report_bloc.dart'; // Your custom Bloc

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
                          onPressed: () async {
                            // Show "Please Wait" message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please wait, exporting to Excel...'),
                                duration: Duration(
                                    seconds: 2), // Adjust duration as needed
                              ),
                            );
                            await _exportToExcel(context); // Export to Excel
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
                          onPressed: () async {
                            // Show "Please Wait" message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please wait, exporting to PDF...'),
                                duration: Duration(
                                    seconds: 2), // Adjust duration as needed
                              ),
                            );
                            await _exportToPDF(context); // Export to PDF
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
        enableEditingMode: false,
        renderer: (rendererContext) {
          final cell = rendererContext.cell;
          final row = rendererContext.row;
          final viewLevel =
              row.cells['ViewLevel']?.value ?? "0"; // Default to "0" if null

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
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Qty',
        field: 'Qty',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Unit Name',
        field: 'UnitName',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Item Remarks',
        field: 'ItemRemarks',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Item File Name',
        field: 'ItemFileName',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        renderer: (rendererContext) {
          final cell = rendererContext.cell;
          final imageUrl = cell.value.toString();

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
          'ViewLevel': PlutoCell(value: data['ViewLevel']),
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

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      print('Exporting to Excel...'); // Debug print

      // Fetch data from the Bloc
      final state = context.read<ReportBloc>().state;
      if (state is ReportLoaded) {
        final reportData = state.reportData;
        print('Report Data: $reportData'); // Debug print

        // Create a new Excel workbook
        final xlsio.Workbook workbook = xlsio.Workbook();
        final xlsio.Worksheet sheet = workbook.worksheets[0];

        // Add headers
        sheet.getRangeByName('A1').setText('Item Name');
        sheet.getRangeByName('B1').setText('Our Item No');
        sheet.getRangeByName('C1').setText('Qty');
        sheet.getRangeByName('D1').setText('Unit Name');
        sheet.getRangeByName('E1').setText('Item File Name');

        // Add data rows
        for (var i = 0; i < reportData.length; i++) {
          final data = reportData[i];
          sheet.getRangeByName('A${i + 2}').setText(data['ItemName'] ?? 'N/A');
          sheet.getRangeByName('B${i + 2}').setText(data['OurItemNo'] ?? 'N/A');
          sheet.getRangeByName('C${i + 2}').setText(data['Qty'] ?? 'N/A');
          sheet.getRangeByName('D${i + 2}').setText(data['UnitName'] ?? 'N/A');

          // Download and embed the image if the URL is valid
          final imageUrl = data['ItemFileName']?.toString() ?? '';
          print('Image URL: $imageUrl'); // Debug print
          if (imageUrl.isNotEmpty &&
              Uri.tryParse(imageUrl)?.hasAbsolutePath == true) {
            final imageBytes = await _downloadImage(imageUrl);
            if (imageBytes != null) {
              // Add the image to the Excel sheet in the "Item File Name" column (column index 5)
              final xlsio.Picture picture =
                  sheet.pictures.addStream(i + 2, 5, imageBytes);
              picture.height = 50; // Set image height
              picture.width = 50; // Set image width

              // Adjust row height to fit the image
              sheet.getRangeByName('A${i + 2}:E${i + 2}').rowHeight = 50;
            } else {
              sheet.getRangeByName('E${i + 2}').setText('Image not available');
            }
          } else {
            sheet.getRangeByName('E${i + 2}').setText('No image');
          }
        }

        // Auto-fit columns for better readability
        sheet.getRangeByName('A1:E${reportData.length + 1}').autoFitColumns();

        // Save the Excel file to bytes
        final List<int> fileBytes = workbook.saveAsStream();
        workbook.dispose();

        // Create a Blob from the Excel bytes
        final blob = html.Blob([
          fileBytes
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);

        // Create an anchor element to trigger the download
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'ReportPage.xlsx')
          ..click();

        // Revoke the object URL to free up memory
        html.Url.revokeObjectUrl(url);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported to Excel successfully!')),
        );
      }
    } catch (e, stackTrace) {
      // Log the error and stack trace
      print('Error occurred during Excel export: $e');
      print('Stack trace: $stackTrace');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export to Excel: $e')),
      );
    }
  }

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
              return pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Table headers
                  pw.TableRow(
                    children: [
                      pw.Text('Item Name'),
                      pw.Text('Our Item No'),
                      pw.Text('Qty'),
                      pw.Text('Unit Name'),
                      pw.Text('Item File Name'),
                    ],
                  ),
                  // Table rows
                  for (var data in reportData)
                    pw.TableRow(
                      children: [
                        pw.Text(data['ItemName'] ?? 'N/A'),
                        pw.Text(data['OurItemNo'] ?? 'N/A'),
                        pw.Text(data['Qty'] ?? 'N/A'),
                        pw.Text(data['UnitName'] ?? 'N/A'),
                        pw.Text(data['ItemFileName'] ?? 'No image'),
                      ],
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

  // Helper function to download an image from a URL
  Future<Uint8List?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }
}
