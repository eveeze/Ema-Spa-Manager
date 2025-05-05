// lib/features/schedule/views/schedule_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/features/dashboard/controllers/dashboard_controller.dart';

class ScheduleView extends GetView<DashboardController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Jadwal', showBackButton: false),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 64,
                color: ColorTheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Jadwal View',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JosefinSans',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Schedule management coming soon',
                style: TextStyle(
                  fontSize: 16,
                  color: ColorTheme.textSecondary,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
