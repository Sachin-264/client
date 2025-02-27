import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'orderAllocation_bloc.dart';
import 'orderAllocation_model.dart';

class orderAllocationList extends StatelessWidget {
  const orderAllocationList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<orderAllocationBloc, orderAllocationState>(
      builder: (context, state) {
        if (state is orderAllocationLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is orderAllocationLoaded) {
          return Container(
            child: PlutoGrid(
              columns: _buildColumns(),
              rows: _buildRows(state.orderAllocations),
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
        } else if (state is orderAllocationError) {
          return Center(child: Text(state.errorMessage));
        }
        return Center(child: Text('No data available'));
      },
    );
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(title: 'Sale Order No', field: 'OrderNo', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Sale Order Date', field: 'OrderDate', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Customer Name', field: 'Customer', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Item Code', field: 'ItemCode', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Item Name', field: 'ItemName', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Closing Stock', field: 'ClosingStock', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Order Qty', field: 'OrderQty', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Order Rate', field: 'OrderRate', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Item Value', field: 'ItemValue', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Stock Allocated On', field: 'AllocatedOn', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Qty Allocated', field: 'QtyAllocated', type: PlutoColumnType.number()),
      PlutoColumn(title: 'Dispatch Qty', field: 'DispatchQty', type: PlutoColumnType.number()),
      PlutoColumn(
        title: 'Balance Qty to Dispatch',
        field: 'BalanceQtyToDispatch',
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          final qty = rendererContext.row.cells['OrderQty']?.value ?? 0;
          final dispatchQty = rendererContext.row.cells['DispatchQty']?.value ?? 0;
          final balance = qty - dispatchQty;
          return Text(balance.toStringAsFixed(2));
        },
      ),
      PlutoColumn(
        title: 'Balance Qty to Mfg',
        field: 'BalanceQtyToMfg',
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          final qty = rendererContext.row.cells['OrderQty']?.value ?? 0;
          final qtyAllocated = rendererContext.row.cells['QtyAllocated']?.value ?? 0;
          final dispatchQty = rendererContext.row.cells['DispatchQty']?.value ?? 0;
          final balance = qty - qtyAllocated - dispatchQty;
          return Text(balance.toStringAsFixed(2));
        },
      ),
    ];
  }

  List<PlutoRow> _buildRows(List<orderAllocation> orderAllocations) {
    double totalQty = 0;
    double totalValue = 0;
    double totalDispatchQty = 0;
    double totalQtyAllocated = 0;
    double totalBalanceQtyToDispatch = 0;
    double totalBalanceQtyToMfg = 0;

    final rows = orderAllocations.map((order) {
      final qty = double.tryParse(order.qty) ?? 0.0;
      final qtyAllocated = double.tryParse(order.qtyAllocated) ?? 0.0;
      final dispatchQty = order.dispatchValue / order.netRate;

      totalQty += qty;
      totalValue += order.value;
      totalDispatchQty += dispatchQty;
      totalQtyAllocated += qtyAllocated;
      totalBalanceQtyToDispatch += (qty - dispatchQty);
      totalBalanceQtyToMfg += (qty - qtyAllocated - dispatchQty);

      return PlutoRow(
        cells: {
          'OrderNo': PlutoCell(value: order.orderNo),
          'OrderDate': PlutoCell(value: order.orderDate),
          'Customer': PlutoCell(value: order.accountName),
          'ItemCode': PlutoCell(value: order.itemCode ?? ''), // Placeholder, defaults to empty
          'ItemName': PlutoCell(value: order.itemName),
          'ClosingStock': PlutoCell(value: order.closingStock ?? ''), // Placeholder, defaults to empty
          'OrderQty': PlutoCell(value: qty),
          'OrderRate': PlutoCell(value: order.netRate),
          'ItemValue': PlutoCell(value: order.value),
          'AllocatedOn': PlutoCell(value: order.allocatedOn),
          'QtyAllocated': PlutoCell(value: qtyAllocated),
          'DispatchQty': PlutoCell(value: dispatchQty),
          'BalanceQtyToDispatch': PlutoCell(value: qty - dispatchQty),
          'BalanceQtyToMfg': PlutoCell(value: qty - qtyAllocated - dispatchQty),
        },
      );
    }).toList();

    rows.add(
      PlutoRow(
        cells: {
          'OrderNo': PlutoCell(value: 'Total'),
          'OrderDate': PlutoCell(value: ''),
          'Customer': PlutoCell(value: ''),
          'ItemCode': PlutoCell(value: ''),
          'ItemName': PlutoCell(value: ''),
          'ClosingStock': PlutoCell(value: ''),
          'OrderQty': PlutoCell(value: totalQty),
          'OrderRate': PlutoCell(value: ''), // Empty string instead of 0
          'ItemValue': PlutoCell(value: totalValue),
          'AllocatedOn': PlutoCell(value: ''),
          'QtyAllocated': PlutoCell(value: totalQtyAllocated),
          'DispatchQty': PlutoCell(value: totalDispatchQty),
          'BalanceQtyToDispatch': PlutoCell(value: totalBalanceQtyToDispatch),
          'BalanceQtyToMfg': PlutoCell(value: totalBalanceQtyToMfg),
        },
      ),
    );

    return rows;
  }
}