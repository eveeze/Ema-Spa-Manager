// lib/features/reservation/views/reservation_detail_view.dart
import 'package:emababyspa/data/models/payment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:intl/intl.dart'; // For currency formatting

// Helper function to darken a color
Color _darkenColor(Color color, [double amount = 0.3]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

class ReservationDetailView extends GetView<ReservationController> {
  const ReservationDetailView({super.key});

  Future<void> _loadReservationDetails(String reservationId) async {
    if (reservationId.isEmpty) {
      Get.snackbar(
        'Error',
        'Reservation ID is missing.',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
      // Attempt to pop only if navigation stack allows
      if (Navigator.of(Get.context!).canPop()) {
        Get.back();
      }
      return;
    }
    controller.clearSelectedReservation();
    controller.clearSelectedPaymentDetails();
    await controller.fetchReservationById(reservationId);
    await controller.fetchOwnerPaymentDetails(reservationId);
  }

  @override
  Widget build(BuildContext context) {
    final String reservationId = Get.parameters['id'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (reservationId.isNotEmpty) {
        _loadReservationDetails(reservationId);
      } else {
        Get.snackbar(
          'Error',
          'Reservation ID not provided.',
          backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
          colorText: ColorTheme.error,
        );
        if (Navigator.of(Get.context!).canPop()) {
          Get.back();
        }
      }
    });

    return MainLayout(
      parentRoute: AppRoutes.schedule,
      showBottomNavigation: true,
      showAppBar: true,
      appBarTitle: 'Reservation Details',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            if (reservationId.isNotEmpty) {
              _loadReservationDetails(reservationId);
            } else {
              Get.snackbar(
                'Error',
                'Cannot refresh: Reservation ID is missing.',
              );
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
      final isLoadingForThisId =
          controller.isLoading.value &&
          (controller.selectedReservation.value == null ||
              (reservationId.isNotEmpty &&
                  controller.selectedReservation.value!.id != reservationId));

      if (isLoadingForThisId) {
        return const Center(child: CircularProgressIndicator());
      }

      final hasErrorForThisId =
          controller.errorMessage.value.isNotEmpty &&
          (controller.selectedReservation.value == null ||
              (reservationId.isNotEmpty &&
                  controller.selectedReservation.value!.id != reservationId));

      if (hasErrorForThisId) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: ColorTheme.error, size: 50),
                const SizedBox(height: 10),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ColorTheme.error, fontSize: 16),
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'Retry',
                  onPressed: () {
                    if (reservationId.isNotEmpty) {
                      _loadReservationDetails(reservationId);
                    } else {
                      Get.snackbar(
                        'Error',
                        'Cannot retry: Reservation ID is missing.',
                      );
                    }
                  },
                  icon: Icons.refresh,
                ),
              ],
            ),
          ),
        );
      }

      final reservation = controller.selectedReservation.value;

      if (reservation == null ||
          (reservationId.isNotEmpty && reservation.id != reservationId)) {
        if (reservationId.isEmpty &&
            !isLoadingForThisId &&
            !hasErrorForThisId) {
          return Center(
            child: Text(
              "Reservation ID is missing.",
              style: TextStyle(color: ColorTheme.error, fontSize: 16),
            ),
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, color: Colors.grey.shade400, size: 50),
              const SizedBox(height: 10),
              Text(
                reservationId.isNotEmpty
                    ? 'Reservation details not found.'
                    : 'Could not load reservation.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Go Back',
                onPressed: () => Get.back(),
                icon: Icons.arrow_back,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          if (reservationId.isNotEmpty) {
            await _loadReservationDetails(reservationId);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusChip(reservation.status),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Session & Service',
                icon: Icons.event_note,
                children: [
                  _buildDetailRow('Reservation ID', reservation.id),
                  if (reservation.sessionDate != null)
                    _buildDetailRow(
                      'Date',
                      TimeZoneUtil.formatDateTimeToIndonesiaDayDate(
                        reservation.sessionDate!,
                      ),
                    ),
                  if (reservation.sessionTime != null)
                    _buildDetailRow('Time', reservation.sessionTime!),
                  _buildDetailRow('Service', reservation.serviceName ?? 'N/A'),
                  _buildDetailRow('Staff', reservation.staffName ?? 'N/A'),
                  _buildDetailRow(
                    'Type',
                    reservation.reservationType == ReservationType.MANUAL
                        ? 'Manual Reservation'
                        : 'Online Booking',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: 'Customer Information',
                icon: Icons.person_outline,
                children: [
                  _buildDetailRow('Name', reservation.customerName ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: 'Baby Information',
                icon: Icons.child_care_outlined,
                children: [
                  _buildDetailRow('Name', reservation.babyName),
                  _buildDetailRow('Age', '${reservation.babyAge} months'),
                  if (reservation.parentNames != null &&
                      reservation.parentNames!.isNotEmpty)
                    _buildDetailRow('Parent Names', reservation.parentNames!),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: 'Payment Summary',
                icon: Icons.payment_outlined,
                children: [
                  _buildDetailRow(
                    'Total Price',
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(reservation.totalPrice),
                  ),
                  _buildDetailRow(
                    'Payment Status',
                    _getPaymentStatusFromReservation(reservation),
                  ),
                  if (reservation.notes != null &&
                      reservation.notes!.isNotEmpty)
                    _buildDetailRow('Reservation Notes', reservation.notes!),
                ],
              ),
              const SizedBox(height: 20),
              Obx(() {
                final paymentDetailsMatch =
                    controller.reservationForPaymentDetails.value?.id ==
                    reservationId;

                if (controller.isLoadingPaymentDetails.value &&
                    (controller.selectedPaymentDetails.value == null ||
                        !paymentDetailsMatch)) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (controller.selectedPaymentDetails.value == null ||
                    !paymentDetailsMatch) {
                  return AppButton(
                    text: 'Load Payment Info',
                    onPressed: () {
                      if (reservationId.isNotEmpty) {
                        controller.fetchOwnerPaymentDetails(reservationId);
                      } else {
                        Get.snackbar(
                          'Error',
                          'Cannot load payment info: Reservation ID is missing.',
                        );
                      }
                    },
                    type: AppButtonType.outline,
                    size: AppButtonSize.medium,
                  );
                }
                final payment = controller.selectedPaymentDetails.value!;
                return _buildPaymentDetailsCard(payment);
              }),
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatusChip(ReservationStatus status) {
    Color chipColor;
    String statusText = controller.getStatusDisplayName(
      status.toString().split('.').last,
    );

    switch (status) {
      case ReservationStatus.PENDING:
        chipColor = Colors.orange.shade100;
        break;
      case ReservationStatus.PENDING_PAYMENT:
        chipColor = Colors.orange.shade100;
        statusText = 'Pending Payment';
        break;
      case ReservationStatus.CONFIRMED:
        chipColor = Colors.blue.shade100;
        break;
      case ReservationStatus.IN_PROGRESS:
        chipColor = Colors.teal.shade100;
        break;
      case ReservationStatus.COMPLETED:
        chipColor = Colors.green.shade100;
        break;
      case ReservationStatus.CANCELLED:
      case ReservationStatus.EXPIRED:
        chipColor = Colors.red.shade100;
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(
          statusText,
          style: TextStyle(
            color: _darkenColor(chipColor, 0.4),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: chipColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  String _getPaymentStatusFromReservation(Reservation reservation) {
    if (reservation.status == ReservationStatus.PENDING_PAYMENT) {
      return 'UNPAID';
    }
    if (reservation.status == ReservationStatus.CONFIRMED ||
        reservation.status == ReservationStatus.IN_PROGRESS ||
        reservation.status == ReservationStatus.COMPLETED) {
      return 'PAID';
    }
    if (reservation.status == ReservationStatus.CANCELLED ||
        reservation.status == ReservationStatus.EXPIRED) {
      return 'N/A';
    }
    return 'PENDING';
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorTheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: ColorTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ColorTheme.textSecondary.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            ':  ',
            style: TextStyle(
              fontSize: 13,
              color: ColorTheme.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: valueColor ?? ColorTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(Payment payment) {
    return _buildSectionCard(
      title: 'Payment Details',
      icon: Icons.receipt_long_outlined,
      children: [
        _buildDetailRow('Payment ID', payment.id),
        _buildDetailRow('Method', payment.paymentMethod),
        _buildDetailRow('Status', payment.paymentStatus.toUpperCase()),
        _buildDetailRow(
          'Amount',
          NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(payment.amount),
        ),
        if (payment.transactionId != null && payment.transactionId!.isNotEmpty)
          _buildDetailRow('Transaction ID', payment.transactionId!),
        if (payment.paymentDate != null)
          _buildDetailRow(
            'Payment Date',
            TimeZoneUtil.formatISOToLocalDateTimeFull(
              payment.paymentDate!.toIso8601String(),
            ),
          ),
        if (payment.tripayPaymentUrl != null &&
            payment.tripayPaymentUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AppButton(
              text: 'View Payment Gateway',
              onPressed: () {
                Get.snackbar(
                  'Info',
                  'Payment URL: ${payment.tripayPaymentUrl}',
                );
              },
              icon: Icons.open_in_new,
              type: AppButtonType.outline,
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
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: ColorTheme.textSecondary.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  ':  ',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorTheme.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.dialog(
                        AlertDialog(
                          content:
                              payment.paymentProof!.startsWith('http')
                                  ? Image.network(
                                    payment.paymentProof!,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (
                                      BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Text('Could not load image.'),
                                  )
                                  : const Text(
                                    "Cannot display proof: Invalid URL or format.",
                                  ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text("Close"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      "View Proof",
                      style: TextStyle(
                        color: ColorTheme.primary,
                        decoration: TextDecoration.underline,
                        fontSize: 14,
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
}
