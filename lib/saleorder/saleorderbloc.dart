import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Events
abstract class SaleOrderEvent extends Equatable {
  const SaleOrderEvent();

  @override
  List<Object> get props => [];
}

class FetchSaleOrderEvent extends SaleOrderEvent {
  final Map<String, String> filters;

  const FetchSaleOrderEvent({required this.filters});

  @override
  List<Object> get props => [filters];
}

// States
abstract class SaleOrderState extends Equatable {
  const SaleOrderState();

  @override
  List<Object> get props => [];
}

class SaleOrderInitial extends SaleOrderState {}

class SaleOrderLoading extends SaleOrderState {}

class SaleOrderLoaded extends SaleOrderState {
  final List<Map<String, dynamic>> saleOrders;

  const SaleOrderLoaded({required this.saleOrders});

  @override
  List<Object> get props => [saleOrders];
}

class SaleOrderError extends SaleOrderState {
  final String errorMessage;

  const SaleOrderError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

// Bloc
class SaleOrderBloc extends Bloc<SaleOrderEvent, SaleOrderState> {
  SaleOrderBloc() : super(SaleOrderInitial()) {
    on<FetchSaleOrderEvent>((event, emit) async {
      print('FetchSaleOrderEvent received with filters: ${event.filters}');
      emit(SaleOrderLoading());

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
                'val8=${event.filters['qNo'] ?? ''}&'
                'val9=${event.filters['accountTypeCode'] ?? ''}&'
                'val10=${event.filters['groupName'] ?? ''}&'
                'val11=${event.filters['itemCode'] ?? ''}&'
                'type=sp_GetSaleOrderDetails&'
                'str=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ==');

        print('API URL: $url');

        // Make the API request
        final response = await http.get(url);

        print('API Response Status Code: ${response.statusCode}');
        print('API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(response.body);
          final saleOrders = jsonList.cast<Map<String, dynamic>>();

          emit(SaleOrderLoaded(saleOrders: saleOrders));
        } else {
          emit(SaleOrderError('Failed to load sale orders: ${response.statusCode}'));
        }
      } catch (e) {
        print('Error: $e');
        emit(SaleOrderError('An error occurred: $e'));
      }
    });
  }
}