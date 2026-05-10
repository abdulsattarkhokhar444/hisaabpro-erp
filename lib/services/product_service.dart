import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Naya Product Add Karna
  Future<void> addProduct(ProductModel product) async {
    final docRef = _firestore.collection('products').doc();
    final newProduct = ProductModel(
      id: docRef.id,
      name: product.name,
      sku: product.sku,
      category: product.category,
      costPrice: product.costPrice,
      sellingPrice: product.sellingPrice,
      stock: product.stock,
      minStock: product.minStock,
      unit: product.unit,
      isActive: true,
      createdAt: Timestamp.now(),
      createdBy: _auth.currentUser?.uid ?? '',
    );
    await docRef.set(newProduct.toMap());
  }

  // 2. Saare Products Lana - Stream
  Stream<List<ProductModel>> getAllProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .toList());
  }

  // 3. Product Update Karna
  Future<void> updateProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).update(product.toMap());
  }

  // 4. Product Delete Karna - Soft Delete
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).update({'isActive': false});
  }

  // 5. Low Stock Products
  Stream<List<ProductModel>> getLowStockProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .where((product) => product.isLowStock)
            .toList());
  }
}