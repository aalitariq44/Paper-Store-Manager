import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/category.dart';
import '../models/product.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Categories Collection Reference
  CollectionReference get _categoriesCollection =>
      _firestore.collection('categories');

  // Products Collection Reference
  CollectionReference get _productsCollection =>
      _firestore.collection('products');

  // =================== AUTH METHODS ===================

  // Check if password is correct (stored in Firestore)
  Future<bool> checkPassword(String password) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('admin')
          .doc('credentials')
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String storedPassword = data['password'] ?? '';
        return storedPassword == password;
      }
      return false;
    } catch (e) {
      print('Error checking password: $e');
      return false;
    }
  }

  // Set admin password (call this once to set up)
  Future<void> setAdminPassword(String password) async {
    try {
      await _firestore.collection('admin').doc('credentials').set({
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error setting password: $e');
    }
  }

  // =================== CATEGORY METHODS ===================

  // Add Category
  Future<String?> addCategory(String name) async {
    try {
      DocumentReference docRef = await _categoriesCollection.add({
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding category: $e');
      return null;
    }
  }

  // Get all Categories
  Stream<List<Category>> getCategories() {
    return _categoriesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Category.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // Delete Category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      // First, delete all products in this category
      QuerySnapshot productsSnapshot = await _productsCollection
          .where('categoryId', isEqualTo: categoryId)
          .get();

      for (QueryDocumentSnapshot doc in productsSnapshot.docs) {
        await deleteProduct(doc.id);
      }

      // Then delete the category
      await _categoriesCollection.doc(categoryId).delete();
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // =================== PRODUCT METHODS ===================

  // Add Product
  Future<String?> addProduct({
    required String name,
    required double price,
    required String description,
    required String categoryId,
    File? imageFile,
  }) async {
    try {
      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
        if (imageUrl == null) {
          return null;
        }
      } else {
        imageUrl = '';
      }

      DocumentReference docRef = await _productsCollection.add({
        'name': name,
        'price': price,
        'description': description,
        'categoryId': categoryId,
        'imageUrl': imageUrl,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  // Get Products by Category
  Stream<List<Product>> getProductsByCategory(String categoryId) {
    return _productsCollection
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Product.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // Get all Products
  Stream<List<Product>> getAllProducts() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Product.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // Delete Product
  Future<bool> deleteProduct(String productId) async {
    try {
      // Get product data first to delete image
      DocumentSnapshot doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String imageUrl = data['imageUrl'] ?? '';

        // Delete image from storage
        if (imageUrl.isNotEmpty) {
          await deleteImageFromUrl(imageUrl);
        }
      }

      // Delete product document
      await _productsCollection.doc(productId).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // =================== STORAGE METHODS ===================

  // Upload Image
  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('product_images/$fileName');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete Image from Storage
  Future<void> deleteImageFromUrl(String imageUrl) async {
    try {
      Reference imageRef = _storage.refFromURL(imageUrl);
      await imageRef.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
