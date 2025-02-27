import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'orderAllocation_model.dart';


// Events
abstract class orderAllocationEvent extends Equatable {
  const orderAllocationEvent();

  @override
  List<Object> get props => [];
}

class FetchorderAllocationEvent extends orderAllocationEvent {
  final Map<String, String> filters;

  const FetchorderAllocationEvent({required this.filters});

  @override
  List<Object> get props => [filters];
}

// States
abstract class orderAllocationState extends Equatable {
  const orderAllocationState();

  @override
  List<Object> get props => [];
}

class orderAllocationInitial extends orderAllocationState {}

class orderAllocationLoading extends orderAllocationState {}

class orderAllocationLoaded extends orderAllocationState {
  final List<orderAllocation> orderAllocations;

  const orderAllocationLoaded({required this.orderAllocations});

  @override
  List<Object> get props => [orderAllocations];
}

class orderAllocationError extends orderAllocationState {
  final String errorMessage;

  const orderAllocationError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

// Bloc
class orderAllocationBloc extends Bloc<orderAllocationEvent, orderAllocationState> {
  orderAllocationBloc() : super(orderAllocationInitial()) {
    on<FetchorderAllocationEvent>((event, emit) async {
      print('FetchorderAllocationEvent received with filters: ${event.filters}');
      emit(orderAllocationLoading());

      try {
        // Construct the API URL with filter parameters
     final url = Uri.parse(
            'http://localhost/AquavivaAPI/getOrderAllocation.php?'
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

            // Convert JSON data to orderAllocation objects
            final List<orderAllocation> orderAllocations = jsonList
                .map((json) => orderAllocation.fromJson(json))
                .toList();

            emit(orderAllocationLoaded(orderAllocations: orderAllocations));
          } else {
            emit(orderAllocationError('Failed to load sale orders: ${jsonResponse['status']}'));
          }
        } else {
          emit(orderAllocationError('Failed to load sale orders: ${response.statusCode}'));
        }
      } catch (e) {
        print('Error: $e');
        emit(orderAllocationError('An error occurred: $e'));
      }
    });
  }
}