import 'package:client/PPS%20report/PPSreportbloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PpsReportPage extends StatelessWidget {
  final Map<String, String> filters;

  PpsReportPage({Key? key, required this.filters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PpsReportBloc()..add(FetchPpsReport(filters: filters)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'PDS Reports',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: PpsReportGrid(),
      ),
    );
  }
}

class PpsReportGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PpsReportBloc, PpsReportState>(
      builder: (context, state) {
        if (state is PpsReportLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is PpsReportError) {
          return Center(child: Text(state.message));
        } else if (state is PpsReportLoaded) {
          return PlutoGrid(
            columns: _buildColumns(),
            rows: _buildRows(state.reports),
            configuration: PlutoGridConfiguration(
              // style: PlutoGridStyleConfig(
              //   gridBorderColor: Colors.grey,
              //   gridBackgroundColor: Colors.white,
              // ),
              columnFilter: PlutoGridColumnFilterConfig(
                filters: const [
                  ...FilterHelper
                      .defaultFilters, // Default filters (text, number, etc.)
                ],
              ),
            ),
            onLoaded: (PlutoGridOnLoadedEvent event) {
              // Enable column filtering
              event.stateManager.setShowColumnFilter(true);
            },
          );
        }
        return Center(child: Text('No data available'));
      },
    );
  }

  // Define columns for PlutoGrid
  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'S.No.',
        field: 'sno',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Sale Order No',
        field: 'saleOrderNo',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Sale Order Date',
        field: 'saleOrderDate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Customer Name',
        field: 'customerName',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Delivery Date',
        field: 'deliveryDate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Desired Date',
        field: 'desiredDate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS1 Date',
        field: 'pds1Date',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Employee Name 1',
        field: 'employeeName1',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS1 Remarks',
        field: 'pds1Remarks',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS2 Date',
        field: 'pds2Date',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Employee Name 2',
        field: 'employeeName2',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS2 Remarks',
        field: 'pds2Remarks',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS3 Date',
        field: 'pds3Date',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Employee Name 3',
        field: 'employeeName3',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'PDS3 Remarks',
        field: 'pds3Remarks',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          return InkWell(
            onTap: () {
              // Handle button click
              final row = rendererContext.row;
              print('Selected Sale Order: ${row.cells['saleOrderNo']?.value}');
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
      PlutoColumn(
        title: 'Salesman Name',
        field: 'salesmanName',
        type: PlutoColumnType.text(),
      ),
    ];
  }

  // Convert API data to PlutoRow format
  List<PlutoRow> _buildRows(List<Map<String, dynamic>> reports) {
    return reports.asMap().entries.map((entry) {
      final index = entry.key;
      final report = entry.value;
      return PlutoRow(
        cells: {
          'sno': PlutoCell(value: (index + 1).toString()),
          'saleOrderNo': PlutoCell(value: report['SaleOrderNo'] ?? 'N/A'),
          'saleOrderDate': PlutoCell(value: report['AddDate'] ?? 'N/A'),
          'customerName': PlutoCell(value: report['AccountName'] ?? 'N/A'),
          'deliveryDate': PlutoCell(value: report['DeliveryDate'] ?? 'N/A'),
          'desiredDate': PlutoCell(value: report['DesiredDate'] ?? 'N/A'),
          'pds1Date': PlutoCell(value: report['PDS1Date'] ?? 'N/A'),
          'employeeName1': PlutoCell(value: report['EmployeeName1'] ?? 'N/A'),
          'pds1Remarks': PlutoCell(value: report['PDS1Remarks'] ?? 'N/A'),
          'pds2Date': PlutoCell(value: report['PDS2Date'] ?? 'N/A'),
          'employeeName2': PlutoCell(value: report['EmployeeName2'] ?? 'N/A'),
          'pds2Remarks': PlutoCell(value: report['PDS2Remarks'] ?? 'N/A'),
          'pds3Date': PlutoCell(value: report['PDS3Date'] ?? 'N/A'),
          'employeeName3': PlutoCell(value: report['EmployeeName3'] ?? 'N/A'),
          'pds3Remarks': PlutoCell(value: report['PDS3Remarks'] ?? 'N/A'),
          'status': PlutoCell(value: 'Select'),
          'salesmanName': PlutoCell(value: report['SalesManName'] ?? 'N/A'),
        },
      );
    }).toList();
  }
}
