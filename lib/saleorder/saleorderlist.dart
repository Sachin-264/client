import 'package:client/saleorder/saleorderbloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';

class SaleOrderList extends StatelessWidget {
  const SaleOrderList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaleOrderBloc, SaleOrderState>(
      builder: (context, state) {
        if (state is SaleOrderInitial || state is SaleOrderLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SaleOrderLoaded) {
          // Define columns with the specified order and styling
          final columns = [
            PlutoColumn(
              title: 'Sale Order Date',
              field: 'PostingDate',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left, // Align text to the left
            ),
            PlutoColumn(
              title: 'Sale Order No',
              field: 'SaleOrderNo',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left, // Align text to the left
            ),
            PlutoColumn(
              title: 'Party Name',
              field: 'AccountName',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left, // Align text to the left
            ),
            PlutoColumn(
              title: 'Value',
              field: 'GrandTotal',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.right, // Align text to the left
            ),
            PlutoColumn(
              title: 'Salesman',
              field: 'SalesManName',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left, // Align text to the left
            ),
            PlutoColumn(
              title: 'Created By',
              field: 'CreatedBy',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left, // Align text to the left
            ),
            PlutoColumn(
              title: 'Created On',
              field: 'AddDate',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left, // Align text to the left
            ),
            PlutoColumn(
              title: 'Action',
              field: 'Action',
              type: PlutoColumnType.text(),
              renderer: (rendererContext) {
                return Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        // Add edit functionality here
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    SizedBox(width: 8), // Add spacing between buttons
                    TextButton(
                      onPressed: () {
                        // Add print functionality here
                      },
                      child: Text(
                        'Print',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                );
              },
            ),
          ];

          // Map sale orders to rows
          final rows = state.saleOrders.map((saleOrder) {
            return PlutoRow(
              cells: {
                'PostingDate': PlutoCell(value: saleOrder.postingDate),
                'SaleOrderNo': PlutoCell(value: saleOrder.saleOrderNo),
                'AccountName': PlutoCell(value: saleOrder.accountName),
                'GrandTotal': PlutoCell(value: saleOrder.grandTotal.toString()),
                'SalesManName': PlutoCell(value: saleOrder.salesManName),
                'CreatedBy': PlutoCell(value: saleOrder.createdBy),
                'AddDate': PlutoCell(value: saleOrder.addDate),
                'Action': PlutoCell(value: ''), // Empty value for action column
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
              style: PlutoGridStyleConfig(
                cellTextStyle: TextStyle(color: Colors.black),
                columnTextStyle: TextStyle(color: Colors.black),
                gridBackgroundColor: Colors.white,
                // Set header background color using enableColumnBorder

              ),
            ),
          );
        } else if (state is SaleOrderError) {
          return Center(child: Text(state.errorMessage));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}