import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double costPrice;
  final double sellingPrice;
  final int stock;
  final int minStock;
  final String unit; // pcs, kg, liter  
  final bool isActive;
  final Timestamp createdAt;
  final String createdBy;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.costPrice,
    required this.sellingPrice,
    required this.stock,
    required this.minStock,
    required this.unit,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
  });

  // Firestore se data laane ke liye
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      sku: map['sku'] ?? '',
      category: map['category'] ?? 'General',
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      minStock: map['minStock'] ?? 5,
      unit: map['unit'] ?? 'pcs',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  // Firestore mein save karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'minStock': minStock,
      'unit': unit,
      'isActive': isActive,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }

  // Profit calculate karne ke liye
  double get profit => sellingPrice - costPrice;
  double get profitPercent => costPrice > 0 ? (profit / costPrice) * 100 : 0;
  bool get isLowStock => stock <= minStock;
}