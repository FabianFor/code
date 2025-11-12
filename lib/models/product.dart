import 'package:uuid/uuid.dart';

class Product {
  String id;
  String name;
  double price;
  String description;
  String category;
  int stock;
  String imagePath;

  Product({
    String? id,
    required this.name,
    required this.price,
    this.description = '',
    this.category = 'Sin categoría',
    this.stock = 0,
    this.imagePath = '',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'category': category,
        'stock': stock,
        'imagePath': imagePath,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? 'Sin categoría',
      stock: json['stock'] ?? 0,
      imagePath: json['imagePath'] ?? '',
    );
  }

  Product copyWith({
    String? name,
    double? price,
    String? description,
    String? category,
    int? stock,
    String? imagePath,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}