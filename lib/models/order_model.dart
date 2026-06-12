class OrderItemModel {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String status;
  final double totalAmount;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.items,
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    List<OrderItemModel> itemsList = [];
    if (data['items'] != null) {
      var list = data['items'] as List;
      itemsList = list.map((item) => OrderItemModel.fromMap(item)).toList();
    }

    return OrderModel(
      id: documentId,
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'Pending',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      items: itemsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'status': status,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}
