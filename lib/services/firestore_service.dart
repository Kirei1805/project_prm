import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // --- Users ---
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      print('--- Đang lấy User từ Firestore: $uid ---');
      // Thử cache trước để tránh chờ kết nối lần đầu
      DocumentSnapshot? doc;
      try {
        doc = await _firestore
            .collection('users')
            .doc(uid)
            .get(const GetOptions(source: Source.cache));
      } catch (_) {
        // Nếu cache trống, lấy từ server
        doc = await _firestore
            .collection('users')
            .doc(uid)
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 10));
      }

      print('--- Đã lấy xong: ${doc.exists} ---');
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUserAddress(String uid, String address) async {
    await _firestore.collection('users').doc(uid).update({'address': address});
  }

  // --- Categories ---
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore.collection('categories')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // --- Products ---
  Stream<List<ProductModel>> getProductsStream() {
    return _firestore.collection('products')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<ProductModel?> getProduct(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // --- Orders ---
  Future<void> createOrder(OrderModel order) async {
    await _firestore.runTransaction((transaction) async {
      // 1. Read all product documents first (Transactions require all reads before writes)
      List<DocumentSnapshot> productSnaps = [];
      for (var item in order.items) {
        DocumentReference productRef = _firestore.collection('products').doc(item.productId);
        productSnaps.add(await transaction.get(productRef));
      }

      // 2. Perform checks and writes
      for (int i = 0; i < order.items.length; i++) {
        var item = order.items[i];
        var snap = productSnaps[i];
        
        if (!snap.exists) {
          throw Exception('Sản phẩm không tồn tại (ID: ${item.productId})');
        }
        
        int currentStock = (snap.data() as Map<String, dynamic>)['stock'] ?? 0;
        if (currentStock < item.quantity) {
          throw Exception('Sản phẩm "${item.name}" không đủ số lượng (còn lại: $currentStock).');
        }
        
        transaction.update(snap.reference, {
          'stock': currentStock - item.quantity
        });
      }

      // 3. Create the order document
      DocumentReference orderRef = _firestore.collection('orders').doc();
      transaction.set(orderRef, order.toMap());
    });
  }

  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<UserModel>> getAllUsersStream() {
    return _firestore.collection('users')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<OrderModel>> getAllOrdersStream() {
    return _firestore.collection('orders')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({'status': newStatus});
  }

  Future<void> addProduct(ProductModel product) async {
    DocumentReference ref = _firestore.collection('products').doc();
    await ref.set(product.toMap());
  }

  Future<void> updateProduct(String productId, ProductModel product) async {
    await _firestore.collection('products').doc(productId).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // --- Chat ---
  Stream<List<MessageModel>> getChatStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
    
    // Update the last updated time of the chat document
    await _firestore.collection('chats').doc(chatId).set({
      'lastUpdated': FieldValue.serverTimestamp(),
      'userId': chatId, // For customer chats, chatId is usually userId
    }, SetOptions(merge: true));
  }

  Stream<List<String>> getActiveChatsStream() {
    return _firestore
        .collection('chats')
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }
}
