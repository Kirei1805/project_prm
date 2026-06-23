class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer' or 'admin'
  final String address;
  final String avatarUrl;
  final List<String> savedAddresses;
  final List<String> favoriteProductIds;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.address = '',
    this.avatarUrl = '',
    this.savedAddresses = const [],
    this.favoriteProductIds = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'customer',
      address: data['address'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      savedAddresses: data['savedAddresses'] != null ? List<String>.from(data['savedAddresses']) : [],
      favoriteProductIds: data['favoriteProductIds'] != null ? List<String>.from(data['favoriteProductIds']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'address': address,
      'avatarUrl': avatarUrl,
      'savedAddresses': savedAddresses,
      'favoriteProductIds': favoriteProductIds,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? address,
    String? avatarUrl,
    List<String>? savedAddresses,
    List<String>? favoriteProductIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
    );
  }
}
