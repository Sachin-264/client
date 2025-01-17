import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Events
abstract class SaleOrderDraftEvent {}

class FetchData extends SaleOrderDraftEvent {
  final String? selectedBranch;

  FetchData({this.selectedBranch});
}

// States
abstract class SaleOrderDraftState {}

class SaleOrderDraftInitial extends SaleOrderDraftState {}

class SaleOrderDraftLoading extends SaleOrderDraftState {}

class SaleOrderDraftLoaded extends SaleOrderDraftState {
  final List<Map<String, String>> branches;
  final List<Map<String, String>> categories;
  final List<Map<String, String>> customers;
  // final List<Map<String, String>> salesmanNames; // Updated type
  // final List<Map<String, String>> items;

  SaleOrderDraftLoaded({
    required this.branches,
    required this.categories,
    required this.customers,
    // required this.salesmanNames, // Updated type
    // required this.items,
  });

  @override
  List<Object> get props => [
        branches,
        categories,
        customers,
      ];
//          salesmanNames, items
}

class SaleOrderDraftError extends SaleOrderDraftState {
  final String message;
  SaleOrderDraftError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class SaleOrderDraftBloc
    extends Bloc<SaleOrderDraftEvent, SaleOrderDraftState> {
  SaleOrderDraftBloc() : super(SaleOrderDraftInitial()) {
    on<FetchData>(_onFetchData);
  }

  Future<void> _onFetchData(
      FetchData event, Emitter<SaleOrderDraftState> emit) async {
    emit(SaleOrderDraftLoading());

    try {
      final selectedBranch = event.selectedBranch ?? 'E';

      final results = await Future.wait([
        _fetchBranchNames(),
        _fetchCategories(selectedBranch),
        _fetchCustomerNames(selectedBranch),
        // _fetchSalesmanNames(
        //     selectedBranch), // Correctly returns List<Map<String, String>>
        // _fetchItemNames(selectedBranch),
      ]);

      final List<Map<String, String>> branches = results[0];
      final List<Map<String, String>> categories = results[1];
      final List<Map<String, String>> customers = results[2];
      // final List<Map<String, String>> salesmanNames =
      //     results[3] as List<Map<String, String>>; // Correct type
      // final List<Map<String, String>> items =
      //     results[4] as List<Map<String, String>>;

      emit(SaleOrderDraftLoaded(
        branches: branches,
        categories: categories,
        customers: customers,
        // salesmanNames: salesmanNames, // Correct type
        // items: items,
      ));
    } catch (e) {
      log('Error fetching data: $e');
      emit(SaleOrderDraftError('Failed to fetch data: $e'));
    }
  }

  Future<List<Map<String, String>>> _fetchBranchNames() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetBranchName&ucode=157.0&ccode=0.0&val1=157.0&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Convert the JSON object into a List<Map<String, String>>
      final List<Map<String, String>> branchList =
          List<Map<String, String>>.from(data.map((item) {
        return {
          'name': item['FieldName']?.toString() ?? '',
          'code': item['FieldID']?.toString() ?? '',
        };
      }));

      return branchList;
    } catch (e) {
      log('Error in _fetchBranchNames: $e');
      rethrow;
    }
  }

  Future<List<Map<String, String>>> _fetchCategories(
      String selectedBranch) async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetSOTypeName&ucode=157.0&ccode=0.0&val1=$selectedBranch&val2=SO&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Convert the JSON object into a List<Map<String, String>>
      final List<Map<String, String>> categoryList =
          List<Map<String, String>>.from(data.map((item) {
        return {
          'code': item['FieldID']?.toString() ?? '',
          'name': item['FieldName']?.toString() ?? '',
        };
      }));

      return categoryList;
    } catch (e) {
      log('Error in _fetchCategories: $e');
      rethrow;
    }
  }

  Future<List<Map<String, String>>> _fetchCustomerNames(
      String selectedBranch) async {
    try {
      // Log the API call
      log('Fetching customer names for branch: $selectedBranch');

      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetBusinessDirectoryName&ucode=157.0&ccode=0.0&val1=$selectedBranch&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      // Decode the response body into a JSON object
      final List<dynamic> data = json.decode(response.body);

      // Convert the JSON object into a List<Map<String, String>>
      final List<Map<String, String>> customerList =
          List<Map<String, String>>.from(data.map((item) {
        return {
          'name': item['FieldName']?.toString() ?? '',
          'code': item['FieldCode']?.toString() ?? '',
        };
      }));

      return customerList;
    } catch (e) {
      log('Error in _fetchCustomerNames: $e');
      rethrow;
    }
  }

//   Future<List<Map<String, String>>> _fetchSalesmanNames(
//       String selectedBranch) async {
//     try {
//       log('Fetching salesman names for branch: $selectedBranch');

//       final response = await http.get(Uri.parse(
//           'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetCommonTableData1&ucode=157.0&ccode=0.0&val1=SalesManMaster&val2=SalesManName&val3=RecNo&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));
//       final List<dynamic> data = json.decode(response.body);

//       // Convert the JSON object into a List<Map<String, String>>
//       final List<Map<String, String>> salesmanList = data.map((item) {
//         return {
//           'name': item['FieldName']?.toString() ?? '',
//           'code': item['FieldID']?.toString() ?? '',
//         };
//       }).toList();

//       return salesmanList;
//     } catch (e) {
//       log('Error in _fetchSalesmanNames: $e');
//       rethrow;
//     }
//   }

//   Future<List<Map<String, String>>> _fetchItemNames(
//       String selectedBranch) async {
//     try {
//       // Log the API call
//       log('Fetching item names for branch: $selectedBranch');

//       final response = await http.get(Uri.parse(
//           'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetItemName1&ucode=157.0&ccode=0.0&val1=$selectedBranch&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

//       // Decode the response body into a JSON object
//       final List<dynamic> data = json.decode(response.body);

//       // Convert the JSON object into a List<Map<String, String>>
//       final List<Map<String, String>> itemList =
//           List<Map<String, String>>.from(data.map((item) {
//         return {
//           'name': item['FieldName']?.toString() ?? '',
//           'code': item['FieldCode']?.toString() ?? '',
//         };
//       }));

//       return itemList;
//     } catch (e) {
//       log('Error in _fetchItemNames: $e');
//       rethrow;
//     }
//   }
}
