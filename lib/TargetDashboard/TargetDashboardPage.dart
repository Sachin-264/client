import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:client/TargetDashboard/targetDashboardBloc.dart';
import 'Targetsalepage.dart'; // Import the TargetSalePage

class TargetDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Target Dashboard For the Month Of Jan-2025',
          style: TextStyle(
            color: Colors.white, // White color for text
          ),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Remove default back button
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Navigate back
            },
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.white), // Blue back icon
                SizedBox(width: 4), // Add spacing between icon and text
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white, // Blue color for text
                    fontSize: 16, // Adjust font size
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => TargetDashboardBloc()..add(FetchTargetDashboard()),
        child: BlocBuilder<TargetDashboardBloc, TargetDashboardState>(
          builder: (context, state) {
            if (state is TargetDashboardLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TargetDashboardError) {
              return Center(child: Text(state.message));
            } else if (state is TargetDashboardLoaded) {
              // Define PlutoGrid columns
              final columns = [
                PlutoColumn(
                  title: 'Name',
                  field: 'SalesManName',
                  type: PlutoColumnType.text(),
                ),
                PlutoColumn(
                  title: 'Designation',
                  field: 'SalesManDesignation',
                  type: PlutoColumnType.text(),
                ),
                PlutoColumn(
                  title: '% Achieved',
                  field: 'ValuePer',
                  type: PlutoColumnType.text(),
                  textAlign: PlutoColumnTextAlign.right,
                ),
                PlutoColumn(
                  title: 'Action',
                  field: 'Action',
                  type: PlutoColumnType.text(),
                  renderer: (rendererContext) {
                    return TextButton(
                      onPressed: () {
                        // Navigate to TargetSalePage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TargetSalePage(),
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

              // Prepare PlutoGrid rows, skipping rows where SalesManName is missing or empty
              final rows = state.data.where((item) => item['SalesManName'] != null && item['SalesManName'].toString().isNotEmpty).map((item) {
                return PlutoRow(
                  cells: {
                    'SalesManName': PlutoCell(value: item['SalesManName'] ?? 'N/A'),
                    'SalesManDesignation': PlutoCell(value: item['SalesManDesignation'] ?? 'N/A'),
                    'ValuePer': PlutoCell(value: '${item['ValuePer'] ?? '0.00'}%'),
                    'Action': PlutoCell(value: 'Select'), // This value is not used due to custom renderer
                  },
                );
              }).toList();

              return PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  event.stateManager.setShowColumnFilter(true); // Enable filtering
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
}