import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Events
abstract class InvoiceDraftPageEvent {}

class FetchData extends InvoiceDraftPageEvent {}

// States
abstract class InvoiceDraftPageState {}

class InvoiceDraftPageInitial extends InvoiceDraftPageState {}

class InvoiceDraftPageLoading extends InvoiceDraftPageState {}

class InvoiceDraftPageLoaded extends InvoiceDraftPageState {
  final List<Map<String, String>> branches;
  final List<Map<String, String>>
      categories; // Changed to List<Map<String, String>>
  final List<Map<String, String>> customers;
  final List<String> salesmanNames;
  final List<Map<String, String>> items;

  InvoiceDraftPageLoaded({
    required this.branches,
    required this.categories,
    required this.customers,
    required this.salesmanNames,
    required this.items,
  });

  @override
  List<Object> get props =>
      [branches, categories, customers, salesmanNames, items];
}

class InvoiceDraftPageError extends InvoiceDraftPageState {
  final String message;
  InvoiceDraftPageError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class InvoiceDraftPageBloc
    extends Bloc<InvoiceDraftPageEvent, InvoiceDraftPageState> {
  InvoiceDraftPageBloc() : super(InvoiceDraftPageInitial()) {
    on<FetchData>(_onFetchData);
  }

  Future<void> _onFetchData(
      FetchData event, Emitter<InvoiceDraftPageState> emit) async {
    emit(InvoiceDraftPageLoading());

    try {
      final results = await Future.wait([
        _fetchBranchNames(),
        _fetchCategories(),
        _fetchCustomerNames(),
        _fetchSalesmanNames(),
        _fetchItemNames(),
      ]);

      // Cast the results to the correct types
      final List<Map<String, String>> branches =
          results[0] as List<Map<String, String>>;
      final List<Map<String, String>> categories =
          results[1] as List<Map<String, String>>; // Updated type
      final List<Map<String, String>> customers =
          results[2] as List<Map<String, String>>;
      final List<String> salesmanNames = results[3] as List<String>;
      final List<Map<String, String>> items =
          results[4] as List<Map<String, String>>;

      // Debugging: Print fetched data
      // print('Branches: $branches');
      // print('Categories: $categories');
      // print('Customers: $customers');
      // print('Salesman Names: $salesmanNames');
      // print('Items: $items');

      emit(InvoiceDraftPageLoaded(
        branches: branches,
        categories: categories,
        customers: customers,
        salesmanNames: salesmanNames,
        items: items,
      ));
    } catch (e) {
      print('Error fetching data: $e'); // Debugging: Print error
      emit(InvoiceDraftPageError('Failed to fetch data: $e'));
    }
  }

  Future<List<Map<String, String>>> _fetchBranchNames() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetBranchName&ucode=157.0&ccode=0.0&val1=157.0&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Debugging: Print raw response body
      // print('Raw Branch Names API Response: ${response.body}');

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Debugging: Print decoded JSON data
      // print('Decoded Branch Names Data: $data');

      // Convert the JSON object into a List<Map<String, String>>
      final List<Map<String, String>> branchList =
          List<Map<String, String>>.from(data.map((item) {
        return {
          'name': item['FieldName']?.toString() ?? '',
          'code': item['FieldID']?.toString() ??
              '', // Only use FieldId, no fallback to FieldName
        };
      }));

      print('Branch Code');
      // Print only the 'code' for each branch
      for (var branch in branchList) {
        print('Branch Code: ${branch['code']}');
      }

      return branchList;
    } catch (e) {
      print('Error in _fetchBranchNames: $e'); // Debugging: Print error
      rethrow;
    }
  }

  Future<List<Map<String, String>>> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetSOTypeName&ucode=157.0&ccode=0.0&val1=E&val2=SO&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Debugging: Print raw response body
      // print('Raw Categories API Response: ${response.body}');

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Debugging: Print decoded JSON data
      // print('Decoded Categories Data: $data');

      // Convert the JSON object into a List<Map<String, String>>
      final List<Map<String, String>> categoryList =
          List<Map<String, String>>.from(data.map((item) {
        return {
          'code': item['FieldID']?.toString() ?? '', // Store FieldID
          'name': item['FieldName']?.toString() ?? '', // Store FieldName
        };
      }));

      // Print both FieldID and FieldName for each category
      print('Categories ->');
      for (var category in categoryList) {
        print('ID: ${category['code']}');
      }

      // Return the list of categories
      return categoryList;
    } catch (e) {
      print('Error in _fetchCategories: $e'); // Debugging: Print error
      rethrow;
    }
  }

  Future<List<Map<String, String>>> _fetchCustomerNames() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetBusinessDirectoryName&ucode=157.0&ccode=0.0&val1=E&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Debugging: Print raw response body
      // print('Raw Customer Names API Response: ${response.body}');

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Debugging: Print decoded JSON data
      // print('Decoded Customer Names Data: $data');

      // Convert the JSON object into a List<Map<String, String>>
      final List<Map<String, String>> customerList =
          List<Map<String, String>>.from(data.map((item) {
        return {
          'name': item['FieldName']?.toString() ?? '',
          'code': item['FieldCode']?.toString() ?? '',
        };
      }));

      // Print the 'code' for each customer
      print('Customer Code ->');
      for (var customer in customerList) {
        print('Customer Code: ${customer['code']}');
      }

      // Return the list of customers
      return customerList;
    } catch (e) {
      print('Error in _fetchCustomerNames: $e'); // Debugging: Print error
      rethrow;
    }
  }

  Future<List<String>> _fetchSalesmanNames() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetCommonTableData1&ucode=157.0&ccode=0.0&val1=SalesManMaster&val2=SalesManName&val3=RecNo&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Debugging: Print raw response body
      // print('Raw Salesman Names API Response: ${response.body}');

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Debugging: Print decoded JSON data
      // print('Decoded Salesman Names Data: $data');

      // Convert the JSON object into a List<String>
      return List<String>.from(
          data.map((item) => item['FieldName']?.toString() ?? ''));
    } catch (e) {
      print('Error in _fetchSalesmanNames: $e'); // Debugging: Print error
      rethrow;
    }
  }

  Future<List<Map<String, String>>> _fetchItemNames() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetItemName1&ucode=157.0&ccode=0.0&val1=E&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Debugging: Print raw response body
      // print('Raw Item Names API Response: ${response.body}');

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Debugging: Print decoded JSON data
      // print('Decoded Item Names Data: $data');

      // Convert the JSON object into a List<Map<String, String>>
      final List<Map<String, String>> itemList =
          List<Map<String, String>>.from(data.map((item) {
        return {
          'name': item['FieldName']?.toString() ?? '',
          'code': item['FieldCode']?.toString() ?? '',
        };
      }));

      // Print the 'code' for each item
      print('Item Codes ->');
      for (var item in itemList) {
        print('Item Code: ${item['code']}');
      }

      // Return the list of items
      return itemList;
    } catch (e) {
      print('Error in _fetchItemNames: $e'); // Debugging: Print error
      rethrow;
    }
  }
}
