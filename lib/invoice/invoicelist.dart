import 'package:client/invoice/invoice%20bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';

class InvoiceList extends StatelessWidget {
  const InvoiceList({Key? key}) : super(key: key);

  // Helper function to format numbers with commas and two decimal places
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

  // Helper function to ensure a number has exactly two decimal places
  String _ensureTwoDecimalPlaces(String number) {
    final parts = number.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    // Ensure exactly two decimal places
    final formattedDecimal = decimalPart.padRight(2, '0').substring(0, 2);

    return '$integerPart.$formattedDecimal';
  }

  List<PlutoRow> _buildRows(List<Map<String, dynamic>> reports) {
    // Calculate the total value of GrandTotal
    double totalValue = 0;
    for (var report in reports) {
      final value = report['GrandTotal'] ?? '0';
      // Remove commas from the value before parsing
      final cleanedValue = value.toString().replaceAll(',', '');

      // Debugging: Print the cleaned value being parsed
      print('Cleaned GrandTotal Value: $cleanedValue');

      try {
        totalValue += double.parse(cleanedValue);
      } catch (e) {
        // Debugging: Print an error if parsing fails
        print('Error parsing GrandTotal: $cleanedValue');
      }
    }

    // Debugging: Print the total value
    print('Total GrandTotal: $totalValue');

    // Build rows for reports
    final rows = reports.map((invoice) {
      // Ensure GrandTotal has exactly two decimal places
      final grandTotal =
          _ensureTwoDecimalPlaces(invoice['GrandTotal'].toString());

      return PlutoRow(
        cells: {
          'InvoiceDate': PlutoCell(value: invoice['InvoiceDate']),
          'InvoiceNo': PlutoCell(value: invoice['InvoiceNo']),
          'AccountName': PlutoCell(value: invoice['AccountName']),
          'GrandTotal': PlutoCell(value: grandTotal),
          'SalesManName': PlutoCell(value: invoice['SalesManName']),
          'AddUserName': PlutoCell(value: invoice['AddUserName']),
          'AddDate': PlutoCell(value: invoice['AddDate']),
          'Action': PlutoCell(value: ''),
        },
      );
    }).toList();

    // Add a footer row for the total with formatting
    final footerRow = PlutoRow(
      cells: {
        'InvoiceDate': PlutoCell(value: 'Total'),
        'InvoiceNo': PlutoCell(value: ''),
        'AccountName': PlutoCell(value: ''),
        'GrandTotal': PlutoCell(
            value: _formatNumber(
                totalValue.toStringAsFixed(2))), // Format the total value
        'SalesManName': PlutoCell(value: ''),
        'AddUserName': PlutoCell(value: ''),
        'AddDate': PlutoCell(value: ''),
        'Action': PlutoCell(value: ''),
      },
    );

    rows.add(footerRow);

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceBloc, InvoiceState>(
      builder: (context, state) {
        if (state is InvoiceInitial || state is InvoiceLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InvoiceLoaded) {
          // Define columns with the specified order and styling
          final columns = [
            PlutoColumn(
              title: 'Date',
              field: 'InvoiceDate',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left,
            ),
            PlutoColumn(
              title: 'P. Invoice No',
              field: 'InvoiceNo',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left,
            ),
            PlutoColumn(
              title: 'Party Name',
              field: 'AccountName',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left,
            ),
            PlutoColumn(
              title: 'Value',
              field: 'GrandTotal',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.right,
              renderer: (rendererContext) {
                final value = rendererContext.row.cells['GrandTotal']?.value;
                // Check if the row is the footer row
                if (rendererContext.row.cells['InvoiceDate']?.value ==
                    'Total') {
                  return Text(
                    value.toString(), // No formatting for the footer row
                    textAlign: TextAlign.right,
                  );
                } else {
                  return Text(
                    _formatNumber(value.toString()), // Format other rows
                    textAlign: TextAlign.right,
                  );
                }
              },
            ),
            PlutoColumn(
              title: 'Salesman',
              field: 'SalesManName',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left,
            ),
            PlutoColumn(
              title: 'Created By',
              field: 'AddUserName',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left,
            ),
            PlutoColumn(
              title: 'Created On',
              field: 'AddDate',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left,
            ),
            PlutoColumn(
              title: 'Action',
              field: 'Action',
              type: PlutoColumnType.text(),
              renderer: (rendererContext) {
                return Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        // Add edit functionality here
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // Add print functionality here
                      },
                      child: Text(
                        'Print',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                );
              },
            ),
          ];

          // Map invoices to rows and calculate the total value
          final rows = _buildRows(state.invoices
              .map((invoice) => {
                    'InvoiceDate': invoice.invoiceDate,
                    'InvoiceNo': invoice.invoiceNo,
                    'AccountName': invoice.accountName,
                    'GrandTotal': invoice.grandTotal,
                    'SalesManName': invoice.salesManName,
                    'AddUserName': invoice.addUserName,
                    'AddDate': invoice.addDate,
                  })
              .toList());

          return PlutoGrid(
            columns: columns,
            rows: rows,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              event.stateManager.setShowColumnFilter(true);
            },
            configuration: PlutoGridConfiguration(
              style: PlutoGridStyleConfig(
                cellTextStyle: TextStyle(color: Colors.black),
                columnTextStyle: TextStyle(color: Colors.black),
                gridBackgroundColor: Colors.white,
              ),
            ),
          );
        } else if (state is InvoiceError) {
          return Center(child: Text(state.errorMessage));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
