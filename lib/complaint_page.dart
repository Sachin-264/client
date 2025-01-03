import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'complaint_bloc.dart';
import 'complaint_event.dart';
import 'complaint_state.dart';
import 'complaint.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ComplaintPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaint Entry List"),
        backgroundColor: Colors.blue, // Change App Bar color to blue
      ),
      body: BlocProvider(
        create: (context) => ComplaintBloc()..add(FetchComplaints()),
        child: BlocBuilder<ComplaintBloc, ComplaintState>(
          builder: (context, state) {
            if (state is ComplaintLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ComplaintError) {
              return Center(child: Text(state.message));
            } else if (state is ComplaintLoaded) {
              // Map complaints to PlutoRow
              List<PlutoRow> rows = state.complaints.map((complaint) {
                return PlutoRow(cells: {
                  'SNo': PlutoCell(value: complaint.sNo),
                  'ComplaintNo': PlutoCell(value: complaint.complaintNo),
                  'CustomerName': PlutoCell(value: complaint.accountName),
                  'CustomerAddress': PlutoCell(value: complaint.customerAddress),
                  'Mobile': PlutoCell(value: complaint.customerMobileNo),
                  'ComplaintDetails': PlutoCell(value: complaint.complaintDetails),
                  'Status': PlutoCell(value: complaint.isComplaintType),
                  'Action': PlutoCell(value: complaint.complaintNo), // Action column with "Select" button
                });
              }).toList();

              return PlutoGrid(
                columns: [
                  PlutoColumn(title: 'SNo', field: 'SNo', type: PlutoColumnType.text()),
                  PlutoColumn(title: 'ComplaintNo', field: 'ComplaintNo', type: PlutoColumnType.text()),
                  PlutoColumn(title: 'Customer Name', field: 'CustomerName', type: PlutoColumnType.text()),
                  PlutoColumn(title: 'Address', field: 'CustomerAddress', type: PlutoColumnType.text()),
                  PlutoColumn(title: 'Mobile', field: 'Mobile', type: PlutoColumnType.text()),
                  PlutoColumn(title: 'Complaint Details', field: 'ComplaintDetails', type: PlutoColumnType.text()),
                  PlutoColumn(title: 'Status', field: 'Status', type: PlutoColumnType.text()),
                  PlutoColumn(
                    title: 'Action',
                    field: 'Action',
                    type: PlutoColumnType.text(),
                    renderer: (rendererContext) {
                      final complaintNo = rendererContext.cell.value;
                      return Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Select',  // Replace "Delete" with "Select"
                          style: TextStyle(color: Colors.blue), // Blue color for text
                        ),
                      );
                    },
                  ),
                ],
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  event.stateManager.setShowColumnFilter(true);
                },
                // Set header background color to a darker version of white (light gray)
                configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    cellTextStyle: TextStyle(color: Colors.black),
                    columnTextStyle: TextStyle(color: Colors.black),
                    gridBackgroundColor: Colors.white,
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
