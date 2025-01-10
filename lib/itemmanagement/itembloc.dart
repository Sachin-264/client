import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For compute

// Events
abstract class ItemManagementEvent {}

class FetchItemNames extends ItemManagementEvent {}

// States
abstract class ItemManagementState {}

class ItemManagementInitial extends ItemManagementState {}

class ItemManagementLoading extends ItemManagementState {}

class ItemManagementLoaded extends ItemManagementState {
  final List<Map<String, String>> items;
  ItemManagementLoaded(this.items);
}

class ItemManagementError extends ItemManagementState {
  final String message;
  ItemManagementError(this.message);
}

// BLoC
class ItemManagementBloc extends Bloc<ItemManagementEvent, ItemManagementState> {
  ItemManagementBloc() : super(ItemManagementInitial()) {
    on<FetchItemNames>(_onFetchItemNames);
  }

  Future<void> _onFetchItemNames(FetchItemNames event, Emitter<ItemManagementState> emit) async {
    emit(ItemManagementLoading());
    print('Fetching items...'); // Debug log
    try {
      final items = await _fetchItemNames();
      print('Items fetched: ${items.length}'); // Debug log
      emit(ItemManagementLoaded(items));
    } catch (e) {
      print('Error fetching items: $e'); // Debug log
      emit(ItemManagementError('Failed to fetch items: $e'));
    }
  }

  Future<List<Map<String, String>>> _fetchItemNames() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?type=sp_GetItemName1&ucode=157.0&ccode=0.0&val1=E&val2=&val3=&val4=&val5=&val6=&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ==='
      )).timeout(Duration(seconds: 10)); // Add timeout

      print('API Response: ${response.statusCode}'); // Debug log
      // print('API Response Body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        // Use compute to parse JSON in a separate isolate
        return await compute(_parseJson, response.body);
      } else {
        throw Exception('Failed to load items');
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Function to parse JSON in a separate isolate
  static List<Map<String, String>> _parseJson(String responseBody) {
    final List<dynamic> data = json.decode(responseBody);
    return List<Map<String, String>>.from(data.map((item) {
      return {
        'name': item['FieldName']?.toString() ?? '',
        'code': item['FieldCode']?.toString() ?? '',
      };
    }));
  }
}