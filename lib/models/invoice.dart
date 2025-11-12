import 'order.dart';

class Invoice {
  String id;
  int invoiceNumber;
  String customerName;
  String customerPhone;
  List<OrderItem> items;
  DateTime createdAt;
  double total;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    this.customerPhone = '',
    required this.items,
    required this.createdAt,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'items': items.map((i) => i.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'total': total,
      };

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'] ?? '',
      items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      total: json['total'].toDouble(),
    );
  }
}