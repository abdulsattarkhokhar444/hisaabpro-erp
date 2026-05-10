import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../../models/sale_model.dart';
import '../../services/product_service.dart';
import '../../services/sale_service.dart';
import '../../theme/app_theme.dart';

class SalesManagement extends StatefulWidget {
  const SalesManagement({super.key});

  @override
  State<SalesManagement> createState() => _SalesManagementState();
}

class _SalesManagementState extends State<SalesManagement> {
  final ProductService _productService = ProductService();
  final SaleService _saleService = SaleService();
  
  final List<SaleItemModel> _cart = [];
  final double _discount = 0;
  String _paymentMethod = 'Cash';
  final _customerController = TextEditingController(text: 'Walk-in');

  double get _subtotal => _cart.fold(0, (current, item) => current + item.total);
  double get _total => _subtotal - _discount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mintTeal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.teal600),
                  ),
                  Text('Sales - A05', style: AppTheme.lightTheme.textTheme.displaySmall),
                  IconButton(
                    onPressed: _cart.isEmpty? null : () => _showCheckoutDialog(),
                    icon: Icon(Icons.shopping_cart_checkout, 
                      color: _cart.isEmpty? Colors.grey : AppTheme.teal600, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cart Summary Card
              _buildGlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cart Items: ${_cart.length}', style: AppTheme.lightTheme.textTheme.titleMedium),
                        Text('Total: Rs ${_total.toStringAsFixed(0)}', 
                          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: AppTheme.teal600)),
                      ],
                    ),
                    if (_cart.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(() => _cart.clear()),
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Products List
              Expanded(
                child: StreamBuilder<List<ProductModel>>(
                  stream: _productService.getAllProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.teal600));
                    }
                    final products = snapshot.data?? [];
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return _buildProductTile(products[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductTile(ProductModel product) {
    final inCart = _cart.any((item) => item.productId == product.id);
    final cartQty = _cart.firstWhere((item) => item.productId == product.id, 
      orElse: () => SaleItemModel(productId: '', productName: '', sku: '', price: 0, quantity: 0, total: 0)).quantity;

    return GestureDetector(
      onTap: product.stock > 0? () => _addToCart(product) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: AppTheme.glassCard.copyWith(
              border: inCart? Border.all(color: AppTheme.teal600, width: 2) : null,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, 
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text('Rs ${product.sellingPrice.toStringAsFixed(0)}', 
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(color: AppTheme.teal600)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Stock: ${product.stock}', 
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: product.isLowStock? Colors.red : Colors.black54)),
                    if (inCart)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.teal600,
                          shape: BoxShape.circle,
                        ),
                        child: Text('$cartQty', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addToCart(ProductModel product) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item.productId == product.id);
      if (existingIndex >= 0) {
        final item = _cart[existingIndex];
        if (item.quantity < product.stock) {
          _cart[existingIndex] = SaleItemModel(
            productId: item.productId,
            productName: item.productName,
            sku: item.sku,
            price: item.price,
            quantity: item.quantity + 1,
            total: (item.quantity + 1) * item.price,
          );
        }
      } else {
        _cart.add(SaleItemModel(
          productId: product.id,
          productName: product.name,
          sku: product.sku,
          price: product.sellingPrice,
          quantity: 1,
          total: product.sellingPrice,
        ));
      }
    });
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.mintTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('Checkout', style: AppTheme.lightTheme.textTheme.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items: ${_cart.length} | Subtotal: Rs ${_subtotal.toStringAsFixed(0)}'),
                Text('Discount: Rs ${_discount.toStringAsFixed(0)}'),
                Text('Total: Rs ${_total.toStringAsFixed(0)}', 
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(color: AppTheme.teal600)),
                const SizedBox(height: 16),
                TextField(
                  controller: _customerController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  items: ['Cash', 'Card', 'UPI'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setDialogState(() => _paymentMethod = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final sale = SaleModel(
                  id: '',
                  invoiceNumber: '',
                  items: _cart,
                  subtotal: _subtotal,
                  discount: _discount,
                  total: _total,
                  paymentMethod: _paymentMethod,
                  customerName: _customerController.text,
                  createdAt: Timestamp.now(),
                  createdBy: '',
                  isActive: true,
                );
                await _saleService.createSale(sale);
                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() => _cart.clear());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sale completed! Stock updated.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teal600),
              child: const Text('Complete Sale', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: AppTheme.glassCard,
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}