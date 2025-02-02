import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';

// Events
abstract class UserGroupEvent extends Equatable {
  const UserGroupEvent();

  @override
  List<Object> get props => [];
}

class FetchUserGroups extends UserGroupEvent {} // Event to fetch user groups

class SelectUserGroup extends UserGroupEvent {
  final String userGroup;
  final String fieldId;
  const SelectUserGroup(this.userGroup, this.fieldId);

  @override
  List<Object> get props => [userGroup, fieldId];
}

// States
abstract class UserGroupState extends Equatable {
  const UserGroupState();

  @override
  List<Object> get props => [];
}

class UserGroupInitial extends UserGroupState {} // Initial state

class UserGroupLoading extends UserGroupState {} // Loading state

class UserGroupLoaded extends UserGroupState {
  final List<Map<String, dynamic>> userGroups;
  final String? selectedUserGroup;
  final String? selectedFieldId;
  const UserGroupLoaded(
    this.userGroups, {
    this.selectedUserGroup,
    this.selectedFieldId,
  });

  @override
  List<Object> get props =>
      [userGroups, selectedUserGroup ?? '', selectedFieldId ?? ''];
}

class UserGroupError extends UserGroupState {
  final String message;
  const UserGroupError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class UserGroupBloc extends Bloc<UserGroupEvent, UserGroupState> {
  final String companyCode;
  UserGroupBloc(this.companyCode) : super(UserGroupInitial()) {
    print("Initializing UserGroupBloc with companyCode: $companyCode");
    on<FetchUserGroups>(_onFetchUserGroups);
    on<SelectUserGroup>(_onSelectUserGroup);
  }

  Future<void> _onFetchUserGroups(
    FetchUserGroups event,
    Emitter<UserGroupState> emit,
  ) async {
    print("Fetching user groups for companyCode: $companyCode");
    emit(UserGroupLoading());
    try {
      final url = Uri.parse(
          'https://www.aquare.co.in/mobileAPI/CRM_getValues.php?type=sp_GetCommonTableData1&val1=UserGroupMaster_CRM&val2=UserGroupName&val3=RecNo&val4=$companyCode&str=eTFKdGFqMG5ibWN0NGJ4ekIxUG8zaHVzOCtsZ1ozMjVOazZMNWJoZmNrcHVVQ0dWSnM0d0RFS1VxUk5ZQThKdnNGM3RpR1QrZll1dWRNODFJMlFWaXc9PQ==');
      print("API URL: $url");
      final response = await http.get(url);
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<dynamic> data = json.decode(response.body);
          print("Decoded Data: $data");

          if (data is List) {
            final userGroups = data.map((group) {
              print("Processing group: $group"); // Debug log
              return {
                'FieldName': group['FieldName'] as String,
                'FieldId':
                    group['FieldID'].toString(), // Ensure String conversion
              };
            }).toList();

            emit(UserGroupLoaded(userGroups));
          } else {
            emit(UserGroupError('Invalid data format received from API'));
          }
        } else {
          emit(UserGroupError('Empty response received from API'));
        }
      } else {
        emit(UserGroupError(
            'Failed to load user groups: ${response.statusCode}'));
      }
    } catch (e) {
      emit(UserGroupError('An error occurred: $e'));
    }
  }

  void _onSelectUserGroup(
    SelectUserGroup event,
    Emitter<UserGroupState> emit,
  ) {
    print(
        "Selecting User Group: ${event.userGroup}, FieldId: ${event.fieldId}");
    if (state is UserGroupLoaded) {
      final currentState = state as UserGroupLoaded;
      emit(UserGroupLoaded(
        currentState.userGroups,
        selectedUserGroup: event.userGroup,
        selectedFieldId: event.fieldId,
      ));
    }
  }
}
