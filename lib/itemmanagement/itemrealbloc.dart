import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Events
abstract class ItemDraftPageEvent {}

class FetchData extends ItemDraftPageEvent {
  final String? selectedBranch;

  FetchData({this.selectedBranch});
}

// States
abstract class ItemDraftPageState {}

class ItemDraftPageInitial extends ItemDraftPageState {}

class ItemDraftPageLoading extends ItemDraftPageState {}

class ItemDraftPageLoaded extends ItemDraftPageState {
  final List<Map<String, String>> branches;
  final List<Map<String, String>> items;

  ItemDraftPageLoaded({
    required this.branches,
    required this.items,
  });

  @override
  List<Object> get props => [branches, items];
}

class ItemDraftPageError extends ItemDraftPageState {
  final String message;
  ItemDraftPageError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class ItemDraftPageBloc extends Bloc<ItemDraftPageEvent, ItemDraftPageState> {
  ItemDraftPageBloc() : super(ItemDraftPageInitial()) {
    on<FetchData>(_onFetchData);
  }

  Future<void> _onFetchData(
      FetchData event, Emitter<ItemDraftPageState> emit) async {
    emit(ItemDraftPageLoading());

    try {
      // Use 'E' as the default branch if selectedBranch is null
      final selectedBranch = event.selectedBranch ?? 'E';

      final results = await Future.wait([
        _fetchBranchNames(),
        _fetchItemNames(selectedBranch),
      ]);

      final List<Map<String, String>> branches = results[0];
      final List<Map<String, String>> items = results[1];

      emit(ItemDraftPageLoaded(
        branches: branches,
        items: items,
      ));
    } catch (e) {
      log('Error fetching data: $e');
      emit(ItemDraftPageError('Failed to fetch data: $e'));
    }
  }

  Future<List<Map<String, String>>> _fetchBranchNames() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetBranchName&ucode=157.0&ccode=0.0&val1=157.0&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, String>>.from(data.map((item) {
          return {
            'name': item['FieldName']?.toString() ?? '',
            'code': item['FieldID']?.toString() ?? '',
          };
        }));
      } else {
        throw Exception('Failed to load branch names');
      }
    } catch (e) {
      log('Error in _fetchBranchNames: $e');
      rethrow;
    }
  }

  Future<List<Map<String, String>>> _fetchItemNames(
      String selectedBranch) async {
    try {
      log('Fetching item names for branch: $selectedBranch');

      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetItemName1&ucode=157.0&ccode=0.0&val1=$selectedBranch&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, String>>.from(data.map((item) {
          return {
            'name': item['FieldName']?.toString() ?? '',
            'code': item['FieldCode']?.toString() ?? '',
          };
        }));
      } else {
        throw Exception('Failed to load item names');
      }
    } catch (e) {
      log('Error in _fetchItemNames: $e');
      rethrow;
    }
  }
}
