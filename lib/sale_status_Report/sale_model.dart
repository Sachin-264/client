class SaleOrder {
  final String resultMsg;
  final String resultStatus;
  final String orderNo;
  final String orderDate;
  final String customerPONo;
  final String customerPODate;
  final String accountName;
  final String saleManager;
  final String salesManName;
  final String itemName;
  final String qty;
  final double value;
  final double grandTotal;
  final double dispatchValue;
  final String deliveryDate;
  final String ldyn;
  final String ldPer;
  final String eva;
  final String esm;
  final String ava;
  final String asm;
  final String quotationNo;
  final String inquiryNo;

  SaleOrder({
    required this.resultMsg,
    required this.resultStatus,
    required this.orderNo,
    required this.orderDate,
    required this.customerPONo,
    required this.customerPODate,
    required this.accountName,
    required this.saleManager,
    required this.salesManName,
    required this.itemName,
    required this.qty,
    required this.value,
    required this.grandTotal,
    required this.dispatchValue,
    required this.deliveryDate,
    required this.ldyn,
    required this.ldPer,
    required this.eva,
    required this.esm,
    required this.ava,
    required this.asm,
    required this.quotationNo,
    required this.inquiryNo,
  });

  factory SaleOrder.fromJson(Map<String, dynamic> json) {
    return SaleOrder(
      resultMsg: json['ResultMsg'] ?? '',
      resultStatus: json['ResultStatus'] ?? '',
      orderNo: json['OrderNo'] ?? '',
      orderDate: json['OrderDate'] ?? '',
      customerPONo: json['CustomerPONo'] ?? '',
      customerPODate: json['CustomerPODate'] ?? '',
      accountName: json['AccountName'] ?? '',
      saleManager: json['SaleManager'] ?? '',
      salesManName: json['SalesManName'] ?? '',
      itemName: json['ItemName'] ?? '',
      qty: json['Qty'] ?? '',
      value: double.tryParse(json['Value'] ?? '0') ?? 0.0,
      grandTotal: double.tryParse(json['GrandTotal'] ?? '0') ?? 0.0,
      dispatchValue: double.tryParse(json['DispatchValue'] ?? '0') ?? 0.0,
      deliveryDate: json['DeliveryDate'] ?? '',
      ldyn: json['LDYN'] ?? '',
      ldPer: json['LDPer'] ?? '',
      eva: json['EVA'] ?? '',
      esm: json['ESM'] ?? '',
      ava: json['AVA'] ?? '',
      asm: json['ASM'] ?? '',
      quotationNo: json['QuotationNo'] ?? '',
      inquiryNo: json['InquiryNo'] ?? '',
    );
  }
}