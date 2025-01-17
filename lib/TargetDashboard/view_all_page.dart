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
import 'package:client/TargetDashboard/select_page.dart';
import 'package:client/TargetDashboard/targetsale&viewallbloc.dart';

class ViewAllPage extends StatelessWidget {
  final String salesmanRecNo;

  const ViewAllPage({required this.salesmanRecNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Target Dashboard',
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
      body: BlocProvider(
        create: (context) => TargetSaleBloc()..add(FetchTargetSale()),
        child: BlocBuilder<TargetSaleBloc, TargetSaleState>(
          builder: (context, state) {
            if (state is TargetSaleLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TargetSaleError) {
              return Center(child: Text(state.message));
            } else if (state is TargetSaleLoaded) {
              // Filter data up to the current month
              final now = DateTime.now();
              final filteredData = state.data.where((item) {
                final fromDate = _parseDate(item['FromDate']);
                return fromDate.isBefore(now) || fromDate.month == now.month;
              }).toList();

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
                                context, filteredData); // Export to Excel
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
                            _exportToPDF(
                                context, filteredData); // Export to PDF
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
                        context, filteredData), // PlutoGrid with data
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
        title: 'Month',
        field: 'Month',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Target Value',
        field: 'TargetValue',
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
          // Get the value from the cell
          final value = rendererContext.cell.value.toString();

          // Append '%' to the value
          return Text(
            '$value%', // Add % sign here
            textAlign: TextAlign.right, // Align text to the right
          );
        },
      ),
      PlutoColumn(
        title: 'Action',
        field: 'Action',
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          return TextButton(
            onPressed: () {
              final row = rendererContext.row;
              _handleActionClick(context, row.cells);
            },
            child: Text(
              'Select',
              style: TextStyle(color: Colors.blue),
            ),
          );
        },
      ),
    ];

    // Prepare PlutoGrid rows
    final rows = data.map((item) {
      final month = _getMonthKeyFromDate(item['FromDate'] ?? 'N/A');
      final formattedTargetValue = _formatValuePer(item['TargeValue'] ?? '0');
      final formattedSaleValue = _formatValuePer(item['SaleValue'] ?? '0');
      final formattedValuePer = _formatValuePer(item['ValuePer'] ?? '0');

      // Apply _formatNumber to add commas
      final targetValue = _formatNumber(formattedTargetValue);
      final saleValue = _formatNumber(formattedSaleValue);
      final valuePer = _formatNumber(formattedValuePer);

      return PlutoRow(
        cells: {
          'Month': PlutoCell(value: month),
          'TargetValue': PlutoCell(value: targetValue),
          'SaleValue': PlutoCell(value: saleValue),
          'ValuePer': PlutoCell(value: valuePer),
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

  // Helper method to parse API date (e.g., "01-Apr-2024")
  DateTime _parseDate(String fromDate) {
    final parts = fromDate.split('-');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]) ?? 1;
      final month = _getMonthNumber(parts[1]);
      final year = int.tryParse(parts[2]) ?? DateTime.now().year;
      return DateTime(year, month, day);
    }
    return DateTime.now();
  }

  // Helper method to get month number from abbreviation (e.g., "Apr" -> 4)
  int _getMonthNumber(String monthAbbr) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames.indexOf(monthAbbr) + 1;
  }

  // Helper method to extract month key from API date (e.g., "01-Apr-2024" -> "Apr-2024")
  String _getMonthKeyFromDate(String fromDate) {
    final parts = fromDate.split('-');
    if (parts.length == 3) {
      return '${parts[1]}-${parts[2]}'; // Returns "Apr-2024"
    }
    return '';
  }

  // Handle Action button click
  void _handleActionClick(BuildContext context, Map<String, PlutoCell> cells) {
    // Get the month and year from the cell value (e.g., "Apr-2024")
    final monthYear = cells['Month']?.value.toString() ?? 'Apr-2024';

    // Convert "Apr-2024" to "01-Apr-2024"
    final fromDate = '01-$monthYear';

    // Calculate the last day of the month for toDate
    final month = monthYear.split('-')[0]; // Extract month (e.g., "Apr")
    final year = monthYear.split('-')[1]; // Extract year (e.g., "2024")
    final lastDay =
        _getLastDayOfMonth(month, year); // Calculate last day of the month

    // Construct toDate (e.g., "30-Apr-2024")
    final toDate = '$lastDay-$monthYear';

    // Print debug information
    print("Viewalldata");
    print("From Date: $fromDate");
    print("To Date: $toDate");
    print("Salesman RecNo: $salesmanRecNo");

    // Navigate to SelectPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectPage(
          fromDate: fromDate,
          toDate: toDate,
        ),
      ),
    );
  }

  // Helper function to get the last day of the month
  String _getLastDayOfMonth(String month, String year) {
    // Map month names to month numbers
    final monthMap = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    // Get the month number
    final monthNumber = monthMap[month] ?? 1;

    // Calculate the last day of the month
    final lastDay = DateTime(int.parse(year), monthNumber + 1, 0).day;

    return lastDay.toString();
  }

  // Helper function to add leading zero to values like ".67" or "-.88"
  String _formatValuePer(String value) {
    if (value.startsWith('-.')) {
      return '-0${value.substring(1)}'; // Add leading zero after the negative sign
    } else if (value.startsWith('.')) {
      return '0$value'; // Add leading zero if the value starts with a dot
    }
    return value; // Return the original value if it's already formatted
  }

  // Helper method to format numbers with commas
  String _formatNumber(String number) {
    final parts = number.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Check if the number is negative
    final isNegative = integerPart.startsWith('-');
    final digits = isNegative ? integerPart.substring(1) : integerPart;

    // Add commas to the integer part
    final buffer = StringBuffer();
    int count = 0;

    // Start from the end of the integer part
    for (int i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;

      // Add a comma after every three digits from the right
      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      }
      // After the first comma, add commas after every two digits
      else if (count == 2 && i != 0 && buffer.toString().contains(',')) {
        buffer.write(',');
        count = 0;
      }
    }

    // Reverse the buffer to get the correct format
    final reversed = buffer.toString().split('').reversed.join();

    // Add the negative sign back if necessary
    return '${isNegative ? '-' : ''}$reversed$decimalPart';
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
        TextCellValue('Month'),
        TextCellValue('Target Value'),
        TextCellValue('Sale Value'),
        TextCellValue('% Achieved'),
      ]);

      // Add data rows (wrap strings in TextCellValue)
      for (var item in data) {
        final month = _getMonthKeyFromDate(item['FromDate'] ?? 'N/A');
        final targetValue =
            _formatNumber(_formatValuePer(item['TargeValue'] ?? '0'));
        final saleValue =
            _formatNumber(_formatValuePer(item['SaleValue'] ?? '0'));
        final valuePer =
            _formatNumber(_formatValuePer(item['ValuePer'] ?? '0'));

        sheet.appendRow([
          TextCellValue(month),
          TextCellValue(targetValue),
          TextCellValue(saleValue),
          TextCellValue('$valuePer%'),
        ]);
      }

      // Save the Excel file to bytes
      var fileBytes = excel.save();
      if (fileBytes != null) {
        // Get the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/ViewAllPage.xlsx');

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

      // // Show error message
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
                'Month',
                'Target Value',
                'Sale Value',
                '% Achieved',
              ],
              data: data.map((item) {
                final month = _getMonthKeyFromDate(item['FromDate'] ?? 'N/A');
                final targetValue =
                    _formatNumber(_formatValuePer(item['TargeValue'] ?? '0'));
                final saleValue =
                    _formatNumber(_formatValuePer(item['SaleValue'] ?? '0'));
                final valuePer =
                    _formatNumber(_formatValuePer(item['ValuePer'] ?? '0'));

                return [
                  month,
                  targetValue,
                  saleValue,
                  '$valuePer%',
                ];
              }).toList(),
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
        ..setAttribute('download', 'ViewAllPage.pdf')
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
