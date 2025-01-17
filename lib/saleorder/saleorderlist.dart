import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart'; // Import PlutoGrid
import 'saleorderbloc.dart';

class SaleOrderList extends StatelessWidget {
  const SaleOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaleOrderBloc, SaleOrderState>(
      builder: (context, state) {
        if (state is SaleOrderLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is SaleOrderLoaded) {
          return Container(
            // padding: EdgeInsets.all(8), // Optional: Add padding
            child: PlutoGrid(
              columns: _buildColumns(), // Define columns
              rows: _buildRows(state.saleOrders), // Convert data to rows
              onLoaded: (PlutoGridOnLoadedEvent event) {
                // Optional: Handle grid load event
                event.stateManager
                    .setShowColumnFilter(true); // Enable column filters
              },
              configuration: PlutoGridConfiguration(
                columnFilter: PlutoGridColumnFilterConfig(
                  filters: const [
                    ...FilterHelper.defaultFilters,
                  ],
                ),
              ),
            ),
          );
        } else if (state is SaleOrderError) {
          return Center(child: Text(state.errorMessage));
        }
        return Center(child: Text('No data available'));
      },
    );
  }

  // Define columns for PlutoGrid
  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'Sale Order Date',
        field: 'SaleOrderDate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Sale Order No',
        field: 'SaleOrderNo',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Party Name',
        field: 'PartyName',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Value',
        field: 'Value',
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          final value = rendererContext.cell.value;
          // Remove commas from the value before parsing
          final cleanedValue = value.toString().replaceAll(',', '');
          final formattValue = cleanedValue != null
              ? double.parse(cleanedValue).toStringAsFixed(2)
              : 'N/A';
          final formattedValue = cleanedValue != null
              ? _formatNumber(formattValue.toString())
              : 'N/A';
          return Text(
            formattedValue,
            textAlign: TextAlign.right, // Ensure text is right-aligned
          );
        },
      ),
      PlutoColumn(
        title: 'Salesman',
        field: 'Salesman',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Created By',
        field: 'CreatedBy',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Created On',
        field: 'CreatedOn',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Action',
        field: 'Action',
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          return InkWell(
            onTap: () {
              // Handle button click
              final row = rendererContext.row;
              print('Selected Sale Order: ${row.cells['SaleOrderNo']?.value}');
            },
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Select',
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

  // Convert saleOrders data to PlutoRow format
  List<PlutoRow> _buildRows(List<Map<String, dynamic>> saleOrders) {
    // Calculate the total value
    double totalValue = 0;
    for (var saleOrder in saleOrders) {
      final value = saleOrder['GrandTotal'] ?? '0';
      // Remove commas from the value before parsing
      final cleanedValue = value.toString().replaceAll(',', '');
      totalValue += double.parse(cleanedValue);
    }

    // Build rows for sale orders
    final rows = saleOrders.map((saleOrder) {
      final value = saleOrder['GrandTotal'] ?? 'N/A';
      // Remove commas from the value before parsing
      final cleanedValue = value.toString().replaceAll(',', '');
      return PlutoRow(
        cells: {
          'SaleOrderDate': PlutoCell(value: saleOrder['PostingDate'] ?? 'N/A'),
          'SaleOrderNo': PlutoCell(value: saleOrder['SaleOrderNo'] ?? 'N/A'),
          'PartyName': PlutoCell(value: saleOrder['AccountName'] ?? 'N/A'),
          'Value': PlutoCell(value: cleanedValue), // Use cleaned value
          'Salesman': PlutoCell(value: saleOrder['SalesManName'] ?? 'N/A'),
          'CreatedBy': PlutoCell(value: saleOrder['CreatedBy'] ?? 'N/A'),
          'CreatedOn': PlutoCell(value: saleOrder['AddDate'] ?? 'N/A'),
          'Action': PlutoCell(value: 'Select'), // Placeholder for action button
        },
      );
    }).toList();

    // Add a footer row for the total value
    rows.add(
      PlutoRow(
        cells: {
          'SaleOrderDate': PlutoCell(value: 'Total'),
          'SaleOrderNo': PlutoCell(value: ''),
          'PartyName': PlutoCell(value: ''),
          'Value':
              PlutoCell(value: _formatNumber(totalValue.toStringAsFixed(2))),
          'Salesman': PlutoCell(value: ''),
          'CreatedBy': PlutoCell(value: ''),
          'CreatedOn': PlutoCell(value: ''),
          'Action': PlutoCell(value: ''),
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
}
