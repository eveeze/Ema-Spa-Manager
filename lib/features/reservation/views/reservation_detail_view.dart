// lib/features/reservation/views/reservation_detail_view.dart

import 'package:emababyspa/data/models/payment.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReservationDetailView extends GetView<ReservationController> {
  const ReservationDetailView({super.key});

  // --- PERBAIKAN 1: Sederhanakan fungsi load data ---
  // Kita hanya butuh satu panggilan API.
  Future<void> _loadReservationDetails(String reservationId) async {
    // Reset state sebelum memuat data baru
    controller.clearSelectedReservation();
    await controller.fetchReservationById(reservationId);
    // Panggilan ke fetchOwnerPaymentDetails() DIHAPUS.
  }

  @override
  Widget build(BuildContext context) {
    final String reservationId = Get.parameters['id'] ?? '';
    final theme = Theme.of(context);

    // Gunakan WidgetsBinding.instance.addPostFrameCallback untuk menghindari error build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (reservationId.isNotEmpty) {
        // Hanya panggil jika data belum ada atau berbeda ID
        if (controller.selectedReservation.value?.id != reservationId) {
          _loadReservationDetails(reservationId);
        }
      } else {
        // Handle jika tidak ada ID
        Get.snackbar(
          'Error',
          'Reservation ID not provided.',
          backgroundColor: theme.colorScheme.errorContainer,
          colorText: theme.colorScheme.onErrorContainer,
        );
        if (Navigator.of(context).canPop()) Get.back();
      }
    });

    return MainLayout(
      parentRoute: AppRoutes.schedule,
      showBottomNavigation: true,
      showAppBar: true,
      appBarTitle: 'Reservation Details',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed:
              () => Get.toNamed('${AppRoutes.reservationEdit}/$reservationId'),
          tooltip: 'Edit Reservation',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            if (reservationId.isNotEmpty) {
              _loadReservationDetails(reservationId);
            }
          },
          tooltip: 'Refresh Details',
        ),
      ],
      child: _buildBody(context, reservationId),
    );
  }

  Widget _buildBody(BuildContext context, String reservationId) {
    return Obx(() {
      // Logika Pengecekan Loading
      if (controller.isLoading.value &&
          controller.selectedReservation.value?.id != reservationId) {
        return const Center(child: CircularProgressIndicator());
      }

      // Logika Pengecekan Error
      if (controller.errorMessage.value.isNotEmpty &&
          controller.selectedReservation.value?.id != reservationId) {
        return _buildErrorState(
          context,
          reservationId,
          controller.errorMessage.value,
        );
      }

      final reservation = controller.selectedReservation.value;

      // Kondisi jika reservasi tidak ditemukan
      if (reservation == null) {
        return _buildErrorState(
          context,
          reservationId,
          'Reservation details not found.',
        );
      }

      // Tampilkan data jika sudah ada
      return RefreshIndicator(
        onRefresh: () => _loadReservationDetails(reservationId),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusChip(context, reservation.status),
              const SizedBox(height: 16),
              _buildSectionCard(
                context: context,
                title: 'Session & Service',
                icon: Icons.event_note,
                children: [
                  _buildDetailRow(context, 'Reservation ID', reservation.id),
                  if (reservation.sessionDate != null)
                    _buildDetailRow(
                      context,
                      'Date',
                      TimeZoneUtil.formatDateTimeToIndonesiaDayDate(
                        reservation.sessionDate!,
                      ),
                    ),
                  if (reservation.sessionTime != null)
                    _buildDetailRow(context, 'Time', reservation.sessionTime!),
                  _buildDetailRow(
                    context,
                    'Service',
                    reservation.serviceName ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    'Staff',
                    reservation.staffName ?? 'N/A',
                  ),
                  _buildDetailRow(
                    context,
                    'Type',
                    reservation.reservationType == ReservationType.MANUAL
                        ? 'Manual Reservation'
                        : 'Online Booking',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                context: context,
                title: 'Customer & Baby',
                icon: Icons.person_outline,
                children: [
                  _buildDetailRow(
                    context,
                    'Customer Name',
                    reservation.customerName ?? 'N/A',
                  ),
                  _buildDetailRow(context, 'Baby Name', reservation.babyName),
                  _buildDetailRow(
                    context,
                    'Baby Age',
                    '${reservation.babyAge} months',
                  ),
                  if (reservation.parentNames != null &&
                      reservation.parentNames!.isNotEmpty)
                    _buildDetailRow(
                      context,
                      'Parent Names',
                      reservation.parentNames!,
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // --- PERBAIKAN 2: Sederhanakan Tampilan Payment ---
              // Langsung cek dari controller.selectedPaymentDetails
              _buildPaymentSection(
                context,
                controller.selectedPaymentDetails.value,
              ),

              if (reservation.notes != null &&
                  reservation.notes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSectionCard(
                  context: context,
                  title: 'Reservation Notes',
                  icon: Icons.notes_rounded,
                  children: [
                    Text(
                      reservation.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    });
  }

  // --- WIDGET BARU UNTUK PAYMENT ---
  Widget _buildPaymentSection(BuildContext context, Payment? payment) {
    // Jika tidak ada data payment sama sekali
    if (payment == null) {
      return _buildSectionCard(
        context: context,
        title: 'Payment Summary',
        icon: Icons.payment_outlined,
        children: const [
          Center(
            child: Text("No payment details available for this reservation."),
          ),
        ],
      );
    }

    // Jika ada data payment
    return _buildPaymentDetailsCard(context, payment);
  }

  Widget _buildStatusChip(BuildContext context, ReservationStatus status) {
    // ... (Fungsi ini tidak berubah, biarkan seperti sebelumnya)
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode;

    Color chipColor;
    Color textColor;
    String statusText = controller.getStatusDisplayName(
      status.toString().split('.').last,
    );

    switch (status) {
      case ReservationStatus.PENDING:
      case ReservationStatus.PENDING_PAYMENT:
        chipColor = isDark ? Colors.orange.shade800 : Colors.orange.shade100;
        textColor = isDark ? Colors.orange.shade100 : Colors.orange.shade900;
        if (status == ReservationStatus.PENDING_PAYMENT) {
          statusText = 'Pending Payment';
        }
        break;
      case ReservationStatus.CONFIRMED:
        chipColor = isDark ? Colors.blue.shade800 : Colors.blue.shade100;
        textColor = isDark ? Colors.blue.shade100 : Colors.blue.shade900;
        break;
      case ReservationStatus.IN_PROGRESS:
        chipColor = isDark ? Colors.teal.shade800 : Colors.teal.shade100;
        textColor = isDark ? Colors.teal.shade100 : Colors.teal.shade900;
        break;
      case ReservationStatus.COMPLETED:
        chipColor = isDark ? Colors.green.shade800 : Colors.green.shade100;
        textColor = isDark ? Colors.green.shade100 : Colors.green.shade900;
        break;
      case ReservationStatus.CANCELLED:
      case ReservationStatus.EXPIRED:
        chipColor = isDark ? Colors.red.shade800 : Colors.red.shade100;
        textColor = isDark ? Colors.red.shade100 : Colors.red.shade900;
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(
          statusText,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: chipColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildPaymentDetailsCard(BuildContext context, Payment payment) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return _buildSectionCard(
      context: context,
      title: 'Payment Details',
      icon: Icons.receipt_long_outlined,
      children: [
        _buildDetailRow(context, 'Payment ID', payment.id),
        _buildDetailRow(context, 'Method', payment.paymentMethod),
        _buildDetailRow(context, 'Status', payment.paymentStatus.toUpperCase()),
        _buildDetailRow(
          context,
          'Amount',
          currencyFormatter.format(payment.amount),
        ),
        if (payment.paymentDate != null)
          _buildDetailRow(
            context,
            'Payment Date',
            TimeZoneUtil.formatISOToLocalDateTimeFull(
              payment.paymentDate!.toIso8601String(),
            ),
          ),

        if (payment.paymentProof != null && payment.paymentProof!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    "Payment Proof",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  ':  ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap:
                        () => Get.dialog(
                          AlertDialog(
                            content: CachedNetworkImage(
                              imageUrl: payment.paymentProof!,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) =>
                                      const Text('Could not load image.'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: Get.back,
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        ),
                    child: Text(
                      "View Proof",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    // ... (Fungsi ini tidak berubah)
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    // ... (Fungsi ini tidak berubah)
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            ':  ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String reservationId,
    String message,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 50),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 16),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Retry',
              onPressed: () => _loadReservationDetails(reservationId),
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }
}
