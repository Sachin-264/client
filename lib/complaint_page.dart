import 'package:client/saleorder/saleorderbloc.dart';
import 'package:client/saleorder/saleorderpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'complaint/complaint_bloc.dart';
import 'complaint/complaint_event.dart';
import 'complaint/complaint_state.dart';
import 'complaint/complaint.dart';
import 'invoice/invoice bloc.dart';
import 'invoice/invoicepage.dart'; // Import PerformInvoicePage
import 'package:pluto_grid/pluto_grid.dart';

class ComplaintPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaint Entry List",
          style: TextStyle(
            color: Colors.white, // White color for text
          ),
        ),
        backgroundColor: Colors.blue,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu,color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blue[50], // Light blue background for the drawer
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue, // Blue background for the header
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dashboard, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        'Complaint Management',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _createDrawerItem(
                icon: Icons.home,
                text: 'Complaint Page',
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
              _createDrawerItem(
                icon: Icons.local_shipping,
                text: 'Sale Order Page',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: BlocProvider.of<SaleOrderBloc>(context),
                        child: SaleOrderPage(),
                      ),
                    ), // Navigate to SaleOrderPage
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.payment,
                text: 'Perform Invoice',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                    value: BlocProvider.of<InvoiceBloc>(context),
                    child: InvoicePage(),
                  ),
                    ),// Navigate to PerformInvoicePage
                  );
                },
              ),
              Divider(), // Add a divider for separation
              _createDrawerItem(
                icon: Icons.settings,
                text: 'Settings',
                onTap: () {
                  // Handle settings tap here
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
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
              List<PlutoRow> rows = state.complaints.map((complaint) {
                return PlutoRow(cells: {
                  'SNo': PlutoCell(value: complaint.sNo),
                  'ComplaintNo': PlutoCell(value: complaint.complaintNo),
                  'CustomerName': PlutoCell(value: complaint.accountName),
                  'CustomerAddress': PlutoCell(value: complaint.customerAddress),
                  'Mobile': PlutoCell(value: complaint.customerMobileNo),
                  'ComplaintDetails': PlutoCell(value: complaint.complaintDetails),
                  'Status': PlutoCell(value: complaint.isComplaintType),
                  'Action': PlutoCell(value: complaint.complaintNo),
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
                          'Select',
                          style: TextStyle(color: Colors.blue),
                        ),
                      );
                    },
                  ),
                ],
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
            }

            return Container();
          },
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
