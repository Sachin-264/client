import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class TargetSaleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTargetSale extends TargetSaleEvent {}

// States
abstract class TargetSaleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TargetSaleLoading extends TargetSaleState {}
class TargetSaleLoaded extends TargetSaleState {
  final List<Map<String, dynamic>> data;
  TargetSaleLoaded(this.data);

  @override
  List<Object?> get props => [data];
}
class TargetSaleError extends TargetSaleState {
  final String message;
  TargetSaleError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class TargetSaleBloc extends Bloc<TargetSaleEvent, TargetSaleState> {
  TargetSaleBloc() : super(TargetSaleLoading()) {
    on<FetchTargetSale>(_onFetchTargetSale);
  }

  Future<void> _onFetchTargetSale(
      FetchTargetSale event,
      Emitter<TargetSaleState> emit,
      ) async {
    emit(TargetSaleLoading());
    try {
      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?val1=157.0&val2=96&val3=05-Jan-2025&val4=&val5=&val6=&val7=&type=sp_GetSaleVsTargetReport&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='
      ));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonData);
        emit(TargetSaleLoaded(data));
      } else {
        emit(TargetSaleError('Failed to load data'));
      }
    } catch (e) {
      emit(TargetSaleError('Error: $e'));
    }
  }
}