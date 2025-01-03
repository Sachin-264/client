
import 'package:equatable/equatable.dart';
import 'complaint.dart';

abstract class ComplaintState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ComplaintInitial extends ComplaintState {}

class ComplaintLoading extends ComplaintState {}

class ComplaintLoaded extends ComplaintState {
  final List<Complaint> complaints;

  ComplaintLoaded({required this.complaints});

  @override
  List<Object?> get props => [complaints];
}

class ComplaintError extends ComplaintState {
  final String message;

  ComplaintError({required this.message});

  @override
  List<Object?> get props => [message];
}
