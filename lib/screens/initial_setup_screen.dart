import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _setupPassword() async {
    String password = _passwordController.text.trim();

    if (password.isEmpty) {
      _showMessage('يرجى إدخال كلمة المرور');
      return;
    }

    if (password.length < 6) {
      _showMessage('يجب أن تكون كلمة المرور أكثر من 6 أحرف');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await _firebaseService.setAdminPassword(password);

    setState(() {
      _isLoading = false;
    });

    _showMessage('تم إعداد كلمة المرور بنجاح');
    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعداد كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'إعداد كلمة مرور الإدارة',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _setupPassword,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('حفظ كلمة المرور'),
            ),
          ],
        ),
      ),
    );
  }
}
