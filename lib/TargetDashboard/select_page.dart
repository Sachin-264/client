import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'accessories_page.dart'; // Import your ItemPage
import 'selectpage_bloc.dart'; // Import your SelectPageBloc

class SelectPage extends StatelessWidget {
  final String fromDate;
  final String toDate;
  final String salesmanRecNo;

  const SelectPage({
    required this.fromDate,
    required this.toDate,
    required this.salesmanRecNo,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectPageBloc()
        ..add(FetchSalesManData(fromDate: fromDate, toDate: toDate)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '',
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
                  Icon(Icons.arrow_back_ios, color: Colors.white), // Blue back icon
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
        body: BlocBuilder<SelectPageBloc, SelectPageState>(
          builder: (context, state) {
            if (state is SalesManDataLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is SalesManDataError) {
              return Center(child: Text(state.message));
            } else if (state is SalesManDataLoaded) {
              final data = state.data;

              // Define PlutoGrid columns
              final columns = [
                PlutoColumn(
                  title: 'Executive Name',
                  field: 'SalesManName',
                  type: PlutoColumnType.text(),
                  renderer: (rendererContext) {
                    // Get the ViewLevel value from the row
                    final viewLevelStr = rendererContext.row.cells['ViewLevel']?.value.toString() ?? '0';
                    // Convert ViewLevel to an integer (default to 0 if conversion fails)
                    final viewLevel = int.tryParse(viewLevelStr) ?? 0;
                    // Calculate padding based on ViewLevel
                    final padding = EdgeInsets.only(left: 16.0 * viewLevel);

                    return Padding(
                      padding: padding,
                      child: Text(
                        rendererContext.row.cells['SalesManName']?.value.toString() ?? 'N/A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Optional: Add styling
                        ),
                      ),
                    );
                  },
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
                        // Navigate to the ItemPage with the selected salesman data
                        print("Accessing data");
                        print("From Date: $fromDate");
                        print("To Date: $toDate");
                        print("Salesman ID: $salesmanRecNo");

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemPage(
                              fromDate: fromDate,
                              toDate: toDate,
                              salesmanId: '157.0',
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

              // Prepare PlutoGrid rows
              final rows = data.map((item) {
                final targetValue = _formatNumber(item['TargeValue'] ?? '0');
                final saleValue = _formatNumber(item['SaleValue'] ?? '0');
                final valuePer = item['ValuePer'] ?? '0';

                return PlutoRow(
                  cells: {
                    'SalesManName': PlutoCell(value: item['SalesManName'] ?? 'N/A'),
                    'HQName': PlutoCell(value: item['HQName'] ?? 'N/A'),
                    'SalesManDesignation': PlutoCell(value: item['SalesManDesignation'] ?? 'N/A'),
                    'TargeValue': PlutoCell(value: targetValue),
                    'SaleValue': PlutoCell(value: saleValue),
                    'ValuePer': PlutoCell(value: valuePer),
                    'ViewLevel': PlutoCell(value: item['ViewLevel'] ?? '0'), // Add ViewLevel to the row
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