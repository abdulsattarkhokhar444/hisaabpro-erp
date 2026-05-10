import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key}); 

  @override
  State<ProductManagement> createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  final ProductService _productService = ProductService();

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
                  Text('Products - A03', style: AppTheme.lightTheme.textTheme.displaySmall),
                  IconButton(
                    onPressed: () => _showAddProductDialog(context),
                    icon: const Icon(Icons.add_circle, color: AppTheme.teal600, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
                    final products = snapshot.data ?? [];
                    if (products.isEmpty) {
                      return Center(
                        child: Text('No products yet. Tap + to add.', 
                          style: AppTheme.lightTheme.textTheme.bodyLarge),
                      );
                    }
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(products[index]);
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

  Widget _buildProductCard(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: AppTheme.glassCard,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: AppTheme.lightTheme.textTheme.titleLarge),
                          Text('SKU: ${product.sku}', style: AppTheme.lightTheme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    if (product.isLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('LOW STOCK', style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(color: Colors.red)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip('Stock', '${product.stock} ${product.unit}'),
                    _buildInfoChip('Cost', 'Rs ${product.costPrice.toStringAsFixed(0)}'),
                    _buildInfoChip('Price', 'Rs ${product.sellingPrice.toStringAsFixed(0)}'),
                    _buildInfoChip('Profit', '${product.profitPercent.toStringAsFixed(0)}%'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTheme.lightTheme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(color: AppTheme.teal600)),
      ],
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final skuController = TextEditingController();
    final costController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    String selectedCategory = 'General';
    String selectedUnit = 'pcs';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mintTeal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Add Product', style: AppTheme.lightTheme.textTheme.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Product Name'),
              const SizedBox(height: 12),
              _buildTextField(skuController, 'SKU / Barcode'),
              const SizedBox(height: 12),
              _buildTextField(costController, 'Cost Price', isNumber: true),
              const SizedBox(height: 12),
              _buildTextField(priceController, 'Selling Price', isNumber: true),
              const SizedBox(height: 12),
              _buildTextField(stockController, 'Opening Stock', isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final product = ProductModel(
                id: '',
                name: nameController.text,
                sku: skuController.text,
                category: selectedCategory,
                costPrice: double.tryParse(costController.text) ?? 0,
                sellingPrice: double.tryParse(priceController.text) ?? 0,
                stock: int.tryParse(stockController.text) ?? 0,
                minStock: 5,
                unit: selectedUnit,
                isActive: true,
                createdAt: Timestamp.now(),
                createdBy: '',
              );
              await _productService.addProduct(product);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teal600),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}