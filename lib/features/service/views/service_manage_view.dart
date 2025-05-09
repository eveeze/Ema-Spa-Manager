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
        appBar: const CustomAppBar(
          title: 'Service Management',
          showBackButton: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed('/services/form'),
          backgroundColor: ColorTheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshServices();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header title
                  Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your baby spa services',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorTheme.textSecondary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter options
                  _buildFilterOptions(),
                  const SizedBox(height: 24),

                  // Service list
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadingServices.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.serviceError.isNotEmpty) {
                        return EmptyStateWidget(
                          title: 'Oops!',
                          message: controller.serviceError.value,
                          icon: Icons.error_outline_rounded,
                          buttonLabel: 'Refresh',
                          onButtonPressed: controller.refreshServices,
                          fullScreen: false,
                        );
                      }

                      if (controller.services.isEmpty) {
                        return EmptyStateWidget(
                          title: 'No Services Found',
                          message: 'You haven\'t added any services yet.',
                          icon: Icons.spa_outlined,
                          buttonLabel: 'Add Service',
                          onButtonPressed: () => Get.toNamed('/services/form'),
                          fullScreen: false,
                        );
                      }

                      return _buildServiceList();
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category filter dropdown will be implemented here
        Obx(() {
          return controller.isLoadingCategories.value
              ? const Center(child: LinearProgressIndicator())
              : DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Filter by Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
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
                    child: Text('All Categories'),
                  ),
                  ...controller.serviceCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }),
                ],
              );
        }),
        const SizedBox(height: 12),
        // Status filter
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.fetchServices(isActive: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorTheme.success,
                  side: BorderSide(color: ColorTheme.success),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Active Only'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.fetchServices(isActive: false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorTheme.error,
                  side: BorderSide(color: ColorTheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Inactive Only'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.fetchServices(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorTheme.primary,
                  side: BorderSide(color: ColorTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('All'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: controller.services.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = controller.services[index];
        return _buildServiceCard(service);
      },
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
        color: ColorTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => {controller.navigateToEditService(service.id)},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Service image or placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ColorTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    service.imageUrl != null && service.imageUrl!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            service.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.spa,
                                size: 40,
                                color: ColorTheme.info,
                              );
                            },
                          ),
                        )
                        : Icon(Icons.spa, size: 40, color: ColorTheme.info),
              ),
              const SizedBox(width: 16),

              // Service info
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorTheme.textPrimary,
                              fontFamily: 'JosefinSans',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                service.isActive
                                    ? ColorTheme.success.withValues(alpha: 0.1)
                                    : ColorTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 4),
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorTheme.info,
                        fontFamily: 'JosefinSans',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: ColorTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.duration} minutes',
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorTheme.textSecondary,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (service.hasPriceTiers)
                          Text(
                            'Multiple price tiers',
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorTheme.warning,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'JosefinSans',
                            ),
                          )
                        else if (service.price != null)
                          Text(
                            'Rp ${service.price?.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorTheme.success,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'JosefinSans',
                            ),
                          ),
                      ],
                    ),
                    if (service.minBabyAge != null &&
                        service.maxBabyAge != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'For babies ${service.minBabyAge} - ${service.maxBabyAge} months',
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorTheme.textSecondary,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                children: [
                  // Toggle active status button
                  IconButton(
                    icon: Icon(
                      service.isActive
                          ? Icons.toggle_on_rounded
                          : Icons.toggle_off_rounded,
                      color:
                          service.isActive
                              ? ColorTheme.success
                              : ColorTheme.textSecondary,
                      size: 28,
                    ),
                    onPressed:
                        () => controller.toggleServiceStatus(
                          service.id,
                          !service.isActive,
                        ),
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: ColorTheme.error,
                      size: 24,
                    ),
                    onPressed: () => _showDeleteConfirmation(service),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(Service service) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete ${service.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: ColorTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteService(service.id);
            },
            child: Text('Delete', style: TextStyle(color: ColorTheme.error)),
          ),
        ],
      ),
    );
  }
}
