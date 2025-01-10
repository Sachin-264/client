import 'package:client/TargetDashboard/select_page.dart';
import 'package:client/TargetDashboard/view_all_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/TargetDashboard/targetsale&viewallbloc.dart';
// Import the SelectPage

class TargetSalePage extends StatelessWidget {

  final String salesmanRecNo;

  const TargetSalePage({ required this.salesmanRecNo,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Target Sale',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Back',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => TargetSaleBloc()..add(FetchTargetSale()),
        child: BlocBuilder<TargetSaleBloc, TargetSaleState>(
          builder: (context, state) {
            if (state is TargetSaleLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TargetSaleError) {
              return Center(child: Text(state.message));
            } else if (state is TargetSaleLoaded) {
              // Get present month, last month, and second last month data
              final presentMonthData = _getMonthData(state.data, 0); // Present month
              final lastMonthData = _getMonthData(state.data, -1); // Last month
              final secondLastMonthData = _getMonthData(state.data, -2); // Second last month

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Three Boxes for Present Month, Last Month, and Second Last Month
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate the number of boxes per row based on screen width
                          final boxWidth = 300.0; // Fixed width
                          final availableWidth = constraints.maxWidth;
                          final boxesPerRow = (availableWidth / boxWidth).floor();
                          final crossAxisCount = boxesPerRow.clamp(1, 3); // Ensure at least 1 and at most 3 boxes per row

                          return GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(), // Disable scrolling
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: [
                              _buildDateBox(context, presentMonthData, Colors.blue), // Pass context here
                              _buildDateBox(context, lastMonthData, Colors.green), // Pass context here
                              _buildDateBox(context, secondLastMonthData, Colors.orange), // Pass context here
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      // View All Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewAllPage(
                                    salesmanRecNo:salesmanRecNo
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: Text(
                            'View All',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
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

  // Helper method to get data for a specific month offset
  Map<String, dynamic> _getMonthData(List<Map<String, dynamic>> data, int monthOffset) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month + monthOffset);
    final targetMonthKey = _getMonthKey(targetMonth);

    return data.firstWhere(
          (item) => _getMonthKeyFromDate(item['FromDate']) == targetMonthKey,
      orElse: () => {},
    );
  }

  // Helper method to get month key (e.g., "Apr-2024")
  String _getMonthKey(DateTime date) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = monthNames[date.month - 1];
    return '$month-${date.year}';
  }

  // Helper method to extract month key from API date (e.g., "01-Apr-2024" -> "Apr-2024")
  String _getMonthKeyFromDate(String fromDate) {
    final parts = fromDate.split('-');
    if (parts.length == 3) {
      return '${parts[1]}-${parts[2]}'; // Returns "Jan-2025"
    }
    return '';
  }

  // Widget to build a date box
  Widget _buildDateBox(BuildContext context, Map<String, dynamic> data, Color color) {
    final month = _getMonthKeyFromDate(data['FromDate'] ?? 'N/A');
    final targetValue = _formatNumber(data['TargeValue'] ?? '0'); // Format target value
    final percentageAchieved = data['ValuePer'] ?? '0.00'; // Use ValuePer directly from API
    final fromDate = data['FromDate'] ?? 'N/A'; // Extract FromDate
    final toDate = data['ToDate'] ?? 'N/A'; // Extract ToDate
    print(fromDate);
    print(toDate);

    return InkWell(
      onTap: () {
        // Navigate to SelectPage with FromDate and ToDate
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectPage(fromDate: fromDate, toDate: toDate, salesmanRecNo: salesmanRecNo,),
          ),
        );
      },
      child: Container(
        width: 300, // Fixed width
        height: 300, // Fixed height
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              month,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18, // Slightly increased font size
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Target: $targetValue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, // Slightly increased font size
              ),
            ),
            SizedBox(height: 8),
            Text(
              '% Achieved: $percentageAchieved%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, // Slightly increased font size
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format numbers with commas (e.g., 425628.00 -> 4,25,628.00)
  String _formatNumber(String number) {
    final parts = number.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Check if the number is negative
    final isNegative = integerPart.startsWith('-');
    final digits = isNegative ? integerPart.substring(1) : integerPart;

    // Add commas to the integer part
    final buffer = StringBuffer();
    int count = 0;

    // Start from the end of the integer part
    for (int i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;

      // Add a comma after every three digits from the right
      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      }
      // After the first comma, add commas after every two digits
      else if (count == 2 && i != 0 && buffer.toString().contains(',')) {
        buffer.write(',');
        count = 0;
      }
    }

    // Reverse the buffer to get the correct format
    final reversed = buffer.toString().split('').reversed.join();

    // Add the negative sign back if necessary
    return '${isNegative ? '-' : ''}$reversed$decimalPart';
  }

}