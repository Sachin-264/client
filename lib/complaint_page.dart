import 'package:client/PPS%20report/ppsdraft.dart';
import 'package:client/PPS%20report/ppsdraftbloc.dart';
import 'package:client/TargetDashboard/TargetDashboardPage.dart';
import 'package:client/TargetDashboard/targetDashboardBloc.dart';
import 'package:client/complaint/complaint.dart';
import 'package:client/complaint/complaint_bloc.dart';
import 'package:client/complaint/complaint_event.dart';
import 'package:client/complaint/complaint_state.dart';
import 'package:client/invoice/invoice_draft.dart';
import 'package:client/invoice/invoice_draft_bloc.dart';
import 'package:client/itemmanagement/itembloc.dart';
import 'package:client/itemmanagement/itemselectionpage.dart';
import 'package:client/saleorder/sale_order_page_draft.dart';
import 'package:client/saleorder/saleorderdraft_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:excel/excel.dart'; // For Excel export
import 'package:pdf/pdf.dart'; // For PDF export
import 'package:pdf/widgets.dart' as pw; // For PDF export
import 'package:path_provider/path_provider.dart'; // For file storage
import 'dart:io'; // For file operations
import 'package:file_picker/file_picker.dart'; // For file picking
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: depend_on_referenced_packages
import 'package:universal_html/html.dart' as html;

class ComplaintPage extends StatelessWidget {
  const ComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Complaint Entry List",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blue[50],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
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
                  Navigator.pop(context);
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
                        value: BlocProvider.of<SaleOrderDraftBloc>(context),
                        child: SaleOrderDraftPage(),
                      ),
                    ),
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
                        value: BlocProvider.of<InvoiceDraftPageBloc>(context),
                        child: InvoiceDraft(),
                      ),
                    ),
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.assessment,
                text: 'Target Dashboard',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: BlocProvider.of<TargetDashboardBloc>(context),
                        child: TargetDashboardPage(),
                      ),
                    ),
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.report_gmailerrorred_outlined,
                text: 'Item report',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: context.read<ItemManagementBloc>(),
                        child: ItemSelectionPage(),
                      ),
                    ),
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.local_shipping,
                text: 'PDS report',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: BlocProvider.of<PPSDraftPageBloc>(context),
                        child: PPSDraftPage(),
                      ),
                    ),
                  );
                },
              ),
              Divider(),
              _createDrawerItem(
                icon: Icons.settings,
                text: 'Settings',
                onTap: () {
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
                  'CustomerAddress':
                      PlutoCell(value: complaint.customerAddress),
                  'Mobile': PlutoCell(value: complaint.customerMobileNo),
                  'ComplaintDetails':
                      PlutoCell(value: complaint.complaintDetails),
                  'Status': PlutoCell(value: complaint.isComplaintType),
                  'Action': PlutoCell(value: complaint.complaintNo),
                });
              }).toList();

              return Column(
                children: [
                  // Add buttons here (below AppBar)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _exportToExcel(
                                state.complaints, context); // Export to Excel
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Green background
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'Export to Excel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 20), // Add spacing between buttons
                        ElevatedButton(
                          onPressed: () {
                            _exportToPDF(
                                state.complaints, context); // Export to PDF
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Red background
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'Export to PDF',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PlutoGrid(
                      columns: [
                        PlutoColumn(
                            title: 'SNo',
                            field: 'SNo',
                            type: PlutoColumnType.text()),
                        PlutoColumn(
                            title: 'ComplaintNo',
                            field: 'ComplaintNo',
                            type: PlutoColumnType.text()),
                        PlutoColumn(
                            title: 'Customer Name',
                            field: 'CustomerName',
                            type: PlutoColumnType.text()),
                        PlutoColumn(
                            title: 'Address',
                            field: 'CustomerAddress',
                            type: PlutoColumnType.text()),
                        PlutoColumn(
                            title: 'Mobile',
                            field: 'Mobile',
                            type: PlutoColumnType.text()),
                        PlutoColumn(
                            title: 'Complaint Details',
                            field: 'ComplaintDetails',
                            type: PlutoColumnType.text()),
                        PlutoColumn(
                            title: 'Status',
                            field: 'Status',
                            type: PlutoColumnType.text()),
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
                    ),
                  ),
                ],
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

  // Export to Excel
  Future<void> _exportToExcel(
      List<Complaint> complaints, BuildContext context) async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Add headers
    sheet.appendRow([
      TextCellValue('SNo'),
      TextCellValue('ComplaintNo'),
      TextCellValue('Customer Name'),
      TextCellValue('Address'),
      TextCellValue('Mobile'),
      TextCellValue('Complaint Details'),
      TextCellValue('Status'),
    ]);

    // Add data rows
    for (var complaint in complaints) {
      sheet.appendRow([
        IntCellValue(complaint.sNo), // Use IntCellValue for integers
        IntCellValue(complaint.complaintNo), // Use IntCellValue for integers
        TextCellValue(complaint.accountName), // Use TextCellValue for strings
        TextCellValue(
            complaint.customerAddress), // Use TextCellValue for strings
        IntCellValue(
            complaint.customerMobileNo), // Use IntCellValue for integers
        TextCellValue(
            complaint.complaintDetails), // Use TextCellValue for strings
        TextCellValue(
            complaint.isComplaintType), // Use TextCellValue for strings
      ]);
    }

    // Save the file
    var fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/complaints.xlsx');
      await file.writeAsBytes(fileBytes);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to Excel successfully!')),
      );
    }
  }

  // Export to PDF
  // Export to PDF

  Future<void> _exportToPDF(
      List<Complaint> complaints, BuildContext context) async {
    try {
      print('Starting PDF export process...');

      // Create a PDF document
      final pdf = pw.Document();
      print('PDF document created.');

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            print('Adding table to PDF page...');
            return pw.Table.fromTextArray(
              headers: [
                'SNo',
                'ComplaintNo',
                'Customer Name',
                'Address',
                'Mobile',
                'Complaint Details',
                'Status',
              ],
              data: complaints
                  .map((complaint) => [
                        complaint.sNo.toString(), // Convert to String
                        complaint.complaintNo.toString(), // Convert to String
                        complaint.accountName, // Already a String
                        complaint.customerAddress, // Already a String
                        complaint.customerMobileNo
                            .toString(), // Convert to String
                        complaint.complaintDetails, // Already a String
                        complaint.isComplaintType, // Already a String
                      ])
                  .toList(),
            );
          },
        ),
      );
      print('Table added to PDF page.');

      // Save the PDF to bytes
      final pdfBytes = await pdf.save();
      print('PDF saved to bytes.');

      // Create a Blob from the PDF bytes
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create an anchor element to trigger the download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'complaints.pdf')
        ..click();

      // Revoke the object URL to free up memory
      html.Url.revokeObjectUrl(url);

      print('PDF file downloaded successfully.');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to PDF successfully!')),
      );
    } catch (e, stackTrace) {
      // Log the error and stack trace
      print('Error occurred during PDF export: $e');
      print('Stack trace: $stackTrace');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export to PDF: $e')),
      );
    }
  }
}
