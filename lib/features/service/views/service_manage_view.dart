// lib/features/service/views/service_manage_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/data/models/service.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

class ServiceManageView extends GetView<ServiceController> {
  const ServiceManageView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return MainLayout(
      child: Obx(() {
        themeController.updateSystemBrightness();

        return Scaffold(
          backgroundColor:
              themeController.isDarkMode
                  ? ColorTheme.backgroundDark
                  : Colors.grey[50],
          appBar: CustomAppBar(
            title: 'Service Management',
            showBackButton: true,
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.primaryLightDark.withOpacity(0.3)
                          : ColorTheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => Get.toNamed('/services/form'),
              backgroundColor:
                  themeController.isDarkMode
                      ? ColorTheme.primaryLightDark
                      : ColorTheme.primary,
              elevation: 0,
              icon: Icon(
                Icons.add_rounded,
                color: themeController.isDarkMode ? Colors.black : Colors.white,
              ),
              label: Text(
                'Add Service',
                style: TextStyle(
                  color:
                      themeController.isDarkMode ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'JosefinSans',
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.refreshServices();
              },
              color:
                  themeController.isDarkMode
                      ? ColorTheme.primaryLightDark
                      : ColorTheme.primary,
              backgroundColor:
                  themeController.isDarkMode
                      ? ColorTheme.surfaceDark
                      : Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildFilterOptions(themeController),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Obx(() {
                        if (controller.isLoadingServices.value) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      themeController.isDarkMode
                                          ? ColorTheme.primaryLightDark
                                          : ColorTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading services...',
                                    style: TextStyle(
                                      color:
                                          themeController.isDarkMode
                                              ? ColorTheme.textSecondaryDark
                                              : ColorTheme.textSecondary,
                                      fontFamily: 'JosefinSans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (controller.serviceError.isNotEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: EmptyStateWidget(
                              title: 'Oops!',
                              message: controller.serviceError.value,
                              icon: Icons.error_outline_rounded,
                              buttonLabel: 'Refresh',
                              onButtonPressed: controller.refreshServices,
                              fullScreen: false,
                            ),
                          );
                        }

                        if (controller.services.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: EmptyStateWidget(
                              title: 'No Services Found',
                              message: 'You haven\'t added any services yet.',
                              icon: Icons.spa_outlined,
                              buttonLabel: 'Add Service',
                              onButtonPressed:
                                  () => Get.toNamed('/services/form'),
                              fullScreen: false,
                            ),
                          );
                        }

                        return _buildServiceList(themeController);
                      }),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFilterOptions(ThemeController themeController) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            themeController.isDarkMode ? ColorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                themeController.isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color:
                    themeController.isDarkMode
                        ? ColorTheme.primaryLightDark
                        : ColorTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.textPrimaryDark
                          : ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            return controller.isLoadingCategories.value
                ? Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color:
                        themeController.isDarkMode
                            ? Colors.grey[700]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: LinearProgressIndicator(
                      backgroundColor:
                          themeController.isDarkMode
                              ? Colors.grey[600]
                              : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        themeController.isDarkMode
                            ? ColorTheme.primaryLightDark
                            : ColorTheme.primary,
                      ),
                    ),
                  ),
                )
                : Container(
                  decoration: BoxDecoration(
                    color:
                        themeController.isDarkMode
                            ? ColorTheme.backgroundDark
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          themeController.isDarkMode
                              ? ColorTheme.borderDark
                              : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    dropdownColor:
                        themeController.isDarkMode
                            ? ColorTheme.surfaceDark
                            : Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Filter by Category',
                      labelStyle: TextStyle(
                        color:
                            themeController.isDarkMode
                                ? ColorTheme.textSecondaryDark
                                : ColorTheme.textSecondary,
                        fontFamily: 'JosefinSans',
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.category_outlined,
                        color:
                            themeController.isDarkMode
                                ? ColorTheme.primaryLightDark
                                : ColorTheme.primary,
                        size: 20,
                      ),
                    ),
                    value: null,
                    style: TextStyle(
                      color:
                          themeController.isDarkMode
                              ? ColorTheme.textPrimaryDark
                              : ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                    onChanged: (String? categoryId) {
                      if (categoryId != null) {
                        controller.fetchServices(categoryId: categoryId);
                      } else {
                        controller.fetchServices();
                      }
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'All Categories',
                          style: TextStyle(
                            fontFamily: 'JosefinSans',
                            color:
                                themeController.isDarkMode
                                    ? ColorTheme.textSecondaryDark
                                    : ColorTheme.textSecondary,
                          ),
                        ),
                      ),
                      ...controller.serviceCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontFamily: 'JosefinSans',
                              color:
                                  themeController.isDarkMode
                                      ? ColorTheme.textPrimaryDark
                                      : ColorTheme.textPrimary,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
          }),
          const SizedBox(height: 16),
          Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.textSecondaryDark
                      : ColorTheme.textSecondary,
              fontFamily: 'JosefinSans',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  label: 'Active',
                  icon: Icons.check_circle_outline_rounded,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.successDark
                          : ColorTheme.success,
                  themeController: themeController,
                  onPressed: () => controller.fetchServices(isActive: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  label: 'Inactive',
                  icon: Icons.cancel_outlined,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.errorDark
                          : ColorTheme.error,
                  themeController: themeController,
                  onPressed: () => controller.fetchServices(isActive: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  label: 'All',
                  icon: Icons.list_rounded,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.primaryLightDark
                          : ColorTheme.primary,
                  themeController: themeController,
                  onPressed: () => controller.fetchServices(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required ThemeController themeController,
  }) {
    Color foregroundColor = color;
    Color backgroundColor =
        themeController.isDarkMode
            ? color.withOpacity(0.15)
            : color.withOpacity(0.05);
    Color borderColor =
        themeController.isDarkMode
            ? color.withOpacity(0.5)
            : color.withOpacity(0.3);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                themeController.isDarkMode
                    ? color.withOpacity(0.25)
                    : color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: foregroundColor),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'JosefinSans',
            color: foregroundColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor, width: 1.5),
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceList(ThemeController themeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(
                Icons.list_alt_rounded,
                color:
                    themeController.isDarkMode
                        ? ColorTheme.primaryLightDark
                        : ColorTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Services (${controller.services.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      themeController.isDarkMode
                          ? ColorTheme.textPrimaryDark
                          : ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: controller.services.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final service = controller.services[index];
            return _buildServiceCard(service, themeController);
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(Service service, ThemeController themeController) {
    String categoryName = 'Unknown';
    final category = controller.serviceCategories.firstWhereOrNull(
      (category) => category.id == service.categoryId,
    );
    if (category != null) {
      categoryName = category.name;
    }

    return Container(
      decoration: BoxDecoration(
        color:
            themeController.isDarkMode ? ColorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                themeController.isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.navigateToEditService(service.id),
        borderRadius: BorderRadius.circular(16),
        splashColor:
            themeController.isDarkMode
                ? ColorTheme.primaryLightDark.withOpacity(0.1)
                : ColorTheme.primary.withOpacity(0.1),
        highlightColor:
            themeController.isDarkMode
                ? ColorTheme.primaryLightDark.withOpacity(0.2)
                : ColorTheme.primary.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceImage(service, themeController),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceHeader(service, themeController),
                    const SizedBox(height: 12),
                    _buildCategoryBadge(categoryName, themeController),
                    const SizedBox(height: 12),
                    _buildServiceDetails(service, themeController),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildActionButtons(service, themeController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImage(Service service, ThemeController themeController) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              themeController.isDarkMode
                  ? [
                    ColorTheme.infoDark.withOpacity(0.2),
                    ColorTheme.primaryLightDark.withOpacity(0.1),
                  ]
                  : [
                    ColorTheme.info.withOpacity(0.1),
                    ColorTheme.primary.withOpacity(0.05),
                  ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              themeController.isDarkMode
                  ? ColorTheme.infoDark.withOpacity(0.3)
                  : ColorTheme.info.withOpacity(0.2),
          width: 1,
        ),
      ),
      child:
          service.imageUrl != null && service.imageUrl!.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.network(
                  service.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.spa_rounded,
                      size: 32,
                      color:
                          themeController.isDarkMode
                              ? ColorTheme.infoDark
                              : ColorTheme.info,
                    );
                  },
                ),
              )
              : Icon(
                Icons.spa_rounded,
                size: 32,
                color:
                    themeController.isDarkMode
                        ? ColorTheme.infoDark
                        : ColorTheme.info,
              ),
    );
  }

  Widget _buildServiceHeader(Service service, ThemeController themeController) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            service.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.textPrimaryDark
                      : ColorTheme.textPrimary,
              fontFamily: 'JosefinSans',
              letterSpacing: -0.3,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        _buildStatusBadge(service, themeController),
      ],
    );
  }

  Widget _buildStatusBadge(Service service, ThemeController themeController) {
    final isActive = service.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            isActive
                ? themeController.isDarkMode
                    ? ColorTheme.successDark.withOpacity(0.15)
                    : ColorTheme.success.withOpacity(0.1)
                : themeController.isDarkMode
                ? ColorTheme.errorDark.withOpacity(0.15)
                : ColorTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isActive
                  ? themeController.isDarkMode
                      ? ColorTheme.successDark.withOpacity(0.4)
                      : ColorTheme.success.withOpacity(0.3)
                  : themeController.isDarkMode
                  ? ColorTheme.errorDark.withOpacity(0.4)
                  : ColorTheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color:
              isActive
                  ? themeController.isDarkMode
                      ? ColorTheme.successDark
                      : ColorTheme.success
                  : themeController.isDarkMode
                  ? ColorTheme.errorDark
                  : ColorTheme.error,
          fontFamily: 'JosefinSans',
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(
    String categoryName,
    ThemeController themeController,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            themeController.isDarkMode
                ? ColorTheme.infoDark.withOpacity(0.15)
                : ColorTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              themeController.isDarkMode
                  ? ColorTheme.infoDark.withOpacity(0.3)
                  : ColorTheme.info.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category_outlined,
            size: 14,
            color:
                themeController.isDarkMode
                    ? ColorTheme.infoDark
                    : ColorTheme.info,
          ),
          const SizedBox(width: 6),
          Text(
            categoryName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.infoDark
                      : ColorTheme.info,
              fontFamily: 'JosefinSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetails(
    Service service,
    ThemeController themeController,
  ) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: [
        _buildDetailItem(
          icon: Icons.access_time_rounded,
          text: '${service.duration} min',
          themeController: themeController,
        ),
        if (service.hasPriceTiers)
          _buildPriceTierBadge(themeController)
        else if (service.price != null)
          _buildPriceBadge(service.price!, themeController),
        if (service.minBabyAge != null && service.maxBabyAge != null)
          _buildDetailItem(
            icon: Icons.child_care_rounded,
            text: '${service.minBabyAge} - ${service.maxBabyAge} months old',
            themeController: themeController,
          ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String text,
    required ThemeController themeController,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color:
                themeController.isDarkMode
                    ? ColorTheme.textSecondaryDark.withOpacity(0.15)
                    : ColorTheme.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color:
                themeController.isDarkMode
                    ? ColorTheme.textSecondaryDark
                    : ColorTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.textSecondaryDark
                      : ColorTheme.textSecondary,
              fontFamily: 'JosefinSans',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBadge(double price, ThemeController themeController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            themeController.isDarkMode
                ? ColorTheme.successDark.withOpacity(0.15)
                : ColorTheme.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Rp ${price.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 12,
          color:
              themeController.isDarkMode
                  ? ColorTheme.successDark
                  : ColorTheme.success,
          fontWeight: FontWeight.bold,
          fontFamily: 'JosefinSans',
        ),
      ),
    );
  }

  Widget _buildPriceTierBadge(ThemeController themeController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            themeController.isDarkMode
                ? ColorTheme.warningDark.withOpacity(0.15)
                : ColorTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.layers_outlined,
            size: 12,
            color:
                themeController.isDarkMode
                    ? ColorTheme.warningDark.withOpacity(0.9)
                    : const Color(0xFFc77700),
          ),
          const SizedBox(width: 4),
          Text(
            'Multiple tiers',
            style: TextStyle(
              fontSize: 11,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.warningDark.withOpacity(0.9)
                      : const Color(0xFFc77700),
              fontWeight: FontWeight.w600,
              fontFamily: 'JosefinSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Service service, ThemeController themeController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color:
                service.isActive
                    ? themeController.isDarkMode
                        ? ColorTheme.successDark.withOpacity(0.15)
                        : ColorTheme.success.withOpacity(0.1)
                    : themeController.isDarkMode
                    ? Colors.grey[700]!.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(
              service.isActive
                  ? Icons.toggle_on_rounded
                  : Icons.toggle_off_rounded,
              color:
                  service.isActive
                      ? themeController.isDarkMode
                          ? ColorTheme.successDark
                          : ColorTheme.success
                      : themeController.isDarkMode
                      ? ColorTheme.textSecondaryDark
                      : ColorTheme.textSecondary,
              size: 28,
            ),
            onPressed:
                () => controller.toggleServiceStatus(
                  service.id,
                  !service.isActive,
                ),
            tooltip: service.isActive ? "Deactivate" : "Activate",
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:
                themeController.isDarkMode
                    ? ColorTheme.errorDark.withOpacity(0.15)
                    : ColorTheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color:
                  themeController.isDarkMode
                      ? ColorTheme.errorDark
                      : ColorTheme.error,
              size: 20,
            ),
            onPressed: () => _showDeleteConfirmation(service, themeController),
            tooltip: "Delete Service",
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
    Service service,
    ThemeController themeController,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor:
            themeController.isDarkMode ? ColorTheme.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    themeController.isDarkMode
                        ? ColorTheme.errorDark.withOpacity(0.15)
                        : ColorTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color:
                    themeController.isDarkMode
                        ? ColorTheme.errorDark
                        : ColorTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Service',
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.bold,
                color:
                    themeController.isDarkMode
                        ? ColorTheme.textPrimaryDark
                        : ColorTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${service.name}"? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            height: 1.4,
            color:
                themeController.isDarkMode
                    ? ColorTheme.textSecondaryDark
                    : ColorTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor:
                  themeController.isDarkMode
                      ? ColorTheme.textSecondaryDark
                      : ColorTheme.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.w600,
                color:
                    themeController.isDarkMode
                        ? ColorTheme.textSecondaryDark.withOpacity(0.8)
                        : ColorTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteService(service.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  themeController.isDarkMode
                      ? ColorTheme.errorDark
                      : ColorTheme.error,
              foregroundColor:
                  themeController.isDarkMode ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
