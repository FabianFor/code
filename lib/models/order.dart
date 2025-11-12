import 'package:uuid/uuid.dart';

class OrderItem {
  String productId;
  String productName;
  double price;
  int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productName: json['productName'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
    );
  }
}

class Order {
  String id;
  List<OrderItem> items;
  DateTime createdAt;
  String status;

  Order({
    String? id,
    required this.items,
    DateTime? createdAt,
    this.status = 'pending',
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  double get total => items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((i) => i.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
    );
  }
}