// lib/features/service_category/views/service_category_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/widgets/empty_state_widget.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/service_category/controllers/service_category_controller.dart';
import 'package:emababyspa/data/models/service_category.dart';

class ServiceCategoryView extends GetView<ServiceCategoryController> {
  const ServiceCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Service Categories',
          showBackButton: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.navigateToAddServiceCategory();
          },
          backgroundColor: ColorTheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              controller.refreshData();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header title
                  Text(
                    'Service Categories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.textPrimary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your spa service categories',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorTheme.textSecondary,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Categories list
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.errorMessage.isNotEmpty) {
                        return EmptyStateWidget(
                          title: 'Oops!',
                          message: controller.errorMessage.value,
                          icon: Icons.error_outline_rounded,
                          buttonLabel: 'Refresh',
                          onButtonPressed: controller.refreshData,
                          fullScreen: false,
                        );
                      }

                      if (controller.serviceCategories.isEmpty) {
                        return EmptyStateWidget(
                          title: 'No Categories Found',
                          message:
                              'You haven\'t added any service categories yet.',
                          icon: Icons.category_outlined,
                          buttonLabel: 'Add Category',
                          onButtonPressed: () {
                            controller.navigateToAddServiceCategory();
                          },
                          fullScreen: false,
                        );
                      }

                      return _buildCategoriesList();
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

  Widget _buildCategoriesList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: controller.serviceCategories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = controller.serviceCategories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(ServiceCategory category) {
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
        onTap: () {
          controller.navigateToEditServiceCategory(category.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: ColorTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(Icons.spa, size: 30, color: ColorTheme.info),
              ),
              const SizedBox(width: 16),

              // Category info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.textPrimary,
                        fontFamily: 'JosefinSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (category.description != null &&
                        category.description!.isNotEmpty)
                      Text(
                        category.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorTheme.textSecondary,
                          fontFamily: 'JosefinSans',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                children: [
                  // Edit button
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: ColorTheme.info,
                      size: 24,
                    ),
                    onPressed: () {
                      controller.navigateToEditServiceCategory(category.id);
                    },
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: ColorTheme.error,
                      size: 24,
                    ),
                    onPressed:
                        () => controller.showDeleteConfirmation(
                          category.id,
                          category.name,
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
}
