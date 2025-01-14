import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'complaint_event.dart';
import 'complaint_state.dart';
import 'complaint.dart';

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final String baseApiUrl =
      "https://moneyshine.net.in/mobileAPI/CRM_getValues.php"; // Base API URL

  ComplaintBloc() : super(ComplaintInitial()) {
    // Fetch Complaints Handler
    on<FetchComplaints>((event, emit) async {
      emit(ComplaintLoading());
      try {
        // Get the first date of the current month
        DateTime now = DateTime.now();
        DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);

        // Get the current date
        DateTime currentDate = DateTime.now();

        // Format dates to the required format (e.g., "01-Dec-2024")
        String formattedFirstDate =
            "${firstDateOfMonth.day.toString().padLeft(2, '0')}-${_getMonthAbbreviation(firstDateOfMonth.month)}-${firstDateOfMonth.year}";
        String formattedCurrentDate =
            "${currentDate.day.toString().padLeft(2, '0')}-${_getMonthAbbreviation(currentDate.month)}-${currentDate.year}";

        // Construct the API URL with dynamic date values
        String apiUrl =
            "$baseApiUrl?val1=19.0&val2=0&val3=$formattedFirstDate&val4=$formattedCurrentDate&val5=101.0&val6=N&type=sp_GetComplaintEntryForApproval&str=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zaHVzOCtsZ1ozMjVOazZMNWJoZmNrcHVVQ0dWSnM0d0RFS1VxUk5ZQThKdnNGM3RpR1QrZll1dWRNODFJMlFWaXc9PQ==";

        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          List<Complaint> complaints =
              data.map((e) => Complaint.fromJson(e)).toList();
          emit(ComplaintLoaded(complaints: complaints));
        } else {
          emit(ComplaintError(message: "Failed to load complaints"));
        }
      } catch (e) {
        emit(ComplaintError(message: "Error: $e"));
      }
    });
  }

  // Helper function to get month abbreviation
  String _getMonthAbbreviation(int month) {
    const monthAbbreviations = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return monthAbbreviations[month - 1];
  }
}
