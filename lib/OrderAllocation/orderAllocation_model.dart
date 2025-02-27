class orderAllocation {
  final String resultMsg;
  final String resultStatus;
  final String orderNo;
  final String orderDate;
  final String accountName;
  final String? itemCode;  // Made optional as placeholder
  final String itemName;
  final String? closingStock;  // Made optional as placeholder
  final String qty;
  final double netRate;
  final double value;
  final double grandTotal;
  final double dispatchValue;
  final String allocatedOn;
  final String qtyAllocated;

  orderAllocation({
    required this.resultMsg,
    required this.resultStatus,
    required this.orderNo,
    required this.orderDate,
    required this.accountName,
    this.itemCode,  // Optional, not required
    required this.itemName,
    this.closingStock,  // Optional, not required
    required this.qty,
    required this.netRate,
    required this.value,
    required this.grandTotal,
    required this.dispatchValue,
    required this.allocatedOn,
    required this.qtyAllocated,
  });

  factory orderAllocation.fromJson(Map<String, dynamic> json) {
    return orderAllocation(
      resultMsg: json['ResultMsg'] ?? '',
      resultStatus: json['ResultStatus'] ?? '',
      orderNo: json['OrderNo'] ?? '',
      orderDate: json['OrderDate'] ?? '',
      accountName: json['AccountName'] ?? '',
      // itemCode is not included from JSON as it's a placeholder
      itemName: json['ItemName'] ?? '',
      // closingStock is not included from JSON as it's a placeholder
      qty: json['Qty'] ?? '0.0',
      netRate: double.tryParse(json['NetRate'] ?? '0') ?? 0.0,
      value: double.tryParse(json['Value'] ?? '0') ?? 0.0,
      grandTotal: double.tryParse(json['GrandTotal'] ?? '0') ?? 0.0,
      dispatchValue: double.tryParse(json['DispatchValue'] ?? '0') ?? 0.0,
      allocatedOn: json['ALLOCATED_ON'] ?? '',
      qtyAllocated: json['QTY_ALLOCATED'] ?? '0.0',
    );
  }
}