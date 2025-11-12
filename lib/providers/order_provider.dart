import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  List<OrderItem> _currentOrderItems = [];

  List<Order> get orders => _orders;
  List<OrderItem> get currentOrderItems => _currentOrderItems;
  int get totalOrders => _orders.length;

  double get currentOrderTotal =>
      _currentOrderItems.fold(0, (sum, item) => sum + item.total);

  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('orders');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _orders = jsonList.map((json) => Order.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_orders.map((o) => o.toJson()).toList());
    await prefs.setString('orders', jsonString);
  }

  void addItemToCurrentOrder(OrderItem item) {
    final existingIndex = _currentOrderItems.indexWhere(
      (i) => i.productId == item.productId,
    );

    if (existingIndex != -1) {
      _currentOrderItems[existingIndex].quantity += item.quantity;
    } else {
      _currentOrderItems.add(item);
    }
    notifyListeners();
  }

  void removeItemFromCurrentOrder(String productId) {
    _currentOrderItems.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }

  void updateItemQuantity(String productId, int quantity) {
    final index = _currentOrderItems.indexWhere((i) => i.productId == productId);
    if (index != -1) {
      if (quantity > 0) {
        _currentOrderItems[index].quantity = quantity;
      } else {
        _currentOrderItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  Future<Order> createOrder() async {
    if (_currentOrderItems.isEmpty) {
      throw Exception('No hay items en el pedido');
    }

    final order = Order(items: List.from(_currentOrderItems));
    _orders.add(order);
    _currentOrderItems.clear();
    await _saveOrders();
    notifyListeners();
    return order;
  }

  void clearCurrentOrder() {
    _currentOrderItems.clear();
    notifyListeners();
  }
}