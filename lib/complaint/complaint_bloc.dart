import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'complaint_event.dart';
import 'complaint_state.dart';
import 'complaint.dart';

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final String apiUrl = "https://moneyshine.net.in/mobileAPI/CRM_getValues.php?val1=19.0&val2=0&val3=01-Dec-2024&val4=02-Jan-2025&val5=101.0&val6=N&type=sp_GetComplaintEntryForApproval&str=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zaHVzOCtsZ1ozMjVOazZMNWJoZmNrcHVVQ0dWSnM0d0RFS1VxUk5ZQThKdnNGM3RpR1QrZll1dWRNODFJMlFWaXc9PQ=="; // Replace with your API URL

  ComplaintBloc() : super(ComplaintInitial()) {
    // Fetch Complaints Handler
    on<FetchComplaints>((event, emit) async {
      emit(ComplaintLoading());
      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          List<Complaint> complaints = data.map((e) => Complaint.fromJson(e)).toList();
          emit(ComplaintLoaded(complaints: complaints));
        } else {
          emit(ComplaintError(message: "Failed to load complaints"));
        }
      } catch (e) {
        emit(ComplaintError(message: "Error: $e"));
      }
    });


  }
}