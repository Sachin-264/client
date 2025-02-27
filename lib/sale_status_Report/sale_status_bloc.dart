import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sale_model.dart'; // Import the SaleOrder model

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
  final List<SaleOrder> saleOrders;

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
            'http://localhost/AquavivaAPI/getSaleOrderSatus.php?'
                'UserCode=${event.filters['UserCode'] ?? ''}&'
                'BranchCode=${event.filters['BranchCode'] ?? ''}&'
                'AddUser=${event.filters['AddUser'] ?? ''}&'
                'FromDate=${event.filters['FromDate'] ?? ''}&'
                'ToDate=${event.filters['ToDate'] ?? ''}&'
                'AccountCode=${event.filters['AccountCode'] ?? ''}&'
                'SONOMasterRecNo=${event.filters['SONOMasterRecNo'] ?? ''}&'
                'ActualQuotationNo=${event.filters['ActualQuotationNo'] ?? ''}&'
                'AccountTypeCode=${event.filters['AccountTypeCode'] ?? ''}&'
                'GroupName=${event.filters['GroupName'] ?? ''}&'
                'ItemNo=${event.filters['ItemNo'] ?? ''}&'
                'SalesManRecNo=${event.filters['SalesManRecNo'] ?? ''}&'
                'str=${event.filters['str'] ?? ''}'
        );

        print('API URL: $url');

        // Make the API request
        final response = await http.get(url);

        print('API Response Status Code: ${response.statusCode}');
        print('API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);

          if (jsonResponse['status'] == 'success') {
            final List<dynamic> jsonList = jsonResponse['data'];

            // Convert JSON data to SaleOrder objects
            final List<SaleOrder> saleOrders = jsonList
                .map((json) => SaleOrder.fromJson(json))
                .toList();

            emit(SaleOrderLoaded(saleOrders: saleOrders));
          } else {
            emit(SaleOrderError('Failed to load sale orders: ${jsonResponse['status']}'));
          }
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