import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';

// Events
abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object> get props => [];
}

class FetchItemData extends ItemEvent {
  final String fromDate;
  final String toDate;
  final String salesmanId;

  const FetchItemData({
    required this.fromDate,
    required this.toDate,
    required this.salesmanId,
  });

  @override
  List<Object> get props => [fromDate, toDate, salesmanId];
}

// States
abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object> get props => [];
}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemLoaded extends ItemState {
  final List<Map<String, dynamic>> data;

  const ItemLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class ItemError extends ItemState {
  final String message;

  const ItemError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ItemBloc extends Bloc<ItemEvent, ItemState> {
  ItemBloc() : super(ItemInitial()) {
    on<FetchItemData>(_onFetchItemData);
  }

  Future<void> _onFetchItemData(
      FetchItemData event,
      Emitter<ItemState> emit,
      ) async {
    emit(ItemLoading());
    try {
      final response = await http.get(Uri.parse(
        'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?val1=${event.salesmanId}&val2=96&val3=${event.fromDate}&val4=${event.toDate}&val5=&val6=&val7=&val8=&val9=&val10=&val11=&val12=&type=sp_GetSaleVsTargetItemWiseReport&val13=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ==',
      ));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Check if the response is a list
        if (jsonData is List) {
          final List<Map<String, dynamic>> data = jsonData
              .map((item) => item as Map<String, dynamic>)
              .toList();
          emit(ItemLoaded(data));
        } else {
          emit(ItemError('Invalid API response format'));
        }
      } else {
        emit(ItemError('Failed to load data: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ItemError('An error occurred: $e'));
    }
  }
}