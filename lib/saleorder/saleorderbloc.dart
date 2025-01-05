import 'package:bloc/bloc.dart';
import 'package:client/saleorder/sale_model.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Events
abstract class SaleOrderEvent extends Equatable {
  const SaleOrderEvent();

  @override
  List<Object> get props => [];
}

class FetchSaleOrderEvent extends SaleOrderEvent {}

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
      emit(SaleOrderLoading());

      try {
        final url = Uri.parse(
            'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?val1=157.0&val2=E&val3=0&val4=01-Jan-2025&val5=04-Jan-2025&val6=&val7=1&val8=&val9=&val10=&val11=&type=sp_GetSaleOrderDetails&str=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ==');

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(response.body);
          final saleOrders = jsonList
              .map((json) => SaleOrder.fromJson(json))
              .toList();

          emit(SaleOrderLoaded(saleOrders: saleOrders));
        } else {
          emit(SaleOrderError('Failed to load sale orders: ${response.statusCode}'));
        }
      } catch (e) {
        emit(SaleOrderError('An error occurred: $e'));
      }
    });
  }
}