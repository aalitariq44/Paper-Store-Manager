import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category.dart';
import '../services/firebase_service.dart';

class AddProductScreen extends StatefulWidget {
  final Category category;

  const AddProductScreen({super.key, required this.category});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _imagePicker = ImagePicker();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // State variables
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showMessage('خطأ في اختيار الصورة');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showMessage('خطأ في التقاط الصورة');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اختيار الصورة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('من المعرض'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      _showMessage('يرجى اختيار صورة للمنتج');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? result = await _firebaseService.addProduct(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        categoryId: widget.category.id,
        imageFile: _selectedImage!,
      );

      if (result != null) {
        _showMessage('تم إضافة المنتج بنجاح');
        Navigator.of(context).pop();
      } else {
        _showMessage('حدث خطأ أثناء إضافة المنتج');
      }
    } catch (e) {
      _showMessage('حدث خطأ أثناء إضافة المنتج');
    }

    setState(() {
      _isLoading = false;
    });
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
        title: Text('إضافة منتج إلى ${widget.category.name}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Selection Section
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_selectedImage!, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: _showImageSourceDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'اضغط لإضافة صورة المنتج',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Product Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المنتج *',
                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[600]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسم المنتج';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Product Price Field
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'سعر المنتج (ر.س) *',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[600]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال سعر المنتج';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'يرجى إدخال سعر صحيح';
                  }
                  if (double.parse(value.trim()) <= 0) {
                    return 'يجب أن يكون السعر أكبر من صفر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Product Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'وصف المنتج *',
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[600]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال وصف المنتج';
                  }
                  if (value.trim().length < 10) {
                    return 'يجب أن يكون الوصف أكثر من 10 أحرف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Add Product Button
              ElevatedButton(
                onPressed: _isLoading ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'إضافة المنتج',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Required Fields Note
              Text(
                '* الحقول المطلوبة',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
