import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'invoice bloc.dart';

class InvoiceList extends StatelessWidget {
  const InvoiceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceBloc, InvoiceState>(
      builder: (context, state) {
        if (state is InvoiceInitial || state is InvoiceLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InvoiceLoaded) {
          // Define columns with the specified order and styling
          final columns = [
            PlutoColumn(
              title: 'Date',
              field: 'InvoiceDate',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left, // Align text to the left
            ),
            PlutoColumn(
              title: 'P. Invoice No',
              field: 'InvoiceNo',
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
              textAlign: PlutoColumnTextAlign.right, // Align text to the right
            ),
            PlutoColumn(
              title: 'Salesman',
              field: 'SalesManName',
              type: PlutoColumnType.text(),
              textAlign: PlutoColumnTextAlign.left, // Align text to the left
            ),
            PlutoColumn(
              title: 'Created By',
              field: 'AddUserName',
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

          // Map invoices to rows
          final rows = state.invoices.map((invoice) {
            return PlutoRow(
              cells: {
                'InvoiceDate': PlutoCell(value: invoice.invoiceDate),
                'InvoiceNo': PlutoCell(value: invoice.invoiceNo),
                'AccountName': PlutoCell(value: invoice.accountName),
                'GrandTotal': PlutoCell(value: invoice.grandTotal.toString()),
                'SalesManName': PlutoCell(value: invoice.salesManName),
                'AddUserName': PlutoCell(value: invoice.addUserName),
                'AddDate': PlutoCell(value: invoice.addDate),
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
              ),
            ),
          );
        } else if (state is InvoiceError) {
          return Center(child: Text(state.errorMessage));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
