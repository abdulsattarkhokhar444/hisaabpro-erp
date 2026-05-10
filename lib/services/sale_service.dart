import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sale_model.dart';

class SaleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Nayi Sale Create Karna + Stock Update
  Future<void> createSale(SaleModel sale) async {
    final batch = _firestore.batch();
    final saleRef = _firestore.collection('sales').doc();
    
    // Sale document add karo
    final newSale = SaleModel(
      id: saleRef.id,
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      items: sale.items,
      subtotal: sale.subtotal,
      discount: sale.discount,
      total: sale.total,
      paymentMethod: sale.paymentMethod,
      customerName: sale.customerName,
      createdAt: Timestamp.now(),
      createdBy: _auth.currentUser?.uid ?? '',
      isActive: true,
    );
    batch.set(saleRef, newSale.toMap());

    // Har product ka stock kam karo
    for (var item in sale.items) {
      final productRef = _firestore.collection('products').doc(item.productId);
      batch.update(productRef, {
        'stock': FieldValue.increment(-item.quantity),
      });
    }

    await batch.commit();
  }

  // 2. Saari Sales Lana
  Stream<List<SaleModel>> getAllSales() {
    return _firestore
        .collection('sales')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SaleModel.fromMap(doc.data()))
            .toList());
  }

  // 3. Aaj Ki Sales
  Stream<List<SaleModel>> getTodaysSales() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    return _firestore
        .collection('sales')
        .where('isActive', isEqualTo: true)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SaleModel.fromMap(doc.data()))
            .toList());
  }
}