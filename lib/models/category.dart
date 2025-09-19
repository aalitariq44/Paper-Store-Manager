class Category {
  final String id;
  final String name;
  final DateTime createdAt;

  Category({required this.id, required this.name, required this.createdAt});

  // Convert Category to Map for Firestore
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'createdAt': createdAt.toIso8601String()};
  }

  // Create Category from Firestore Map
  factory Category.fromMap(Map<String, dynamic> map, String documentId) {
    return Category(
      id: documentId,
      name: map['name'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Create Category from Firestore DocumentSnapshot
  factory Category.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Category.fromMap(data, documentId);
  }
}
