// lib/features/analytics/views/analytics_view.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/utils/app_routes.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout.subPage(
      title: 'Statistik',
      parentRoute: AppRoutes.analyticsView,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animation/under_development.json', // Path sesuai lokasi file Anda
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 24.0),

              Text(
                'Fitur Segera Hadir!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8.0),

              Text(
                'Fitur Dashboard Analitik akan dikembangkan di tugas akhir',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
