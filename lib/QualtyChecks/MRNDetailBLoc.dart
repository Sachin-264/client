import 'package:equatable/equatable.dart';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

// event

abstract class MRNDetailEvent extends Equatable {
  const MRNDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchMRNDetailEvent extends MRNDetailEvent {
  final String branchCode;
  final String itemNo;

  const FetchMRNDetailEvent({required this.branchCode, required this.itemNo});

  @override
  List<Object> get props => [branchCode, itemNo];
}

// state

abstract class MRNDetailState extends Equatable {
  const MRNDetailState();

  @override
  List<Object> get props => [];
}

class MRNDetailInitial extends MRNDetailState {}

class MRNDetailLoading extends MRNDetailState {}

class MRNDetailLoaded extends MRNDetailState {
  final List<Map<String, dynamic>> qualityParameters;

  const MRNDetailLoaded({required this.qualityParameters});

  @override
  List<Object> get props => [qualityParameters];
}

class MRNDetailError extends MRNDetailState {
  final String message;

  const MRNDetailError({required this.message});

  @override
  List<Object> get props => [message];
}

/// bloc

class MRNDetailBloc extends Bloc<MRNDetailEvent, MRNDetailState> {
  MRNDetailBloc() : super(MRNDetailInitial()) {
    on<FetchMRNDetailEvent>(_onFetchMRNDetail);
  }

  Future<void> _onFetchMRNDetail(
      FetchMRNDetailEvent event, Emitter<MRNDetailState> emit) async {
    emit(MRNDetailLoading());
    try {
      final response = await http.get(Uri.parse(
          'http://localhost/AquavivaAPI/get_item_quality_parameter.php?BranchCode=${event.branchCode}&itemNo=${event.itemNo}'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> qualityParameters =
            data.map((item) => item as Map<String, dynamic>).toList();
        emit(MRNDetailLoaded(qualityParameters: qualityParameters));
      } else {
        emit(MRNDetailError(message: 'Failed to load quality parameters'));
      }
    } catch (e) {
      emit(MRNDetailError(message: e.toString()));
    }
  }
}
