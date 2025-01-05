class SaleOrder {
  final String resultMsg;
  final String resultStatus;
  final String postingDate;
  final String recNo;
  final String branchCode;
  final String saleOrderNo;
  final String accountCode;
  final String accountName;
  final String customerPONo;
  final double grandTotal;
  final String? lc;
  final String authorize;
  final String? authorizeBy;
  final String? authorizeDateTime;
  final String salesManName;
  final String createdBy;
  final String addDate;
  final String groupName;
  final String filename1;

  SaleOrder({
    required this.resultMsg,
    required this.resultStatus,
    required this.postingDate,
    required this.recNo,
    required this.branchCode,
    required this.saleOrderNo,
    required this.accountCode,
    required this.accountName,
    required this.customerPONo,
    required this.grandTotal,
    this.lc,
    required this.authorize,
    this.authorizeBy,
    this.authorizeDateTime,
    required this.salesManName,
    required this.createdBy,
    required this.addDate,
    required this.groupName,
    required this.filename1,
  });

  factory SaleOrder.fromJson(Map<String, dynamic> json) {
    return SaleOrder(
      resultMsg: json['ResultMsg'],
      resultStatus: json['ResultStatus'],
      postingDate: json['PostingDate'],
      recNo: json['RecNo'],
      branchCode: json['BranchCode'],
      saleOrderNo: json['SaleOrderNo'],
      accountCode: json['AccountCode'],
      accountName: json['AccountName'],
      customerPONo: json['CustomerPONo'],
      grandTotal: double.parse(json['GrandTotal']),
      lc: json['LC'],
      authorize: json['Authorize'],
      authorizeBy: json['AuthorizeBy'],
      authorizeDateTime: json['AuthorizeDateTime'],
      salesManName: json['SalesManName'],
      createdBy: json['CreatedBy'],
      addDate: json['AddDate'],
      groupName: json['GroupName'],
      filename1: json['Filename1'],
    );
  }
}