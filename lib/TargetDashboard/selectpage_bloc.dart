import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Events
abstract class SelectPageEvent {}

class FetchSalesManData extends SelectPageEvent {
  final String fromDate;
  final String toDate;

  FetchSalesManData({required this.fromDate, required this.toDate});
}

// States
abstract class SelectPageState {}

class SalesManDataInitial extends SelectPageState {}

class SalesManDataLoading extends SelectPageState {}

class SalesManDataLoaded extends SelectPageState {
  final List<Map<String, dynamic>> data;

  SalesManDataLoaded({required this.data});
}

class SalesManDataError extends SelectPageState {
  final String message;

  SalesManDataError({required this.message});
}

// Bloc
class SelectPageBloc extends Bloc<SelectPageEvent, SelectPageState> {
  SelectPageBloc() : super(SalesManDataInitial()) {
    on<FetchSalesManData>(_onFetchSalesManData);
  }

  Future<void> _onFetchSalesManData(
      FetchSalesManData event,
      Emitter<SelectPageState> emit,
      ) async {
    emit(SalesManDataLoading());

    try {
      // Make the API call
      final data = await fetchSalesManData(event.fromDate, event.toDate);
      emit(SalesManDataLoaded(data: data));
    } catch (e) {
      emit(SalesManDataError(message: 'Failed to fetch data: $e'));
    }
  }

  // Function to fetch data from the API
  Future<List<Map<String, dynamic>>> fetchSalesManData(String fromDate, String toDate) async {
    final url = Uri.parse(
      'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?val1=157.0&val2=96&val3=01-Apr-2024&val4=30-Apr-2024&val5=&val6=&val7=&val8=&val9=&val10=&val11=&val12=&type=sp_GetSaleVsTargetSalesManReport&val13=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ==',
    );

    try {
      final response = await http.get(url);
      print('API Request: ${response.request?.url}');  // Log request URL

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data'); // Debug print

        if (data is List<dynamic>) {
          // Convert List<dynamic> to List<Map<String, dynamic>>
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          print('Unexpected response format: $data');
          throw Exception('Invalid data format: Expected List<dynamic>');
        }
      } else {
        print('API Request failed with status: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error during API call: $e');
      rethrow; // Re-throw exception to handle it in the Bloc
    }
  }
}
