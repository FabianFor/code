import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/invoice_provider.dart';
import '../models/order.dart';
import 'dart:io';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final filteredProducts = productProvider.products.where((product) {
      return _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Pedido', style: TextStyle(fontSize: 18.sp)),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          if (orderProvider.currentOrderItems.isNotEmpty) ...[
            IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.shopping_cart, size: 24.sp),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.w,
                        minHeight: 16.h,
                      ),
                      child: Text(
                        '${orderProvider.currentOrderItems.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () => _showCurrentOrderSheet(context),
              tooltip: 'Ver carrito',
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep, size: 24.sp),
              onPressed: () => _confirmClearOrder(context),
              tooltip: 'Vaciar carrito',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, size: 20.sp),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),

          // Product List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.shopping_cart_outlined,
                          size: 80.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No se encontraron productos'
                              : 'No hay productos disponibles',
                          style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: Icon(Icons.clear, size: 18.sp),
                            label: Text('Limpiar búsqueda',
                                style: TextStyle(fontSize: 14.sp)),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final inCart = orderProvider.currentOrderItems
                          .any((item) => item.productId == product.id);

                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        color: inCart ? Colors.blue[50] : Colors.white,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12.w),
                          leading: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: product.imagePath.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.file(
                                      File(product.imagePath),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.broken_image,
                                            size: 30.sp, color: Colors.grey);
                                      },
                                    ),
                                  )
                                : Icon(Icons.inventory_2,
                                    size: 30.sp, color: Colors.grey),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (inCart)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    'En carrito',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF4CAF50),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    product.category,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Stock: ${product.stock}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: product.stock <= 5
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontWeight: product.stock <= 5
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: product.stock > 0
                                ? () {
                                    final orderProvider = Provider.of<OrderProvider>(
                                        context,
                                        listen: false);
                                    
                                    final added = orderProvider.addItemToCurrentOrder(
                                      OrderItem(
                                        productId: product.id,
                                        productName: product.name,
                                        price: product.price,
                                        quantity: 1,
                                      ),
                                      product.stock,
                                    );

                                    if (added) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${product.name} agregado',
                                              style: TextStyle(fontSize: 14.sp)),
                                          duration: const Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '❌ Stock insuficiente para ${product.name}',
                                              style: TextStyle(fontSize: 14.sp)),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                            ),
                            child: Text(
                              product.stock > 0 ? '+ Agregar' : 'Sin stock',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Current Order Summary
          if (orderProvider.currentOrderItems.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Items: ${orderProvider.currentOrderItems.length}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Total: \$${orderProvider.currentOrderTotal.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _showCurrentOrderSheet(context),
                            icon: Icon(Icons.visibility, size: 18.sp),
                            label: Text('Ver', style: TextStyle(fontSize: 13.sp)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2196F3),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateInvoiceDialog(context),
                            icon: Icon(Icons.receipt_long, size: 18.sp),
                            label: Text('Crear Boleta',
                                style: TextStyle(fontSize: 13.sp)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showCurrentOrderSheet(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<OrderProvider>(
            builder: (context, provider, child) {
              return Container(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Carrito de Pedido',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 24.sp),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: provider.currentOrderItems.isEmpty
                          ? Center(
                              child: Text(
                                'El carrito está vacío',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: provider.currentOrderItems.length,
                              itemBuilder: (context, index) {
                                final item = provider.currentOrderItems[index];
                                final product = productProvider.getProductById(item.productId);
                                final availableStock = product?.stock ?? 0;
                                
                                return Card(
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.productName,
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Stock disponible: $availableStock',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, size: 20.sp),
                                              color: Colors.red,
                                              onPressed: () {
                                                provider.removeItemFromCurrentOrder(
                                                    item.productId);
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.remove, size: 18.sp),
                                                  onPressed: item.quantity > 1
                                                      ? () {
                                                          provider
                                                              .updateItemQuantity(
                                                            item.productId,
                                                            item.quantity - 1,
                                                            availableStock,
                                                          );
                                                        }
                                                      : null,
                                                  style: IconButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    foregroundColor: Colors.black,
                                                    padding: EdgeInsets.all(8.w),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Text(
                                                  '${item.quantity}',
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                IconButton(
                                                  icon: Icon(Icons.add, size: 18.sp),
                                                  onPressed: () {
                                                    final success = provider.updateItemQuantity(
                                                      item.productId,
                                                      item.quantity + 1,
                                                      availableStock,
                                                    );
                                                    
                                                    if (!success) {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              '❌ Stock insuficiente. Disponible: $availableStock',
                                                              style: TextStyle(
                                                                  fontSize: 14.sp)),
                                                          backgroundColor: Colors.red,
                                                          duration:
                                                              const Duration(seconds: 2),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  style: IconButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF2196F3),
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.all(8.w),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '\$${item.price.toStringAsFixed(0)} c/u',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Text(
                                                  '\$${item.total.toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF4CAF50),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${provider.currentOrderTotal.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmClearOrder(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text('Vaciar', style: TextStyle(fontSize: 15.sp)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showCreateInvoiceDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text('Crear Boleta',
                                style: TextStyle(fontSize: 15.sp)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmClearOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24.sp),
            SizedBox(width: 12.w),
            Text('Vaciar carrito', style: TextStyle(fontSize: 18.sp)),
          ],
        ),
        content: Text(
          '¿Estás seguro de vaciar el carrito? Se perderán todos los items.',
          style: TextStyle(fontSize: 15.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<OrderProvider>(context, listen: false).clearCurrentOrder();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Carrito vaciado',
                      style: TextStyle(fontSize: 14.sp)),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Vaciar', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  void _showCreateInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Crear Boleta', style: TextStyle(fontSize: 18.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Nombre del Cliente *',
                labelStyle: TextStyle(fontSize: 14.sp),
                hintText: 'Ej: Juan Pérez',
                hintStyle: TextStyle(fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: Icon(Icons.person, size: 20.sp),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _customerPhoneController,
              decoration: InputDecoration(
                labelText: 'Teléfono (opcional)',
                labelStyle: TextStyle(fontSize: 14.sp),
                hintText: '123456789',
                hintStyle: TextStyle(fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: Icon(Icons.phone, size: 20.sp),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_customerNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '⚠️ Por favor ingresa el nombre del cliente',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final orderProvider =
                  Provider.of<OrderProvider>(context, listen: false);
              final productProvider =
                  Provider.of<ProductProvider>(context, listen: false);
              final invoiceProvider =
                  Provider.of<InvoiceProvider>(context, listen: false);

              // Validar stock
              final errorMessage = orderProvider.validateCurrentOrder(
                (productId) => productProvider.getProductById(productId)?.stock,
              );

              if (errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ $errorMessage',
                        style: TextStyle(fontSize: 14.sp)),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
                return;
              }

              // Reducir stock
              for (final item in orderProvider.currentOrderItems) {
                await productProvider.reduceStock(
                  item.productId,
                  item.quantity,
                );
              }

              // ✅ ARREGLADO: Crear boleta con COPIA de items
              await invoiceProvider.createInvoice(
                customerName: _customerNameController.text.trim(),
                customerPhone: _customerPhoneController.text.trim(),
                items: orderProvider.getCurrentOrderItemsCopy(), // ✅ Copia, no referencia
              );

              // Limpiar carrito DESPUÉS de crear la boleta
              orderProvider.clearCurrentOrder();
              _customerNameController.clear();
              _customerPhoneController.clear();

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '✅ Boleta creada y stock actualizado',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            child: Text('Crear', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}