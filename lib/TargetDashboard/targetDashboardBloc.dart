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
      // Generate from date (first day of the current month)
      final DateTime now = DateTime.now();
      final DateTime fromDate = DateTime(now.year, now.month, 1);
      final String formattedFromDate = _formatDate(fromDate);

      // Generate to date (current date)
      final String formattedToDate = _formatDate(now);

      // Construct the API URL with dynamic dates
      final String apiUrl =
          'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?val1=157.0&val2=$formattedFromDate&val3=$formattedToDate&val4=&val5=&val6=&val7=&val8=&val9=&val10=&val11=&val12=&type=sp_GetSaleVsTargetAllSalesManReport&val13=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ==';

      // Make the API call
      final response = await http.get(Uri.parse(apiUrl));

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

  // Helper function to format dates as "dd-MMM-yyyy"
  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final String day = date.day.toString().padLeft(2, '0');
    final String month = months[date.month - 1];
    final String year = date.year.toString();

    return '$day-$month-$year';
  }
}