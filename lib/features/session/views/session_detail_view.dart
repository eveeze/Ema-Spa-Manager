// lib/features/session/views/session_detail_view.dart

import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/text_theme.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/data/models/session.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionDetailView extends StatefulWidget {
  const SessionDetailView({super.key});

  @override
  State<SessionDetailView> createState() => _SessionDetailViewState();
}

class _SessionDetailViewState extends State<SessionDetailView> {
  final sessionController = Get.find<SessionController>();
  late Session session;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    session = args['session'];

    // --- PERBAIKAN DI SINI ---
    // Kita panggil getSessionById setelah frame pertama selesai di-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Memastikan widget masih ada di tree
        sessionController.getSessionById(session.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (_) {
        return MainLayout(
          child: Scaffold(
            appBar: _buildAppBar(context),
            body: _buildBody(context),
            bottomNavigationBar: _buildBottomActions(context),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      title: const Text('Session Details'),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmation(context);
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: M3Spacing.md),
                      Text(
                        'Delete Session',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await sessionController.getSessionById(session.id),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: M3Spacing.md),
        child: Obx(() {
          // Gunakan data dari controller jika sudah ada, jika tidak, gunakan data dari argumen
          final currentSession =
              sessionController.currentSession.value ?? session;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: M3Spacing.md),
              _buildStatusHeader(context, currentSession),
              const SizedBox(height: M3Spacing.lg),
              _buildSessionInfoCard(context, currentSession),
              const SizedBox(height: M3Spacing.lg),
              _buildTimeSlotInfoCard(context, currentSession),
              const SizedBox(height: M3Spacing.lg),
              _buildStaffInfoCard(context, currentSession),
              const SizedBox(height: M3Spacing.lg),
              _buildReservationCard(context, currentSession),
              const SizedBox(height: 120),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, Session session) {
    final isBooked = session.isBooked;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Color containerColor =
        isBooked ? colorScheme.errorContainer : colorScheme.primaryContainer;
    final Color contentColor =
        isBooked
            ? colorScheme.onErrorContainer
            : colorScheme.onPrimaryContainer;
    final IconData icon =
        isBooked ? Icons.event_busy_rounded : Icons.event_available_rounded;

    return Card(
      color: containerColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(M3Spacing.lg),
        child: Row(
          children: [
            Icon(icon, color: contentColor, size: 40),
            const SizedBox(width: M3Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBooked ? 'Booked Session' : 'Available Session',
                    style: textTheme.titleLarge?.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: M3Spacing.xs),
                  Text(
                    isBooked
                        ? 'This session is currently booked.'
                        : 'This session is available for booking.',
                    style: textTheme.bodyMedium?.copyWith(color: contentColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(M3Spacing.md),
            child: Row(
              children: [
                Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
                const SizedBox(width: M3Spacing.sm),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(M3Spacing.md),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: M3Spacing.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: M3Spacing.md),
          Expanded(
            child: SelectableText(
              value,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard(BuildContext context, Session session) {
    return _buildInfoCard(
      context: context,
      title: 'Session Information',
      icon: Icons.info_outline_rounded,
      children: [
        _buildInfoRow(context, 'Session ID', session.id),
        _buildInfoRow(
          context,
          'Booking Status',
          session.isBooked ? 'Booked' : 'Available',
        ),
        _buildInfoRow(
          context,
          'Created At',
          TimeZoneUtil.formatISOToIndonesiaTime(
            session.createdAt.toIso8601String(),
            format: 'EEEE, d MMMM yyyy HH:mm',
          ),
        ),
        _buildInfoRow(
          context,
          'Last Updated',
          TimeZoneUtil.formatISOToIndonesiaTime(
            session.updatedAt.toIso8601String(),
            format: 'EEEE, d MMMM yyyy HH:mm',
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotInfoCard(BuildContext context, Session session) {
    final timeSlot = session.timeSlot;
    return _buildInfoCard(
      context: context,
      title: 'Time Slot Information',
      icon: Icons.access_time_rounded,
      children: [
        if (timeSlot != null) ...[
          _buildInfoRow(
            context,
            'Date',
            TimeZoneUtil.formatISOToIndonesiaTime(
              timeSlot.startTime.toIso8601String(),
              format: 'EEEE, d MMMM yyyy',
            ),
          ),
          _buildInfoRow(
            context,
            'Start Time',
            TimeZoneUtil.formatISOToIndonesiaTime(
              timeSlot.startTime.toIso8601String(),
              format: 'HH:mm',
            ),
          ),
          _buildInfoRow(
            context,
            'End Time',
            TimeZoneUtil.formatISOToIndonesiaTime(
              timeSlot.endTime.toIso8601String(),
              format: 'HH:mm',
            ),
          ),
          _buildInfoRow(
            context,
            'Duration',
            '${timeSlot.endTime.difference(timeSlot.startTime).inMinutes} minutes',
          ),
        ] else
          _buildInfoRow(context, 'Time Slot ID', session.timeSlotId),
      ],
    );
  }

  Widget _buildStaffInfoCard(BuildContext context, Session session) {
    final staff = session.staff;
    return _buildInfoCard(
      context: context,
      title: 'Staff Information',
      icon: Icons.person_outline_rounded,
      children: [
        if (staff != null) ...[
          _buildInfoRow(context, 'Staff Name', staff.name),
          _buildInfoRow(context, 'Email', staff.email),
          _buildInfoRow(context, 'Phone', staff.phoneNumber),
          _buildInfoRow(
            context,
            'Status',
            staff.isActive ? 'Active' : 'Inactive',
          ),
        ] else
          _buildInfoRow(context, 'Staff ID', session.staffId),
      ],
    );
  }

  Widget _buildEmptyReservationState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(M3Spacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 48,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(height: M3Spacing.md),
          Text(
            'No Reservation',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: M3Spacing.sm),
          Text(
            'This session is not yet reserved by any customer.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, Session session) {
    final reservation = session.reservation;
    return _buildInfoCard(
      context: context,
      title: 'Reservation Information',
      icon:
          reservation != null
              ? Icons.event_note_rounded
              : Icons.event_note_outlined,
      children: [
        if (reservation != null) ...[
          _buildInfoRow(context, 'Reservation ID', reservation.id),
          _buildInfoRow(
            context,
            'Type',
            _getReservationTypeText(reservation.reservationType),
          ),
          _buildInfoRow(context, 'Baby Name', reservation.babyName),
          _buildInfoRow(context, 'Baby Age', '${reservation.babyAge} months'),
          if (reservation.parentNames != null &&
              reservation.parentNames!.isNotEmpty)
            _buildInfoRow(context, 'Parent Names', reservation.parentNames!),
          _buildInfoRow(
            context,
            'Status',
            _getReservationStatusText(reservation.status),
          ),
          _buildInfoRow(
            context,
            'Total Price',
            'Rp ${reservation.totalPrice.toStringAsFixed(0)}',
          ),
          if (reservation.notes != null && reservation.notes!.isNotEmpty)
            _buildInfoRow(context, 'Notes', reservation.notes!),
          _buildInfoRow(
            context,
            'Reserved At',
            TimeZoneUtil.formatISOToIndonesiaTime(
              reservation.createdAt.toIso8601String(),
              format: 'EEEE, d MMMM yyyy HH:mm',
            ),
          ),
        ] else
          _buildEmptyReservationState(context),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final currentSession = sessionController.currentSession.value ?? session;
      final hasReservation = currentSession.reservation != null;
      final isBooked = currentSession.isBooked;

      return Container(
        padding: const EdgeInsets.all(M3Spacing.md).copyWith(
          bottom: M3Spacing.md + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!hasReservation && !isBooked)
              AppButton(
                text: 'Add Manual Reservation',
                onPressed:
                    () => _navigateToReservationForm(context, currentSession),
                icon: Icons.add_circle_outline,
                type: AppButtonType.primary,
                isFullWidth: true,
              ),
            if (hasReservation)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'View',
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.reservationDetail.replaceAll(
                            ':id',
                            currentSession.reservation!.id,
                          ),
                        );
                      },
                      type: AppButtonType.outline,
                      icon: Icons.visibility_outlined,
                    ),
                  ),
                  const SizedBox(width: M3Spacing.md),
                  Expanded(
                    child: AppButton(
                      text: 'Edit',
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.reservationEdit.replaceAll(
                            ':id',
                            currentSession.reservation!.id,
                          ),
                        );
                      },
                      type: AppButtonType.primary,
                      icon: Icons.edit_outlined,
                    ),
                  ),
                ],
              ),
            if (hasReservation) const SizedBox(height: M3Spacing.sm),
            AppButton(
              text: isBooked ? 'Mark as Available' : 'Mark as Booked',
              icon:
                  isBooked
                      ? Icons.event_available_outlined
                      : Icons.event_busy_outlined,
              onPressed:
                  () => _showToggleBookingConfirmation(
                    context,
                    currentSession,
                    !isBooked,
                  ),
              type: AppButtonType.outline,
              isFullWidth: true,
            ),
          ],
        ),
      );
    });
  }

  void _showCustomSnackbar(
    String title,
    String message, {
    bool isError = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    Get.snackbar(
      title,
      message,
      backgroundColor:
          isError ? colorScheme.errorContainer : colorScheme.primaryContainer,
      colorText:
          isError
              ? colorScheme.onErrorContainer
              : colorScheme.onPrimaryContainer,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(M3Spacing.md),
      borderRadius: 12,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color:
            isError
                ? colorScheme.onErrorContainer
                : colorScheme.onPrimaryContainer,
      ),
    );
  }

  void _navigateToReservationForm(BuildContext context, Session session) {
    Get.toNamed(
      AppRoutes.reservationForm,
      arguments: {'session': session},
    )?.then((result) {
      if (result == true) {
        sessionController.getSessionById(session.id);
        _showCustomSnackbar(
          'Success',
          'Manual reservation created successfully',
        );
      }
    });
  }

  void _showToggleBookingConfirmation(
    BuildContext context,
    Session session,
    bool newBookingStatus,
  ) {
    final action = newBookingStatus ? 'book' : 'unbook';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${newBookingStatus ? 'Book' : 'Unbook'} Session'),
          content: Text('Are you sure you want to $action this session?'),
          actions: [
            AppButton(
              text: 'Cancel',
              onPressed: () => Get.back(),
              type: AppButtonType.text,
              size: AppButtonSize.small,
            ),
            AppButton(
              text: newBookingStatus ? 'Book' : 'Unbook',
              type: AppButtonType.text,
              size: AppButtonSize.small,
              onPressed: () {
                Get.back();
                sessionController.updateSessionBookingStatus(
                  session.id,
                  newBookingStatus,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Session'),
          content: const Text(
            'Are you sure you want to delete this session? This action cannot be undone.',
          ),
          actions: [
            AppButton(
              text: 'Cancel',
              onPressed: () => Get.back(),
              type: AppButtonType.text,
              size: AppButtonSize.small,
            ),
            AppButton(
              text: 'Delete',
              type: AppButtonType.text,
              size: AppButtonSize.small,
              onPressed: () {
                Get.back(); // Close dialog
                sessionController.deleteSession(session.id).then((success) {
                  if (success) {
                    Get.back(); // Return to previous screen
                    _showCustomSnackbar(
                      'Success',
                      'Session deleted successfully',
                    );
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  String _getReservationTypeText(ReservationType type) =>
      type == ReservationType.ONLINE ? 'Online Booking' : 'Manual Reservation';

  String _getReservationStatusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.PENDING:
      case ReservationStatus.PENDING_PAYMENT:
        return 'Pending';
      case ReservationStatus.CONFIRMED:
        return 'Confirmed';
      case ReservationStatus.IN_PROGRESS:
        return 'In Progress';
      case ReservationStatus.COMPLETED:
        return 'Completed';
      case ReservationStatus.CANCELLED:
        return 'Cancelled';
      case ReservationStatus.EXPIRED:
        return 'Expired';
    }
  }
}
