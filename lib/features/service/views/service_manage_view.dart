// lib/features/service/views/service_manage_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/data/models/service.dart';

class ServiceManageView extends GetView<ServiceController> {
  const ServiceManageView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: const CustomAppBar(
          title: 'Service Management',
          showBackButton: true,
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ColorTheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => Get.toNamed('/services/form'),
            backgroundColor: ColorTheme.primary,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Service',
              style: TextStyle(
                color: Colors.white,
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
            color: ColorTheme.primary,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Header Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ColorTheme.primary.withValues(alpha: 0.05),
                          ColorTheme.info.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ColorTheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.spa_rounded,
                                  color: ColorTheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Service Management',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: ColorTheme.textPrimary,
                                        fontFamily: 'JosefinSans',
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage and organize your baby spa services',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: ColorTheme.textSecondary,
                                        fontFamily: 'JosefinSans',
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filter Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildFilterOptions(),
                  ),

                  // Service list
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
                                    ColorTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading services...',
                                  style: TextStyle(
                                    color: ColorTheme.textSecondary,
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

                      return _buildServiceList();
                    }),
                  ),

                  // Bottom spacing for FAB
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                color: ColorTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorTheme.textPrimary,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category filter dropdown
          Obx(() {
            return controller.isLoadingCategories.value
                ? Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: LinearProgressIndicator()),
                )
                : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filter by Category',
                      labelStyle: TextStyle(
                        color: ColorTheme.textSecondary,
                        fontFamily: 'JosefinSans',
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.category_outlined,
                        color: ColorTheme.primary,
                        size: 20,
                      ),
                    ),
                    value: null,
                    onChanged: (String? categoryId) {
                      if (categoryId != null) {
                        controller.fetchServices(categoryId: categoryId);
                      } else {
                        controller.fetchServices();
                      }
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'All Categories',
                          style: TextStyle(fontFamily: 'JosefinSans'),
                        ),
                      ),
                      ...controller.serviceCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(
                            category.name,
                            style: const TextStyle(fontFamily: 'JosefinSans'),
                          ),
                        );
                      }),
                    ],
                  ),
                );
          }),

          const SizedBox(height: 16),

          // Status filter buttons
          Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorTheme.textSecondary,
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
                  color: ColorTheme.success,
                  onPressed: () => controller.fetchServices(isActive: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  label: 'Inactive',
                  icon: Icons.cancel_outlined,
                  color: ColorTheme.error,
                  onPressed: () => controller.fetchServices(isActive: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  label: 'All',
                  icon: Icons.list_rounded,
                  color: ColorTheme.primary,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'JosefinSans',
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.3), width: 1.5),
          backgroundColor: color.withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(Icons.list_alt_rounded, color: ColorTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Services (${controller.services.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorTheme.textPrimary,
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
            return _buildServiceCard(service);
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(Service service) {
    // Find the category name for this service
    String categoryName = 'Unknown';
    final category = controller.serviceCategories.firstWhereOrNull(
      (category) => category.id == service.categoryId,
    );
    if (category != null) {
      categoryName = category.name;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => {controller.navigateToEditService(service.id)},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Enhanced service image
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorTheme.info.withValues(alpha: 0.1),
                      ColorTheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ColorTheme.info.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child:
                    service.imageUrl != null && service.imageUrl!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            service.imageUrl!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.spa_rounded,
                                size: 44,
                                color: ColorTheme.info,
                              );
                            },
                          ),
                        )
                        : Icon(
                          Icons.spa_rounded,
                          size: 44,
                          color: ColorTheme.info,
                        ),
              ),
              const SizedBox(width: 16),

              // Enhanced service info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColorTheme.textPrimary,
                              fontFamily: 'JosefinSans',
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  service.isActive
                                      ? [
                                        ColorTheme.success.withValues(
                                          alpha: 0.1,
                                        ),
                                        ColorTheme.success.withValues(
                                          alpha: 0.05,
                                        ),
                                      ]
                                      : [
                                        ColorTheme.error.withValues(alpha: 0.1),
                                        ColorTheme.error.withValues(
                                          alpha: 0.05,
                                        ),
                                      ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  service.isActive
                                      ? ColorTheme.success.withValues(
                                        alpha: 0.3,
                                      )
                                      : ColorTheme.error.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            service.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  service.isActive
                                      ? ColorTheme.success
                                      : ColorTheme.error,
                              fontFamily: 'JosefinSans',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ColorTheme.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ColorTheme.info.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColorTheme.info,
                          fontFamily: 'JosefinSans',
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Service details
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: ColorTheme.textSecondary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: ColorTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${service.duration} min',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ColorTheme.textSecondary,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (service.hasPriceTiers)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ColorTheme.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Multiple tiers',
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorTheme.warning,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'JosefinSans',
                              ),
                            ),
                          )
                        else if (service.price != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ColorTheme.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Rp ${service.price?.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: ColorTheme.success,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'JosefinSans',
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (service.minBabyAge != null &&
                        service.maxBabyAge != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.child_care_rounded,
                              size: 14,
                              color: ColorTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${service.minBabyAge} - ${service.maxBabyAge} months old',
                              style: TextStyle(
                                fontSize: 13,
                                color: ColorTheme.textSecondary,
                                fontFamily: 'JosefinSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Enhanced action buttons
              Column(
                children: [
                  // Toggle active status button
                  Container(
                    decoration: BoxDecoration(
                      color:
                          service.isActive
                              ? ColorTheme.success.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        service.isActive
                            ? Icons.toggle_on_rounded
                            : Icons.toggle_off_rounded,
                        color:
                            service.isActive
                                ? ColorTheme.success
                                : ColorTheme.textSecondary,
                        size: 32,
                      ),
                      onPressed:
                          () => controller.toggleServiceStatus(
                            service.id,
                            !service.isActive,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Delete button
                  Container(
                    decoration: BoxDecoration(
                      color: ColorTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: ColorTheme.error,
                        size: 24,
                      ),
                      onPressed: () => _showDeleteConfirmation(service),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced delete confirmation dialog
  void _showDeleteConfirmation(Service service) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: ColorTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Service',
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${service.name}"? This action cannot be undone.',
          style: const TextStyle(fontFamily: 'JosefinSans', height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: ColorTheme.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteService(service.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTheme.error,
              foregroundColor: Colors.white,
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
