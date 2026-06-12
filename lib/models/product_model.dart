class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final String categoryId;
  final String brand;
  final String voltage;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.categoryId,
    required this.brand,
    required this.voltage,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      id: documentId,
      name: data['name'] ?? '',
      sku: data['sku'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      categoryId: data['categoryId'] ?? '',
      brand: data['brand'] ?? '',
      voltage: data['voltage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'brand': brand,
      'voltage': voltage,
    };
  }
}
