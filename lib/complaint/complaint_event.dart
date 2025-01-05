import 'package:equatable/equatable.dart';

abstract class ComplaintEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchComplaints extends ComplaintEvent {}


