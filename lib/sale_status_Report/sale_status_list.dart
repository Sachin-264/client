import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart'; // Import PlutoGrid
import 'sale_status_bloc.dart';
import 'sale_model.dart';

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
              rows: _buildRows(state.saleOrders),
              onLoaded: (PlutoGridOnLoadedEvent event) {
                event.stateManager.setShowColumnFilter(true);
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
        title: 'ORDER NO',
        field: 'OrderNo',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'ORDER DATE',
        field: 'OrderDate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'SALES MANAGER',
        field: 'SalesManager',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'SALES MAN NAME',
        field: 'SalesManName',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'ORDER STATUS',
        field: 'OrderStatus',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'CUSTOMER',
        field: 'Customer',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'CUSTOMER PO NO',
        field: 'CustomerPONo',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'CUSTOMER PO DATE',
        field: 'CustomerPODate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'DEL DATE',
        field: 'DeliveryDate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'LD',
        field: 'LD',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'LD%',
        field: 'LDPercentage',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'ITEM NAME',
        field: 'ItemName',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'QTY',
        field: 'Qty',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'VALUE',
        field: 'Value',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'SALES ORDER VALUE',
        field: 'SalesOrderValue',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'DISPATCH VALUE',
        field: 'DispatchValue',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'BALANCE',
        field: 'Balance',
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          final salesOrderValue = rendererContext.row.cells['SalesOrderValue']?.value ?? 0;
          final dispatchValue = rendererContext.row.cells['DispatchValue']?.value ?? 0;
          final balance = salesOrderValue - dispatchValue;
          return Text(
            balance.toStringAsFixed(2),
            textAlign: TextAlign.right,
          );
        },
      ),
      PlutoColumn(
        title: 'EVA',
        field: 'EVA',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'ESM',
        field: 'ESM',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'AVA',
        field: 'AVA',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'ASM',
        field: 'ASM',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'AVA-EVA',
        field: 'AVA_EVA',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'ASM-ESM',
        field: 'ASM_ESM',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'QUOTATION NO',
        field: 'Quotation',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'INQ NO',
        field: 'InqNo',
        type: PlutoColumnType.text(),
      ),
    ];
  }

  // Convert saleOrders data to PlutoRow format
  List<PlutoRow> _buildRows(List<SaleOrder> saleOrders) {
    // Initialize totals for the required columns
    double totalValue = 0;
    double totalSalesOrderValue = 0;
    double totalDispatchValue = 0;
    double totalBalance = 0;
    double totalQty = 0; // Add total for Qty

    // Build rows for sale orders
    final rows = saleOrders.map((saleOrder) {
      // Parse Qty to double
      final qty = double.tryParse(saleOrder.qty) ?? 0.0;

      // Calculate totals
      totalValue += saleOrder.value;
      totalSalesOrderValue += saleOrder.grandTotal;
      totalDispatchValue += saleOrder.dispatchValue;
      totalBalance += (saleOrder.grandTotal - saleOrder.dispatchValue);
      totalQty += qty; // Add to total Qty

      return PlutoRow(
        cells: {
          'OrderNo': PlutoCell(value: saleOrder.orderNo),
          'OrderDate': PlutoCell(value: saleOrder.orderDate),
          'SalesManager': PlutoCell(value: saleOrder.saleManager),
          'SalesManName': PlutoCell(value: saleOrder.salesManName),
          'OrderStatus': PlutoCell(value: saleOrder.resultStatus),
          'Customer': PlutoCell(value: saleOrder.accountName),
          'CustomerPONo': PlutoCell(value: saleOrder.customerPONo),
          'CustomerPODate': PlutoCell(value: saleOrder.customerPODate),
          'DeliveryDate': PlutoCell(value: saleOrder.deliveryDate),
          'LD': PlutoCell(value: saleOrder.ldyn),
          'LDPercentage': PlutoCell(value: saleOrder.ldPer),
          'ItemName': PlutoCell(value: saleOrder.itemName),
          'Qty': PlutoCell(value: qty), // Use parsed Qty
          'Value': PlutoCell(value: saleOrder.value),
          'SalesOrderValue': PlutoCell(value: saleOrder.grandTotal),
          'DispatchValue': PlutoCell(value: saleOrder.dispatchValue),
          'Balance': PlutoCell(value: saleOrder.grandTotal - saleOrder.dispatchValue),
          'EVA': PlutoCell(value: saleOrder.eva),
          'ESM': PlutoCell(value: saleOrder.esm),
          'AVA': PlutoCell(value: saleOrder.ava),
          'ASM': PlutoCell(value: saleOrder.asm),
          'AVA_EVA': PlutoCell(value: ''), // Placeholder for AVA-EVA
          'ASM_ESM': PlutoCell(value: ''), // Placeholder for ASM-ESM
          'Quotation': PlutoCell(value: saleOrder.quotationNo),
          'InqNo': PlutoCell(value: saleOrder.inquiryNo),
        },
      );
    }).toList();

    // Add a footer row for totals
    rows.add(
      PlutoRow(
        cells: {
          'OrderNo': PlutoCell(value: 'Total'),
          'OrderDate': PlutoCell(value: ''),
          'SalesManager': PlutoCell(value: ''),
          'SalesManName': PlutoCell(value: ''),
          'OrderStatus': PlutoCell(value: ''),
          'Customer': PlutoCell(value: ''),
          'CustomerPONo': PlutoCell(value: ''),
          'CustomerPODate': PlutoCell(value: ''),
          'DeliveryDate': PlutoCell(value: ''),
          'LD': PlutoCell(value: ''),
          'LDPercentage': PlutoCell(value: ''),
          'ItemName': PlutoCell(value: ''),
          'Qty': PlutoCell(value: totalQty), // Total Qty
          'Value': PlutoCell(value: totalValue),
          'SalesOrderValue': PlutoCell(value: totalSalesOrderValue),
          'DispatchValue': PlutoCell(value: totalDispatchValue),
          'Balance': PlutoCell(value: totalBalance),
          'EVA': PlutoCell(value: ''),
          'ESM': PlutoCell(value: ''),
          'AVA': PlutoCell(value: ''),
          'ASM': PlutoCell(value: ''),
          'AVA_EVA': PlutoCell(value: ''),
          'ASM_ESM': PlutoCell(value: ''),
          'Quotation': PlutoCell(value: ''),
          'InqNo': PlutoCell(value: ''),
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
