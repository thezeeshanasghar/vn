import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/controllers/auth_controller.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/app_card.dart';
import '../core/router/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authController.login(
        _identifierController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (success) {
        Get.offAllNamed(AppRoutes.main);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary, // Solid blue background
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Medical Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight, // Lighter blue circle
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: AppColors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 60,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Title
                const Text(
                  'Doctor Portal',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                const Text(
                  'Patient Management System',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 60),
                
                // Login Card
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _identifierController,
                          label: 'Email or Phone Number',
                          hint: 'Enter your email or phone number',
                          prefixIcon: Icons.person,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email or phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock,
                          suffixIcon: _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          onSuffixIconTap: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        Obx(() => AppButton(
                          text: 'Sign In',
                          onPressed: _authController.isLoading.value ? null : _login,
                          isLoading: _authController.isLoading.value,
                          type: AppButtonType.primary,
                          size: AppButtonSize.large,
                          width: double.infinity,
                        )),
                      ],
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