// lib/features/account/views/account_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/authentication/controllers/auth_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();

    return MainLayout.subPage(
      title: 'Akun Saya',
      parentRoute: '/account',
      showAppBar: true,
      showBottomNavigation: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              final owner = authController.owner.value;
              final bool isDarkMode = themeController.isDarkMode;

              return Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Theme.of(context).colorScheme.surface
                          : Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDarkMode ? 0.2 : 0.05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        owner?.name.isNotEmpty == true
                            ? owner!.name[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      owner?.name ?? 'Loading...',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      owner?.email ?? 'Loading...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            _buildSectionTitle(context, 'Pengaturan Tampilan'),
            _buildSettingsTile(
              context,
              themeController: themeController,
              icon: themeController.themeModeIcon,
              title: 'Mode Tampilan',
              subtitle: themeController.themeModeDisplayName,
              onTap: () => _showThemePicker(context, themeController),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              onPressed: () {
                authController.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontFamily: 'JosefinSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required ThemeController themeController,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final bool isDarkMode = themeController.isDarkMode;

    return Material(
      color:
          isDarkMode
              ? Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, ThemeController themeController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.light_mode_outlined),
              title: const Text('Terang'),
              onTap: () {
                themeController.setLightMode();
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Gelap'),
              onTap: () {
                themeController.setDarkMode();
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto_outlined),
              title: const Text('Sesuai Sistem'),
              onTap: () {
                themeController.setSystemMode();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
