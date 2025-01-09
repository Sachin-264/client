import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'accessories_page.dart'; // Import your ItemPage
import 'selectpage_bloc.dart'; // Import your SelectPageBloc

class SelectPage extends StatelessWidget {
  final String fromDate;
  final String toDate;

  const SelectPage({required this.fromDate, required this.toDate});

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemPage(
                              fromDate: '01-Apr-2024',
                              toDate: '30-Apr-2024',
                              salesmanId: '157.0',
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