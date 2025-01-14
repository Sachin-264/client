import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';

// Events
abstract class PpsReportEvent extends Equatable {
  const PpsReportEvent();

  @override
  List<Object> get props => [];
}

class FetchPpsReport extends PpsReportEvent {
  final Map<String, String> filters;

  const FetchPpsReport({required this.filters});

  @override
  List<Object> get props => [filters];
}

// States
abstract class PpsReportState extends Equatable {
  const PpsReportState();

  @override
  List<Object> get props => [];
}

class PpsReportInitial extends PpsReportState {}

class PpsReportLoading extends PpsReportState {}

class PpsReportLoaded extends PpsReportState {
  final List<Map<String, dynamic>> reports;

  const PpsReportLoaded({required this.reports});

  @override
  List<Object> get props => [reports];
}

class PpsReportError extends PpsReportState {
  final String errorMessage;

  const PpsReportError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];

  String get message => errorMessage;
}

// BLoC
class PpsReportBloc extends Bloc<PpsReportEvent, PpsReportState> {
  PpsReportBloc() : super(PpsReportInitial()) {
    on<FetchPpsReport>((event, emit) async {
      print('FetchPpsReport received with filters: ${event.filters}');
      emit(PpsReportLoading());

      try {
        // Construct the API URL with filter parameters
        final url = Uri.parse(
            'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?'
            'val1=${event.filters['userId'] ?? ''}&'
            'val2=${event.filters['branchCode'] ?? ''}&'
            'val3=${event.filters['addUser'] ?? ''}&'
            'val4=${event.filters['fromDate'] ?? ''}&'
            'val5=${event.filters['toDate'] ?? ''}&'
            'val6=${event.filters['customerCode'] ?? ''}&'
            'val7=${event.filters['soNoRecNo'] ?? ''}&'
            'val8=${event.filters['saleOrderNo'] ?? ''}&' //sAale order no.
            'val9=${event.filters['accountTypeCode'] ?? ''}&'
            'val10=${event.filters['groupName'] ?? ''}&'
            'val11=${event.filters['itemCode'] ?? ''}&'
            'type=sp_GetSaleOrderDetails&'
            'str=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ==');
        ;

        print('API URL: $url');

        // Make the API request
        final response = await http.get(url);

        print('API Response Status Code: ${response.statusCode}');
        print('API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(response.body);
          final reports = jsonList.cast<Map<String, dynamic>>();

          emit(PpsReportLoaded(reports: reports));
        } else {
          emit(
              PpsReportError('Failed to load reports: ${response.statusCode}'));
        }
      } catch (e) {
        print('Error: $e');
        emit(PpsReportError('An error occurred: $e'));
      }
    });
  }
}
