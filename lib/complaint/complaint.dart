class Complaint {
  final int sNo;
  final int recNo;
  final String entryDate;
  final String fromTime;
  final String toTime;
  final int rCode;
  final String rName;
  final String isComplaintType;
  final int complaintNo;
  final String isCustomerType;
  final String accountName;
  final String customerAddress;
  final int customerMobileNo;
  final String customerEmailID;
  final String itemName;
  final String complaintDetails;

  Complaint({
    required this.sNo,
    required this.recNo,
    required this.entryDate,
    required this.fromTime,
    required this.toTime,
    required this.rCode,
    required this.rName,
    required this.isComplaintType,
    required this.complaintNo,
    required this.isCustomerType,
    required this.accountName,
    required this.customerAddress,
    required this.customerMobileNo,
    required this.customerEmailID,
    required this.itemName,
    required this.complaintDetails,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      sNo: json['SNo'] ?? 0,
      recNo: json['RecNo'] ?? 0,
      entryDate: json['EntryDate'] ?? 'Unknown Date',
      fromTime: json['FromTime'] ?? '',
      toTime: json['ToTime'] ?? '',
      rCode: json['RCode'] ?? 0,
      rName: json['RName'] ?? 'Unknown Name',
      isComplaintType: json['IsComplaintType'] ?? 'Unknown',
      complaintNo: json['ComplaintNo'] ?? 0,
      isCustomerType: json['IsCustomerType'] ?? 'Unknown',
      accountName: json['AccountName'] ?? 'Unknown Account',
      customerAddress: json['CustomerAddress'] ?? 'Unknown Address',
      customerMobileNo: json['CustomerMobileNo'] ?? 0,
      customerEmailID: json['CustomerEmailID'] ?? '',
      itemName: json['ItemName'] ?? 'Unknown Item',
      complaintDetails: json['ComplaintDetails'] ?? 'No Details Provided',
    );
  }
}
