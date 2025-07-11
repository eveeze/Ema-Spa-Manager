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
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  // Top section with illustration
                  SizedBox(
                    height: size.height * 0.35, // Fixed height for top section
                    width: double.infinity,
                    child: Padding(
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
                      child: SingleChildScrollView(
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

                              // Email field using AppTextField with white label
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
                                // Force white label for both themes
                                labelColor: Colors.white,
                                requiredColor: Colors.red.shade300,
                              ),

                              const SizedBox(height: 24),

                              // Password field using AppTextField with white label
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
                                // Force white label for both themes
                                labelColor: Colors.white,
                                requiredColor: Colors.red.shade300,
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

                              // Error messages with improved visibility
                              Obx(() {
                                if (_authController.errorMessage.isNotEmpty) {
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                      bottom: 20,
                                    ), // Add margin for spacing
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: (isDark
                                              ? ColorTheme.errorDark
                                              : ColorTheme.error)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: (isDark
                                                ? ColorTheme.errorDark
                                                : ColorTheme.error)
                                            .withValues(alpha: 0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color:
                                              isDark
                                                  ? ColorTheme.errorDark
                                                  : ColorTheme.error,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _authController.errorMessage.value,
                                            style: TextStyle(
                                              color: textPrimary,
                                              fontSize:
                                                  15, // Increased from default
                                              fontWeight:
                                                  FontWeight
                                                      .w500, // Better contrast
                                              height: 1.4,
                                              fontFamily: 'JosefinSans',
                                            ),
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
