class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String categoryId;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.categoryId,
    required this.createdAt,
  });

  // Convert Product to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Product from Firestore Map
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      categoryId: map['categoryId'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Create Product from Firestore DocumentSnapshot
  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Product.fromMap(data, documentId);
  }
}
