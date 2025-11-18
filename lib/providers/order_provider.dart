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

  /// Agregar item al carrito con validación de stock
  bool addItemToCurrentOrder(OrderItem item, int availableStock) {
    final existingIndex = _currentOrderItems.indexWhere(
      (i) => i.productId == item.productId,
    );

    if (existingIndex != -1) {
      final newQuantity = _currentOrderItems[existingIndex].quantity + item.quantity;
      
      if (newQuantity > availableStock) {
        return false;
      }
      
      _currentOrderItems[existingIndex].quantity = newQuantity;
    } else {
      if (item.quantity > availableStock) {
        return false;
      }
      
      _currentOrderItems.add(item);
    }
    
    notifyListeners();
    return true;
  }

  void removeItemFromCurrentOrder(String productId) {
    _currentOrderItems.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }

  /// Actualizar cantidad con validación de stock
  bool updateItemQuantity(String productId, int quantity, int availableStock) {
    final index = _currentOrderItems.indexWhere((i) => i.productId == productId);
    
    if (index != -1) {
      if (quantity > 0) {
        if (quantity > availableStock) {
          return false;
        }
        
        _currentOrderItems[index].quantity = quantity;
      } else {
        _currentOrderItems.removeAt(index);
      }
      notifyListeners();
      return true;
    }
    
    return false;
  }

  /// Validar todo el carrito antes de crear boleta
  String? validateCurrentOrder(Function(String) getStock) {
    for (final item in _currentOrderItems) {
      final availableStock = getStock(item.productId);
      
      if (availableStock == null) {
        return 'Producto "${item.productName}" no encontrado';
      }
      
      if (item.quantity > availableStock) {
        return 'Stock insuficiente para "${item.productName}". '
            'Disponible: $availableStock, Solicitado: ${item.quantity}';
      }
    }
    
    return null;
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

  /// ✅ ARREGLADO: Limpiar carrito completamente
  void clearCurrentOrder() {
    _currentOrderItems.clear();
    notifyListeners();
    print('🧹 Carrito limpiado completamente');
  }

  /// Obtener copia de los items actuales (para crear boleta)
  /// Esto devuelve una copia, no la referencia original
  List<OrderItem> getCurrentOrderItemsCopy() {
    return _currentOrderItems.map((item) {
      return OrderItem(
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: item.quantity,
      );
    }).toList();
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }
}