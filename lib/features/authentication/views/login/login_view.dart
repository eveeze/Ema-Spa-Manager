// lib/features/authentication/views/login/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/features/authentication/controllers/auth_controller.dart';
import 'package:emababyspa/common/utils/validator_utils.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/widgets/app_button.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic colors based on theme
    final gradientPrimary =
        isDark ? ColorTheme.secondaryDark : ColorTheme.secondary;
    final gradientSecondary =
        isDark ? ColorTheme.primaryLightDark : ColorTheme.primaryDark;
    final formBackground =
        isDark ? ColorTheme.surfaceDark : ColorTheme.primaryDark;
    final textPrimary = isDark ? ColorTheme.textPrimaryDark : Colors.white;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Dynamic gradient based on theme
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              gradientPrimary, // Center color
              gradientSecondary, // Outer color
            ],
            stops: const [0.3, 1.0],
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
                                  // Fallback icon with theme-aware color
                                  return Icon(
                                    Icons.spa,
                                    size: size.width * 0.3,
                                    color: textPrimary,
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
                        // Dynamic form background
                        color: formBackground,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color:
                                isDark
                                    ? ColorTheme.borderDark
                                    : ColorTheme.borderFocus,
                            width: 2,
                          ),
                        ),
                        // Theme-aware shadow
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : Colors.black)
                                .withValues(alpha: isDark ? 0.4 : 0.2),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: const Offset(0, -5),
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
                                      color: textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              // Email field using AppTextField
                              AppTextField(
                                label: 'Email',
                                placeholder: 'Enter your email',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                size: TextFieldSize.medium,
                                isRequired: true,
                                prefix: const Icon(Icons.email_outlined),
                                validator: ValidatorUtils.validateEmail,
                                textInputAction: TextInputAction.next,
                              ),

                              const SizedBox(height: 24),

                              // Password field using AppTextField
                              AppTextField(
                                label: 'Password',
                                placeholder: 'Enter your password',
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                size: TextFieldSize.medium,
                                isRequired: true,
                                prefix: const Icon(Icons.lock_outlined),
                                suffix: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                validator: ValidatorUtils.validatePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _handleLogin(),
                              ),

                              const SizedBox(height: 32),

                              // Login button using AppButton
                              Obx(
                                () => AppButton(
                                  text: 'LOGIN',
                                  onPressed:
                                      _authController.isLoading.value
                                          ? null
                                          : _handleLogin,
                                  type: AppButtonType.primary,
                                  size: AppButtonSize.large,
                                  isFullWidth: true,
                                  isLoading: _authController.isLoading.value,
                                  icon: Icons.login,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Forgot password button using AppButton
                              Center(
                                child: AppButton(
                                  text: 'Lupa Password',
                                  onPressed: () {
                                    Get.toNamed('/forgot-password');
                                  },
                                  type: AppButtonType.text,
                                  size: AppButtonSize.medium,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Error messages
                              Obx(() {
                                if (_authController.errorMessage.isNotEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: (isDark
                                              ? ColorTheme.errorDark
                                              : ColorTheme.error)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: (isDark
                                                ? ColorTheme.errorDark
                                                : ColorTheme.error)
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color:
                                              isDark
                                                  ? ColorTheme.errorDark
                                                  : ColorTheme.error,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _authController.errorMessage.value,
                                            style: textTheme.bodySmall
                                                ?.copyWith(color: textPrimary),
                                          ),
                                        ),
                                      ],
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
