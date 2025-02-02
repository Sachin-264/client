import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<FetchSearchData>(_onFetchSearchData);
    on<SaveChanges>(_onSaveChanges);
  }

  Future<void> _onFetchSearchData(
    FetchSearchData event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final response = await http.get(Uri.parse(
        'https://www.aquare.co.in/mobileAPI/CRM_getValues.php?type=sp_GetUserGroupRightCRMDetails&val1=${event.companyCode}&val2=${event.fieldId}&str=${event.str}',
      ));
      log('api url: ${response.request?.url}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        emit(SearchLoaded(data.cast<Map<String, dynamic>>()));
      } else {
        emit(SearchError('Failed to load data'));
      }
    } catch (e) {
      emit(SearchError('An error occurred: $e'));
    }
  }

  Future<void> _onSaveChanges(
    SaveChanges event,
    Emitter<SearchState> emit,
  ) async {
    try {
      emit(SearchLoading());

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'type': 'UserGroupRight',
        'UserCode': '1', // val1
        'UserGroupCode': event.fieldId, // val2 dropdown value
        'UserCompanyCode': event.companyCode,
        'UserGroupRightDetails': json.encode(event.updatedData
            .map((item) => {
                  'MenuCode': item['MenuCode'],
                  'ShowMenu': item['ShowMenu'],
                  'CanAdd': item['CanAdd'],
                  'CanEdit': item['CanEdit'],
                  'CanDelete': item['CanDelete'],
                  'CanPrint': item['CanPrint'],
                  'CanExport': item['CanExport'],
                })
            .toList()),

        'str': event.str, // Pass the str parameter
      };

      // Log request body before sending
      debugPrint('Sending Request Body: ${json.encode(requestBody)}');

      // Send request to API
      final response = await http.post(
        Uri.parse('https://www.aquare.co.in/mobileAPI/CRM_AddMasterEntry.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      // Log API response
      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      // Decode response
      final List<dynamic> responseData = json.decode(response.body);

      if (responseData.isNotEmpty &&
          responseData.first is Map<String, dynamic>) {
        final Map<String, dynamic> result = responseData.first;

        final String resultMsg = result['ResultMsg'] ?? 'Unknown error';
        final String resultStatus = result['ResultStatus'] ?? 'Error';

        if (resultStatus == "Success") {
          emit(SearchSuccess(message: resultMsg));
        } else {
          emit(SearchError(resultMsg));
        }
      } else {
        emit(SearchError('Invalid response format from API.'));
      }
    } catch (error, stackTrace) {
      debugPrint('Error during API call: $error');
      debugPrint(stackTrace.toString());
      emit(SearchError('An unexpected error occurred.'));
    }
  }
}

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class FetchSearchData extends SearchEvent {
  final String companyCode;
  final String userCode;
  final String str;
  final String fieldId; // Add FieldId

  FetchSearchData({
    Key? key,
    required this.companyCode,
    required this.userCode,
    required this.str,
    required this.fieldId,
  });

  @override
  List<Object> get props => [companyCode, userCode, str, fieldId];
}

class SaveChanges extends SearchEvent {
  final List<Map<String, dynamic>> updatedData;
  final String companyCode;
  final String userCode;
  final String str;
  final String fieldId; // Add FieldId
  const SaveChanges({
    required this.updatedData,
    required this.companyCode,
    required this.userCode,
    required this.str,
    required this.fieldId,
  });

  @override
  List<Object> get props => [updatedData];
}

// States
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Map<String, dynamic>> data;
  const SearchLoaded(this.data);

  @override
  List<Object> get props => [data];
}

// searchsucess
class SearchSuccess extends SearchState {
  final String message;
  const SearchSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}
