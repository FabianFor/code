import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products;

  int get totalProducts => _products.length;

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('products');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _products = jsonList.map((json) => Product.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_products.map((p) => p.toJson()).toList());
    await prefs.setString('products', jsonString);
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      await _saveProducts();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await _saveProducts();
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}