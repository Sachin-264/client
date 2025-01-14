import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON parsing

/// abhi static date jaa rhi hai

// Events
abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object> get props => [];
}

class FetchInvoiceEvent extends InvoiceEvent {}

// States
abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<Invoice> invoices;

  const InvoiceLoaded({required this.invoices});

  @override
  List<Object> get props => [invoices];
}

class InvoiceError extends InvoiceState {
  final String errorMessage;

  const InvoiceError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

// Model
class Invoice {
  final String recNo;
  final String branchCode;
  final String invoiceNo;
  final String invoiceDate;
  final String accountName;
  final double grandTotal;
  final String lc;
  final String salesManName;
  final String addUserName;
  final String addDate;

  Invoice({
    required this.recNo,
    required this.branchCode,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.accountName,
    required this.grandTotal,
    required this.lc,
    required this.salesManName,
    required this.addUserName,
    required this.addDate,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      recNo: json['RecNo'],
      branchCode: json['BranchCode'],
      invoiceNo: json['InvoiceNo'],
      invoiceDate: json['InvoiceDate'],
      accountName: json['AccountName'],
      grandTotal: double.parse(json['GrandTotal']),
      lc: json['LC'],
      salesManName: json['SalesManName'],
      addUserName: json['AddUserName'],
      addDate: json['AddDate'],
    );
  }
}

// Bloc
class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  InvoiceBloc() : super(InvoiceInitial()) {
    on<FetchInvoiceEvent>((event, emit) async {
      emit(InvoiceLoading());

      try {
        // Replace with your API endpoint
        final url = Uri.parse(
            'https://www.aquare.co.in/mobileAPI/ERP_getValues.php?val1=157.0&val2=E&val3=01-Jan-2025&val4=04-Jan-2025&val5=&val6=&val7=&type=sp_GetPerformaInvoiceDetails&str=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zbzRrNXZFbGQxaW96dHpteFFQdEdWQ2kzcnNBQlk1b1BpYW0wNy80Q3FXNlFwVnF6Zkl4ZzU1dU9ZS1lwWWxqUWc9PQ==');

        final response = await http.get(url);

        if (response.statusCode == 200) {
          // Parse the JSON response
          final List<dynamic> jsonList = json.decode(response.body);
          final invoices =
              jsonList.map((json) => Invoice.fromJson(json)).toList();

          emit(InvoiceLoaded(invoices: invoices));
        } else {
          emit(InvoiceError('Failed to load invoices: ${response.statusCode}'));
        }
      } catch (e) {
        emit(InvoiceError('An error occurred: $e'));
      }
    });
  }
}
