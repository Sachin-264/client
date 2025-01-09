import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Events
abstract class SaleOrderDraftEvent {}

class FetchData extends SaleOrderDraftEvent {}

// States
abstract class SaleOrderDraftState {}

class SaleOrderDraftInitial extends SaleOrderDraftState {}

class SaleOrderDraftLoading extends SaleOrderDraftState {}

class SaleOrderDraftLoaded extends SaleOrderDraftState {
  final List<Map<String, String>> branches;
  final List<String> categories;
  final List<Map<String, String>> customers;
  final List<String> salesmanNames;
  final List<Map<String, String>> items;

  SaleOrderDraftLoaded({
    required this.branches,
    required this.categories,
    required this.customers,
    required this.salesmanNames,
    required this.items,
  });

  @override
  List<Object> get props => [branches, categories, customers, salesmanNames, items];
}

class SaleOrderDraftError extends SaleOrderDraftState {
  final String message;
  SaleOrderDraftError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class SaleOrderDraftBloc extends Bloc<SaleOrderDraftEvent, SaleOrderDraftState> {
  SaleOrderDraftBloc() : super(SaleOrderDraftInitial()) {
    on<FetchData>(_onFetchData);
  }

  Future<void> _onFetchData(FetchData event, Emitter<SaleOrderDraftState> emit) async {
    emit(SaleOrderDraftLoading());

    try {
      final results = await Future.wait([
        _fetchBranchNames(),
        _fetchCategories(),
        _fetchCustomerNames(),
        _fetchSalesmanNames(),
        _fetchItemNames(),
      ]);

      // Cast the results to the correct types
      final List<Map<String, String>> branches = results[0] as List<Map<String, String>>;
      final List<String> categories = results[1] as List<String>;
      final List<Map<String, String>> customers = results[2] as List<Map<String, String>>;
      final List<String> salesmanNames = results[3] as List<String>;
      final List<Map<String, String>> items = results[4] as List<Map<String, String>>;

      // Debugging: Print fetched data
      print('Branches: $branches');
      print('Categories: $categories');
      print('Customers: $customers');
      print('Salesman Names: $salesmanNames');
      print('Items: $items');

      emit(SaleOrderDraftLoaded(
        branches: branches,
        categories: categories,
        customers: customers,
        salesmanNames: salesmanNames,
        items: items,
      ));
    } catch (e) {
      print('Error fetching data: $e'); // Debugging: Print error
      emit(SaleOrderDraftError('Failed to fetch data: $e'));
    }
  }

  Future<List<Map<String, String>>> _fetchBranchNames() async {
    try {
      final response = await http.get(Uri.parse('https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetBranchName&ucode=157.0&ccode=0.0&val1=157.0&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Debugging: Print raw response body
      print('Raw Branch Names API Response: ${response.body}');

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Debugging: Print decoded JSON data
      print('Decoded Branch Names Data: $data');

      // Convert the JSON object into a List<Map<String, String>>
      return List<Map<String, String>>.from(data.map((item) {
        return {
          'name': item['FieldName']?.toString() ?? '',
          'code': item['FieldId']?.toString() ?? item['FieldName']?.toString() ?? '', // Fallback to name if code is empty
        };
      }));
    } catch (e) {
      print('Error in _fetchBranchNames: $e'); // Debugging: Print error
      rethrow;
    }
  }

  Future<List<String>> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetSOTypeName&ucode=157.0&ccode=0.0&val1=E&val2=SO&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Debugging: Print raw response body
      print('Raw Categories API Response: ${response.body}');

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Debugging: Print decoded JSON data
      print('Decoded Categories Data: $data');

      // Convert the JSON object into a List<String>
      return List<String>.from(data.map((item) => item['FieldName']?.toString() ?? ''));
    } catch (e) {
      print('Error in _fetchCategories: $e'); // Debugging: Print error
      rethrow;
    }
  }

  Future<List<Map<String, String>>> _fetchCustomerNames() async {
    try {
      final response = await http.get(Uri.parse('https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetBusinessDirectoryName&ucode=157.0&ccode=0.0&val1=E&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Debugging: Print raw response body
      print('Raw Customer Names API Response: ${response.body}');

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Debugging: Print decoded JSON data
      print('Decoded Customer Names Data: $data');

      // Convert the JSON object into a List<Map<String, String>>
      return List<Map<String, String>>.from(data.map((item) {
        return {
          'name': item['FieldName']?.toString() ?? '',
          'code': item['FieldCode']?.toString() ?? '',
        };
      }));
    } catch (e) {
      print('Error in _fetchCustomerNames: $e'); // Debugging: Print error
      rethrow;
    }
  }

  Future<List<String>> _fetchSalesmanNames() async {
    try {
      final response = await http.get(Uri.parse('https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetCommonTableData1&ucode=157.0&ccode=0.0&val1=SalesManMaster&val2=SalesManName&val3=RecNo&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Debugging: Print raw response body
      print('Raw Salesman Names API Response: ${response.body}');

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Debugging: Print decoded JSON data
      print('Decoded Salesman Names Data: $data');

      // Convert the JSON object into a List<String>
      return List<String>.from(data.map((item) => item['FieldName']?.toString() ?? ''));
    } catch (e) {
      print('Error in _fetchSalesmanNames: $e'); // Debugging: Print error
      rethrow;
    }
  }

  Future<List<Map<String, String>>> _fetchItemNames() async {
    try {
      final response = await http.get(Uri.parse('https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetItemName1&ucode=157.0&ccode=0.0&val1=E&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Debugging: Print raw response body
      print('Raw Item Names API Response: ${response.body}');

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Debugging: Print decoded JSON data
      print('Decoded Item Names Data: $data');

      // Convert the JSON object into a List<Map<String, String>>
      return List<Map<String, String>>.from(data.map((item) {
        return {
          'name': item['FieldName']?.toString() ?? '',
          'code': item['FieldCode']?.toString() ?? '',
        };
      }));
    } catch (e) {
      print('Error in _fetchItemNames: $e'); // Debugging: Print error
      rethrow;
    }
  }
}