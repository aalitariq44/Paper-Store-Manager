import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../services/firebase_service.dart';
import 'login_screen.dart';
import 'products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _showAddCategoryDialog() {
    _categoryController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إضافة تصنيف جديد'),
          content: TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'اسم التصنيف',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(onPressed: _addCategory, child: const Text('إضافة')),
          ],
        );
      },
    );
  }

  Future<void> _addCategory() async {
    String categoryName = _categoryController.text.trim();

    if (categoryName.isEmpty) {
      _showMessage('يرجى إدخال اسم التصنيف');
      return;
    }

    String? result = await _firebaseService.addCategory(categoryName);

    if (result != null) {
      _categoryController.clear();
      Navigator.of(context).pop();
      _showMessage('تم إضافة التصنيف بنجاح');
    } else {
      _showMessage('حدث خطأ أثناء إضافة التصنيف');
    }
  }

  void _showDeleteCategoryDialog(Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف التصنيف'),
          content: Text(
            'هل أنت متأكد من حذف تصنيف "${category.name}"؟\nسيتم حذف جميع المنتجات في هذا التصنيف.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => _deleteCategory(category.id),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCategory(String categoryId) async {
    Navigator.of(context).pop();

    bool result = await _firebaseService.deleteCategory(categoryId);

    if (result) {
      _showMessage('تم حذف التصنيف بنجاح');
    } else {
      _showMessage('حدث خطأ أثناء حذف التصنيف');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التصنيفات'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: _firebaseService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ في تحميل التصنيفات',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          List<Category> categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد تصنيفات',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط على الزر أدناه لإضافة تصنيف جديد',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              Category category = categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.category,
                      color: Colors.blue[600],
                      size: 28,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'تم الإنشاء: ${_formatDate(category.createdAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showDeleteCategoryDialog(category),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductsScreen(category: category),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
