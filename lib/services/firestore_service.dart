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
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // --- Categories ---
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // --- Products ---
  Stream<List<ProductModel>> getProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
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
    // Generate a new document reference
    DocumentReference ref = _firestore.collection('orders').doc();
    // Update the ID to the generated one or keep using Firestore-generated ID.
    // In this case, we just save the map without setting the doc ID explicitly if the order object didn't have one,
    // but the toMap doesn't include ID, which is correct.
    await ref.set(order.toMap());
  }

  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // --- Admin ---
  Stream<List<UserModel>> getAllUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<OrderModel>> getAllOrdersStream() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
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
