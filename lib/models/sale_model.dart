import 'package:cloud_firestore/cloud_firestore.dart';

class SaleItemModel {
  final String productId;
  final String productName;
  final String sku;
  final double price;
  final int quantity;
  final double total;

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.price,
    required this.quantity,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'sku': sku,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      sku: map['sku'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      total: (map['total'] ?? 0).toDouble(),
    );
  }
}

class SaleModel {
  final String id;
  final String invoiceNumber;
  final List<SaleItemModel> items;
  final double subtotal;
  final double discount;
  final double total;
  final String paymentMethod; // Cash, Card, UPI
  final String customerName;
  final Timestamp createdAt;
  final String createdBy;
  final bool isActive;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.customerName,
    required this.createdAt,
    required this.createdBy,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'customerName': customerName,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'isActive': isActive,
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      items: List<SaleItemModel>.from(map['items']?.map((x) => SaleItemModel.fromMap(x)) ?? []),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      customerName: map['customerName'] ?? 'Walk-in',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      createdBy: map['createdBy'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}