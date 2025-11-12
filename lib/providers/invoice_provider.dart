import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice.dart';
import '../models/order.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> _invoices = [];
  int _lastInvoiceNumber = 2517;

  List<Invoice> get invoices => _invoices;
  int get totalInvoices => _invoices.length;

  double get totalRevenue =>
      _invoices.fold(0, (sum, invoice) => sum + invoice.total);

  Future<void> loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('invoices');
    final lastNumber = prefs.getInt('last_invoice_number');

    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _invoices = jsonList.map((json) => Invoice.fromJson(json)).toList();
    }

    if (lastNumber != null) {
      _lastInvoiceNumber = lastNumber;
    }

    notifyListeners();
  }

  Future<void> _saveInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_invoices.map((i) => i.toJson()).toList());
    await prefs.setString('invoices', jsonString);
    await prefs.setInt('last_invoice_number', _lastInvoiceNumber);
  }

  Future<Invoice> createInvoice({
    required String customerName,
    required String customerPhone,
    required List<OrderItem> items,
  }) async {
    _lastInvoiceNumber++;

    final invoice = Invoice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNumber: _lastInvoiceNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      createdAt: DateTime.now(),
      total: items.fold(0, (sum, item) => sum + item.total),
    );

    _invoices.insert(0, invoice);
    await _saveInvoices();
    notifyListeners();
    return invoice;
  }

  Invoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }
}