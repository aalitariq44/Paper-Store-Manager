import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import 'categories_screen.dart';
import 'initial_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    String password = _passwordController.text.trim();

    if (password.isEmpty) {
      _showErrorMessage('يرجى إدخال كلمة المرور');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool isValidPassword = await _firebaseService.checkPassword(password);

      if (isValidPassword) {
        // Save login status
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // Navigate to Categories Screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CategoriesScreen()),
          );
        }
      } else {
        _showErrorMessage('كلمة المرور غير صحيحة');
      }
    } catch (e) {
      _showErrorMessage('حدث خطأ أثناء تسجيل الدخول');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon/Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // App Title
                Text(
                  'مدير المتجر',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'لإدارة المنتجات والتصنيفات',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 48),

                // Login Card
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        onSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
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
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
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
                                'دخول',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Footer
                Text(
                  'مخصص لصاحب المتجر فقط',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),

                const SizedBox(height: 16),

                // Setup Password Button (Hidden - only shows on long press)
                GestureDetector(
                  onLongPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InitialSetupScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '.',
                      style: TextStyle(fontSize: 1, color: Colors.grey[100]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
