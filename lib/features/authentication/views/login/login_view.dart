// lib/features/authentication/views/login/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
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
  bool _rememberMe = false;

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
        Get.offAllNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: ColorTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo and welcome text
                  Center(
                    child: Column(
                      children: [
                        Image.asset('assets/images/logo.jpg', height: 100),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to Ema Baby Spa',
                          style: textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login to your account',
                          style: textTheme.bodyLarge?.copyWith(
                            color: ColorTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Email field
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    placeholder: 'Enter your email',
                    prefix: Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    errorText:
                        _formKey.currentState?.validate() == false &&
                                ValidatorUtils.validateEmail(
                                      _emailController.text,
                                    ) !=
                                    null
                            ? ValidatorUtils.validateEmail(
                              _emailController.text,
                            )
                            : null,
                    size: TextFieldSize.medium,
                    isRequired: true,
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    placeholder: 'Enter your password',
                    prefix: Icon(Icons.lock_outlined),
                    obscureText: !_isPasswordVisible,
                    errorText:
                        _formKey.currentState?.validate() == false &&
                                ValidatorUtils.validatePassword(
                                      _passwordController.text,
                                    ) !=
                                    null
                            ? ValidatorUtils.validatePassword(
                              _passwordController.text,
                            )
                            : null,
                    isRequired: true,
                    suffix: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: ColorTheme.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Remember me and Forgot password row
                  Row(
                    children: [
                      // Remember me checkbox
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: ColorTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Remember me', style: textTheme.labelMedium),
                        ],
                      ),

                      const Spacer(),

                      // Forgot password button
                      AppButton(
                        text: 'Forgot Password?',
                        type: AppButtonType.text,
                        onPressed: () {
                          Get.toNamed('/forgot-password');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Login button
                  Obx(
                    () => AppButton(
                      text: 'Login',
                      type: AppButtonType.primary,
                      size: AppButtonSize.medium,
                      isFullWidth: true,
                      isLoading: _authController.isLoading.value,
                      onPressed: _handleLogin,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: textTheme.bodyMedium,
                        ),
                        AppButton(
                          text: 'Register',
                          type: AppButtonType.text,
                          onPressed: () {
                            Get.toNamed('/register');
                          },
                        ),
                      ],
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
                            color: ColorTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: ColorTheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _authController.errorMessage.value,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: ColorTheme.error,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
