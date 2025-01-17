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
  final List<SalesManData> data; // Use the model class here

  SalesManDataLoaded({required this.data});
}

class SalesManDataError extends SelectPageState {
  final String message;

  SalesManDataError({required this.message});
}

// model
class SalesManData {
  final String salesManName;
  final String hqName;
  final String salesManDesignation;
  final String targeValue;
  final String saleValue;
  final String valuePer;
  final String viewLevel;
  final String salesManRecNo;

  SalesManData({
    required this.salesManName,
    required this.hqName,
    required this.salesManDesignation,
    required this.targeValue,
    required this.saleValue,
    required this.valuePer,
    required this.viewLevel,
    required this.salesManRecNo,
  });
// Convert the object back to a Map (optional, useful for debugging or serialization)
  Map<String, dynamic> toMap() {
    return {
      'SalesManName': salesManName,
      'HQName': hqName,
      'SalesManDesignation': salesManDesignation,
      'TargeValue': targeValue,
      'SaleValue': saleValue,
      'ValuePer': valuePer,
      'ViewLevel': viewLevel,
      'SalesManRecNo': salesManRecNo,
    };
  }

  // Factory method to create a SalesManData object from a Map
  factory SalesManData.fromJson(Map<String, dynamic> map) {
    return SalesManData(
      salesManName: map['SalesManName'] ?? 'N/A',
      hqName: map['HQName'] ?? 'N/A',
      salesManDesignation: map['SalesManDesignation'] ?? 'N/A',
      targeValue: map['TargeValue'] ?? '0',
      saleValue: map['SaleValue'] ?? '0',
      valuePer: map['ValuePer'] ?? '0',
      viewLevel: map['ViewLevel'] ?? '0',
      salesManRecNo: map['SalesManRecNo'] ?? '0',
    );
  }
}

// Bloc
class SelectPageBloc extends Bloc<SelectPageEvent, SelectPageState> {
  SelectPageBloc() : super(SalesManDataInitial()) {
    on<FetchSalesManData>(_onFetchSalesManData);
  }

  Future<void> _onFetchSalesManData(
      FetchSalesManData event, Emitter<SelectPageState> emit) async {
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
  Future<List<SalesManData>> fetchSalesManData(
      String fromDate, String toDate) async {
    final url = Uri.parse(
      'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?val1=157.0&val2=96&val3=$fromDate&val4=$toDate&val5=&val6=&val7=&val8=&val9=&val10=&val11=&val12=&type=sp_GetSaleVsTargetSalesManReport&val13=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ==',
    );

    try {
      final response = await http.get(url);
      print('API Request: ${response.request?.url}'); // Log request URL

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data'); // Debug print

        if (data is List<dynamic>) {
          // Convert List<dynamic> to List<SalesManData>
          return data.map((item) => SalesManData.fromJson(item)).toList();
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
