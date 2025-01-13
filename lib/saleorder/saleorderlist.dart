import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart'; // Import PlutoGrid
import 'saleorderbloc.dart';

class SaleOrderList extends StatelessWidget {
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
    return saleOrders.map((saleOrder) {
      return PlutoRow(
        cells: {
          'SaleOrderDate': PlutoCell(value: saleOrder['PostingDate'] ?? 'N/A'),
          'SaleOrderNo': PlutoCell(value: saleOrder['SaleOrderNo'] ?? 'N/A'),
          'PartyName': PlutoCell(value: saleOrder['AccountName'] ?? 'N/A'),
          'Value': PlutoCell(value: saleOrder['GrandTotal'] ?? 'N/A'),
          'Salesman': PlutoCell(value: saleOrder['SalesManName'] ?? 'N/A'),
          'CreatedBy': PlutoCell(value: saleOrder['CreatedBy'] ?? 'N/A'),
          'CreatedOn': PlutoCell(value: saleOrder['AddDate'] ?? 'N/A'),
          'Action': PlutoCell(value: 'Select'), // Placeholder for action button
        },
      );
    }).toList();
  }
}
