// lib/features/authentication/views/login/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/features/authentication/controllers/auth_controller.dart';
import 'package:emababyspa/common/utils/validator_utils.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await _authController.login(email, password);

      if (success) {
        Get.offAllNamed('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Radial gradient dengan biru muda di tengah dan biru tua di sekeliling
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              ColorTheme.secondary, // Biru muda di tengah
              ColorTheme.primaryDark, // Biru tua di sekeliling
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: size.height - MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  // Top section with illustration
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo/Illustration
                          SizedBox(
                            width: size.width * 0.6,
                            height: size.width * 0.6,
                            child: Center(
                              child: Image.asset(
                                'assets/images/login_icon.png',
                                width: size.width * 0.5,
                                height: size.width * 0.5,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback if image doesn't exist
                                  return Icon(
                                    Icons.spa,
                                    size: size.width * 0.3,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom section with form
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        // Background form menggunakan warna biru yang lebih tua
                        color: ColorTheme.primaryDark, // Biru tua untuk form
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: ColorTheme.borderFocus, // Warna border fokus
                            width: 2,
                          ),
                        ),
                        // Tambahkan shadow untuk depth
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sign In Title
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32.0),
                                child: Center(
                                  child: Text(
                                    'Sign In',
                                    style: textTheme.displaySmall?.copyWith(
                                      color: Colors.white, // Ubah ke putih
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              // Email field
                              Text(
                                'Email',
                                style: textTheme.labelLarge?.copyWith(
                                  color: Colors.white, // Ubah ke putih
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(
                                    0xFF2A4A6B,
                                  ), // Background input lebih gelap
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(
                                      0xFF3D5A7A,
                                    ), // Border lebih terang
                                    width: 1,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white, // Text putih
                                  ),
                                  validator: ValidatorUtils.validateEmail,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your email',
                                    hintStyle: textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ), // Hint lebih transparan
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Password field
                              Text(
                                'Password',
                                style: textTheme.labelLarge?.copyWith(
                                  color: Colors.white, // Ubah ke putih
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(
                                    0xFF2A4A6B,
                                  ), // Background input lebih gelap
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(
                                      0xFF3D5A7A,
                                    ), // Border lebih terang
                                    width: 1,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white, // Text putih
                                  ),
                                  validator: ValidatorUtils.validatePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    hintStyle: textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ), // Hint lebih transparan
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ), // Icon putih transparan
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Login button
                              Obx(
                                () => SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed:
                                        _authController.isLoading.value
                                            ? null
                                            : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorTheme.primary,
                                      foregroundColor:
                                          ColorTheme
                                              .primaryDark, // Text button biru tua
                                      elevation: 4, // Tambah elevation
                                      shadowColor: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      disabledBackgroundColor: Color(
                                        0xFF3D5A7A,
                                      ), // Disabled state lebih gelap
                                    ),
                                    child:
                                        _authController.isLoading.value
                                            ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(ColorTheme.primaryDark),
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : Text(
                                              'LOGIN',
                                              style: textTheme.labelLarge?.copyWith(
                                                color:
                                                    ColorTheme
                                                        .primaryDark, // Text biru tua
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Forgot password link
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Get.toNamed('/forgot-password');
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: ColorTheme.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    'Lupa Password',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: ColorTheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              // Error messages
                              Obx(() {
                                if (_authController.errorMessage.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: ColorTheme.error.withValues(
                                          alpha:
                                              0.2, // Lebih visible di background gelap
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: ColorTheme.error.withValues(
                                            alpha: 0.5, // Border lebih terang
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: ColorTheme.error,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _authController
                                                  .errorMessage
                                                  .value,
                                              style: textTheme.bodySmall?.copyWith(
                                                color:
                                                    Colors
                                                        .white, // Text error putih
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),

                              // Register link (if needed)
                              const Spacer(),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ), // Text putih transparan
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.toNamed('/register');
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: ColorTheme.primary,
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Register',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: ColorTheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
