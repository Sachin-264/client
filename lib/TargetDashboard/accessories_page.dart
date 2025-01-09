import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'accessories_bloc.dart'; // Import the ItemBloc

class ItemPage extends StatelessWidget {
  final String fromDate;
  final String toDate;
  final String salesmanId;

  const ItemPage({
    required this.fromDate,
    required this.toDate,
    required this.salesmanId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemBloc()
        ..add(FetchItemData(
          fromDate: fromDate,
          toDate: toDate,
          salesmanId: salesmanId,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ItemWise Report',
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
        body: BlocBuilder<ItemBloc, ItemState>(
          builder: (context, state) {
            if (state is ItemLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ItemError) {
              return Center(child: Text(state.message));
            } else if (state is ItemLoaded) {
              final data = state.data;

              // Define PlutoGrid columns
              final columns = [
                PlutoColumn(
                  title: 'Item Group Name',
                  field: 'ItemGroupName',
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
                // PlutoColumn(
                //   title: 'Action',
                //   field: 'Action',
                //   type: PlutoColumnType.text(),
                //   renderer: (rendererContext) {
                //     return TextButton(
                //       onPressed: () {
                //         // Handle the "Select" button click
                //         final row = rendererContext.row;
                //         print('Selected Row: ${row.cells}');
                //       },
                //       child: Text(
                //         'Select',
                //         style: TextStyle(color: Colors.blue), // Make text blue
                //       ),
                //     );
                //   },
                // ),
              ];

              // Calculate totals
              double totalTargetValue = 0;
              double totalSaleValue = 0;
              double totalValuePer = 0;

              // Prepare PlutoGrid rows
              final rows = data.map((item) {
                final targetValue = double.tryParse(item['TargeValue'] ?? '0') ?? 0;
                final saleValue = double.tryParse(item['SaleValue'] ?? '0') ?? 0;
                final valuePer = double.tryParse(item['ValuePer'] ?? '0') ?? 0;

                // Add to totals
                totalTargetValue += targetValue;
                totalSaleValue += saleValue;
                totalValuePer += valuePer;

                return PlutoRow(
                  cells: {
                    'ItemGroupName': PlutoCell(value: item['ItemGroupName'] ?? 'N/A'),
                    'TargeValue': PlutoCell(value: _formatNumber(targetValue.toString())),
                    'SaleValue': PlutoCell(value: _formatNumber(saleValue.toString())),
                    'ValuePer': PlutoCell(value: valuePer),
                    'Action': PlutoCell(value: 'Select'), // This value is not used due to custom renderer
                  },
                );
              }).toList();

              // Add a last row for totals
              rows.add(
                PlutoRow(
                  cells: {
                    'ItemGroupName': PlutoCell(value: 'Total'),
                    'TargeValue': PlutoCell(value: _formatNumber(totalTargetValue.toString())),
                    'SaleValue': PlutoCell(value: _formatNumber(totalSaleValue.toString())),
                    'ValuePer': PlutoCell(value: _formatNumber(totalValuePer.toString())),
                    'Action': PlutoCell(value: ''),
                  },
                ),
              );

              return PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  event.stateManager.setShowColumnFilter(true); // Enable filtering
                },
                onChanged: (PlutoGridOnChangedEvent event) {
                  print(event);
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