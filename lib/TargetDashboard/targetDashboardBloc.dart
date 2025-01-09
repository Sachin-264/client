import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class TargetDashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTargetDashboard extends TargetDashboardEvent {}

// States
abstract class TargetDashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TargetDashboardLoading extends TargetDashboardState {}
class TargetDashboardLoaded extends TargetDashboardState {
  final List<Map<String, dynamic>> data;
  TargetDashboardLoaded(this.data);

  @override
  List<Object?> get props => [data];
}
class TargetDashboardError extends TargetDashboardState {
  final String message;
  TargetDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class TargetDashboardBloc extends Bloc<TargetDashboardEvent, TargetDashboardState> {
  TargetDashboardBloc() : super(TargetDashboardLoading()) {
    on<FetchTargetDashboard>(_onFetchTargetDashboard);
  }

  Future<void> _onFetchTargetDashboard(
      FetchTargetDashboard event,
      Emitter<TargetDashboardState> emit,
      ) async {
    emit(TargetDashboardLoading());
    try {
      final response = await http.get(Uri.parse(
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?val1=157.0&val2=01-Jan-2025&val3=05-Jan-2025&val4=&val5=&val6=&val7=&val8=&val9=&val10=&val11=&val12=&type=sp_GetSaleVsTargetAllSalesManReport&val13=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ=='
      ));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonData);
        emit(TargetDashboardLoaded(data));
      } else {
        emit(TargetDashboardError('Failed to load data'));
      }
    } catch (e) {
      emit(TargetDashboardError('Error: $e'));
    }
  }
}