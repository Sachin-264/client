
import 'package:equatable/equatable.dart';

abstract class ComplaintEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchComplaints extends ComplaintEvent {}

class DeleteComplaint extends ComplaintEvent {
  final int complaintNo;

  DeleteComplaint({required this.complaintNo});

  @override
  List<Object?> get props => [complaintNo];
}
