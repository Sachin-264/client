import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:client/TargetDashboard/select_page.dart';
import 'package:client/TargetDashboard/targetsale&viewallbloc.dart';

class ViewAllPage extends StatelessWidget {
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
              // Filter data up to the present month
              final now = DateTime.now();
              final filteredData = state.data.where((item) {
                final fromDate = _parseDate(item['FromDate']);
                return fromDate.isBefore(now) || fromDate.month == now.month;
              }).toList();

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
              final rows = filteredData.map((item) {
                final month = _getMonthKeyFromDate(item['FromDate'] ?? 'N/A');
                final targetValue = _formatNumber(item['TargetValue'] ?? '0');
                final saleValue = _formatNumber(item['SaleValue'] ?? '0');
                final valuePer = item['ValuePer'] ?? '0';

                return PlutoRow(
                  cells: {
                    'Month': PlutoCell(value: month),
                    'TargetValue': PlutoCell(value: targetValue),
                    'SaleValue': PlutoCell(value: saleValue),
                    'ValuePer': PlutoCell(value: valuePer),
                    'Action': PlutoCell(value: 'Select'), // This value is not used due to custom renderer
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
            return Container();
          },
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
    final fromDate = cells['Month']?.value.toString() ?? '01-Apr-2024';
    final toDate = '30-${fromDate.split('-')[0]}-${fromDate.split('-')[1]}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectPage(fromDate: fromDate, toDate: toDate),
      ),
    );
  }

  // Helper method to format numbers with commas every two digits
  String _formatNumber(String number) {
    final parts = number.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Add commas to the integer part
    final buffer = StringBuffer();
    int count = 0;

    // Start from the end of the integer part
    for (int i = integerPart.length - 1; i >= 0; i--) {
      buffer.write(integerPart[i]);
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
    return '$reversed$decimalPart';
  }
}