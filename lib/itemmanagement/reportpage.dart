import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart'; // Ensure this import is correct
import 'report_bloc.dart';

class ReportPage extends StatelessWidget {
  final String itemCode;
  final String quantity;

  const ReportPage({required this.itemCode, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: Colors.blue,
      ),
      body: BlocProvider(
        create: (context) => ReportBloc()..add(FetchReport(itemCode: itemCode, quantity: quantity)),
        child: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            if (state is ReportLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ReportError) {
              return Center(child: Text(state.message));
            } else if (state is ReportLoaded) {
              return _buildPlutoGrid(state.reportData);
            }
            return const Center(child: Text('No data available'));
          },
        ),
      ),
    );
  }

  Widget _buildPlutoGrid(List<Map<String, dynamic>> reportData) {
    final columns = _buildColumns();
    final rows = _buildRows(reportData);

    return PlutoGrid(
      columns: columns,
      rows: rows,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        event.stateManager.setShowColumnFilter(true); // Enable filtering
      },
      configuration: const PlutoGridConfiguration(
        columnSize: PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
        ),
      ),
    );
  }

  List<PlutoColumn> _buildColumns() {
    return [
      // PlutoColumn(
      //   title: 'View Level',
      //   field: 'ViewLevel',
      //   type: PlutoColumnType.text(),
      // ),
      PlutoColumn(
        title: 'Item Name',
        field: 'ItemName',
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          final cell = rendererContext.cell;
          final row = rendererContext.row;
          final valuePer = row.cells['ValuePer']?.value;

          // Determine padding based on ValuePer
          final padding = valuePer == 1 ? const EdgeInsets.all(8.0) : EdgeInsets.zero;

          // Determine if ItemName should be bold
          final isBold = valuePer == 0;

          return Padding(
            padding: padding,
            child: Text(
              cell.value.toString(),
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Our Item No',
        field: 'OurItemNo',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Qty',
        field: 'Qty',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Unit Name',
        field: 'UnitName',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Item Remarks',
        field: 'ItemRemarks',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Item File Name',
        field: 'ItemFileName',
        type: PlutoColumnType.text(),
      ),
    ];
  }

  List<PlutoRow> _buildRows(List<Map<String, dynamic>> reportData) {
    return reportData.map((data) {
      return PlutoRow(
        cells: {
          'ViewLevel': PlutoCell(value: data['ViewLevel']),
          'ItemName': PlutoCell(value: data['ItemName']),
          'OurItemNo': PlutoCell(value: data['OurItemNo']),
          'Qty': PlutoCell(value: data['Qty']),
          'UnitName': PlutoCell(value: data['UnitName']),
          'ItemRemarks': PlutoCell(value: data['ItemRemarks']),
          'ItemFileName': PlutoCell(value: data['ItemFileName']),
          'ValuePer': PlutoCell(value: data['ValuePer']), // Ensure this field exists in your data
        },
      );
    }).toList();
  }
}