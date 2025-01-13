import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'accessories_page.dart'; // Import your ItemPage
import 'selectpage_bloc.dart'; // Import your SelectPageBloc

class SelectPage extends StatelessWidget {
  final String fromDate;
  final String toDate;

  const SelectPage({
    required this.fromDate,
    required this.toDate,
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
              color: Colors.white,
            ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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

              final filteredData = data.where((item) {
                final targetValue = double.tryParse(item['TargeValue'] ?? '0') ?? 0;
                final saleValue = double.tryParse(item['SaleValue'] ?? '0') ?? 0;
                return targetValue != 0 || saleValue != 0;
              }).toList();

              final columns = [
                PlutoColumn(
                  title: 'Executive Name',
                  field: 'SalesManName',
                  type: PlutoColumnType.text(),
                  renderer: (rendererContext) {
                    final viewLevelStr = rendererContext.row.cells['ViewLevel']?.value.toString() ?? '0';
                    final viewLevel = int.tryParse(viewLevelStr) ?? 0;
                    final padding = EdgeInsets.only(left: 16.0 * viewLevel);

                    return Padding(
                      padding: padding,
                      child: Text(
                        rendererContext.row.cells['SalesManName']?.value.toString() ?? 'N/A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
                    final value = rendererContext.cell.value.toString();
                    return Text(
                      '$value%',
                      textAlign: TextAlign.right,
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
                        final salesmanRecNo = rendererContext.row.cells['SalesManRecNo']?.value.toString() ?? '0';
                        print(salesmanRecNo);
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

              final rows = filteredData.map((item) {
                final formattedTargetValue = _formatValuePer(item['TargeValue'] ?? '0');
                final formattedSaleValue = _formatValuePer(item['SaleValue'] ?? '0');
                final formattedValuePer = _formatValuePer(item['ValuePer'] ?? '0');

                final targetValue = _formatNumber(formattedTargetValue);
                final saleValue = _formatNumber(formattedSaleValue);
                final valuePer = _formatNumber(formattedValuePer);

                return PlutoRow(
                  cells: {
                    'SalesManName': PlutoCell(value: item['SalesManName'] ?? 'N/A'),
                    'HQName': PlutoCell(value: item['HQName'] ?? 'N/A'),
                    'SalesManDesignation': PlutoCell(value: item['SalesManDesignation'] ?? 'N/A'),
                    'TargeValue': PlutoCell(value: targetValue),
                    'SaleValue': PlutoCell(value: saleValue),
                    'ValuePer': PlutoCell(value: valuePer),
                    'ViewLevel': PlutoCell(value: item['ViewLevel'] ?? '0'),
                    'SalesManRecNo': PlutoCell(value: item['SalesManRecNo'] ?? '0'), // Add SalesManRecNo to the row
                    'Action': PlutoCell(value: 'Select'),
                  },
                );
              }).toList();

              return PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  event.stateManager.setShowColumnFilter(true);
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

  String _formatNumber(String number) {
    final parts = number.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final isNegative = integerPart.startsWith('-');
    final digits = isNegative ? integerPart.substring(1) : integerPart;

    final buffer = StringBuffer();
    int count = 0;

    for (int i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;

      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      } else if (count == 2 && i != 0 && buffer.toString().contains(',')) {
        buffer.write(',');
        count = 0;
      }
    }

    final reversed = buffer.toString().split('').reversed.join();
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