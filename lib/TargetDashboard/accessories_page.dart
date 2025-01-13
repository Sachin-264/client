import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'accessories_bloc.dart'; // Import the ItemBloc

class ItemPage extends StatelessWidget {
  final String fromDate;
  final String toDate;
  final String salesmanId;
  final String salesmanRecNo;

  const ItemPage({
    required this.fromDate,
    required this.toDate,
    required this.salesmanId,
    required this.salesmanRecNo,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemBloc()
        ..add(FetchItemData(
          fromDate: fromDate,
          toDate: toDate,
          salesmanId: salesmanId,
          salesmanRecNo: salesmanRecNo,
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

              // Print raw data for debugging
              print('Raw Data:');
              data.forEach((item) {
                print(item);
              });

              // Filter out rows where both TargetValue and SaleValue are zero
              final filteredData = data.where((item) {
                final targetValue = double.tryParse(item['TargeValue'] ?? '0') ?? 0;
                final saleValue = double.tryParse(item['SaleValue'] ?? '0') ?? 0;
                return targetValue != 0 || saleValue != 0; // Keep rows where either is not zero
              }).toList();

              // Print filtered data for debugging
              print('Filtered Data:');
              filteredData.forEach((item) {
                print(item);
              });

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
              ];

              // Calculate totals
              double totalTargetValue = 0;
              double totalSaleValue = 0;
              double totalValuePer = 0;

              // Print initial totals for debugging
              print('Initial Totals:');
              print('Total Target Value: $totalTargetValue');
              print('Total Sale Value: $totalSaleValue');
              print('Total ValuePer: $totalValuePer');

              // Prepare PlutoGrid rows
              final rows = filteredData.map((item) {
                final targetValue = double.tryParse(item['TargeValue'] ?? '0') ?? 0;
                final saleValue = double.tryParse(item['SaleValue'] ?? '0') ?? 0;
                final valuePer = double.tryParse(item['ValuePer'] ?? '0') ?? 0;

                // Print values for each row for debugging
                print('Processing Row:');
                print('ItemGroupName: ${item['ItemGroupName']}');
                print('TargetValue: $targetValue');
                print('SaleValue: $saleValue');
                print('ValuePer: $valuePer');

                // Add to totals (negative values will be subtracted automatically)
                totalTargetValue += targetValue;
                totalSaleValue += saleValue;
                totalValuePer += valuePer;

                // Print updated totals after each row for debugging
                print('Updated Totals:');
                print('Total Target Value: $totalTargetValue');
                print('Total Sale Value: $totalSaleValue');
                print('Total ValuePer: $totalValuePer');

                // Step 1: Apply _formatValuePer to handle leading zeros
                final formattedTargetValue = _formatValuePer(targetValue.toString());
                final formattedSaleValue = _formatValuePer(saleValue.toString());
                final formattedValuePer = _formatValuePer(valuePer.toString());

                // Step 2: Apply _formatNumber to format with commas
                final formattedTargetValueWithCommas = _formatNumber(formattedTargetValue);
                final formattedSaleValueWithCommas = _formatNumber(formattedSaleValue);
                final formattedValuePerWithCommas = _formatNumber(formattedValuePer);

                return PlutoRow(
                  cells: {
                    'ItemGroupName': PlutoCell(value: item['ItemGroupName'] ?? 'N/A'),
                    'TargeValue': PlutoCell(value: formattedTargetValueWithCommas), // Format TargetValue
                    'SaleValue': PlutoCell(value: formattedSaleValueWithCommas), // Format SaleValue
                    'ValuePer': PlutoCell(value: formattedValuePerWithCommas), // Format ValuePer
                  },
                );
              }).toList();

              // Print final totals for debugging
              print('Final Totals:');
              print('Total Target Value: $totalTargetValue');
              print('Total Sale Value: $totalSaleValue');
              print('Total ValuePer: $totalValuePer');

              // Step 1: Apply _formatValuePer to handle leading zeros for totals
              final formattedTotalTargetValue = _formatValuePer(totalTargetValue.toString());
              final formattedTotalSaleValue = _formatValuePer(totalSaleValue.toString());
              final formattedTotalValuePer = _formatValuePer(totalValuePer.toString());

              // Step 2: Apply _formatNumber to format totals with commas
              final formattedTotalTargetValueWithCommas = _formatNumber(formattedTotalTargetValue);
              final formattedTotalSaleValueWithCommas = _formatNumber(formattedTotalSaleValue);
              final formattedTotalValuePerWithCommas = _formatNumber(formattedTotalValuePer);

              // Add a last row for totals
              rows.add(
                PlutoRow(
                  cells: {
                    'ItemGroupName': PlutoCell(value: 'Total'),
                    'TargeValue': PlutoCell(value: formattedTotalTargetValueWithCommas),
                    'SaleValue': PlutoCell(value: formattedTotalSaleValueWithCommas),
                    'ValuePer': PlutoCell(value: formattedTotalValuePerWithCommas),
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

// Helper function to add leading zero to values like ".67" or "-.88"
  String _formatValuePer(String value) {
    if (value.startsWith('-.')) {
      return '-0${value.substring(1)}'; // Add leading zero after the negative sign
    } else if (value.startsWith('.')) {
      return '0$value'; // Add leading zero if the value starts with a dot
    }
    return value; // Return the original value if it's already formatted
  }
}