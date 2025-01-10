import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// Events
abstract class ReportEvent {}

class FetchReport extends ReportEvent {
  final String itemCode;
  final String quantity;

  FetchReport({required this.itemCode, required this.quantity});
}

// States
abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<Map<String, dynamic>> reportData;

  ReportLoaded(this.reportData);
}

class ReportError extends ReportState {
  final String message;

  ReportError(this.message);
}

// BLoC
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc() : super(ReportInitial()) {
    on<FetchReport>(_onFetchReport);
  }

  Future<void> _onFetchReport(FetchReport event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final response = await http.get(Uri.parse(
        'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?val1=${event.itemCode}&val2=${event.quantity}&val8=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ==&type=sp_GetTreeRelationMasterReport',
      )).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> reportData = List<Map<String, dynamic>>.from(data);
        emit(ReportLoaded(reportData));
      } else {
        emit(ReportError('Failed to load report'));
      }
    } on TimeoutException {
      emit(ReportError('Request timed out'));
    } catch (e) {
      emit(ReportError('Error: $e'));
    }
  }
}