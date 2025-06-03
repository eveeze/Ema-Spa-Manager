// lib/features/session/views/session_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:emababyspa/data/models/session.dart';
import 'package:emababyspa/data/models/reservation.dart';

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

    // Refresh session data to get latest information
    sessionController.getSessionById(session.id);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        bottomNavigationBar: _buildBottomActions(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Session Details',
        style: TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: ColorTheme.primary),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete Session',
          onPressed: () {
            _showDeleteConfirmation(context);
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await sessionController.getSessionById(session.id);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, ColorTheme.primary.withValues(alpha: 0.05)],
          ),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              final currentSession =
                  sessionController.currentSession.value ?? session;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(currentSession),
                  const SizedBox(height: 20),
                  _buildSessionInfoCard(currentSession),
                  const SizedBox(height: 20),
                  _buildTimeSlotInfoCard(currentSession),
                  const SizedBox(height: 20),
                  _buildStaffInfoCard(currentSession),
                  const SizedBox(height: 20),
                  _buildReservationCard(currentSession),
                  const SizedBox(height: 100), // Space for bottom actions
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(Session session) {
    final isBooked = session.isBooked;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isBooked
                  ? [Colors.red.shade100, Colors.red.shade50]
                  : [Colors.green.shade100, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isBooked ? Colors.red.shade200 : Colors.green.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBooked ? Icons.event_busy : Icons.event_available,
              color: isBooked ? Colors.red.shade700 : Colors.green.shade700,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBooked ? 'Booked Session' : 'Available Session',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:
                        isBooked ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isBooked
                      ? 'This session is currently booked'
                      : 'This session is available for booking',
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard(Session session) {
    return _buildInfoCard(
      title: 'Session Information',
      icon: Icons.info_outline,
      children: [
        _buildInfoRow('Session ID', session.id),
        _buildInfoRow(
          'Booking Status',
          session.isBooked ? 'Booked' : 'Available',
        ),
        _buildInfoRow(
          'Created At',
          TimeZoneUtil.formatISOToIndonesiaTime(
            session.createdAt.toIso8601String(),
            format: 'EEEE, d MMMM yyyy HH:mm',
          ),
        ),
        _buildInfoRow(
          'Last Updated',
          TimeZoneUtil.formatISOToIndonesiaTime(
            session.updatedAt.toIso8601String(),
            format: 'EEEE, d MMMM yyyy HH:mm',
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotInfoCard(Session session) {
    final timeSlot = session.timeSlot;

    return _buildInfoCard(
      title: 'Time Slot Information',
      icon: Icons.access_time,
      children: [
        if (timeSlot != null) ...[
          _buildInfoRow(
            'Date',
            TimeZoneUtil.formatISOToIndonesiaTime(
              timeSlot.startTime.toIso8601String(),
              format: 'EEEE, d MMMM yyyy',
            ),
          ),
          _buildInfoRow(
            'Start Time',
            TimeZoneUtil.formatISOToIndonesiaTime(
              timeSlot.startTime.toIso8601String(),
              format: 'HH:mm',
            ),
          ),
          _buildInfoRow(
            'End Time',
            TimeZoneUtil.formatISOToIndonesiaTime(
              timeSlot.endTime.toIso8601String(),
              format: 'HH:mm',
            ),
          ),
          _buildInfoRow(
            'Duration',
            '${timeSlot.endTime.difference(timeSlot.startTime).inMinutes} minutes',
          ),
        ] else ...[
          _buildInfoRow('Time Slot ID', session.timeSlotId),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Time slot details not loaded',
              style: TextStyle(
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStaffInfoCard(Session session) {
    final staff = session.staff;

    return _buildInfoCard(
      title: 'Staff Information',
      icon: Icons.person,
      children: [
        if (staff != null) ...[
          _buildInfoRow('Staff Name', staff.name),
          _buildInfoRow('Email', staff.email),
          _buildInfoRow('Phone', staff.phoneNumber),
          _buildInfoRow('Status', staff.isActive ? 'Active' : 'Inactive'),
        ] else ...[
          _buildInfoRow('Staff ID', session.staffId),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Staff details not loaded',
              style: TextStyle(
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReservationCard(Session session) {
    final reservation = session.reservation;
    final hasReservation = reservation != null;

    return _buildInfoCard(
      title: 'Reservation Information',
      icon: hasReservation ? Icons.event_note : Icons.event_note_outlined,
      children: [
        if (hasReservation) ...[
          _buildInfoRow('Reservation ID', reservation.id),
          _buildInfoRow(
            'Type',
            _getReservationTypeText(reservation.reservationType),
          ),
          _buildInfoRow('Baby Name', reservation.babyName),
          _buildInfoRow('Baby Age', '${reservation.babyAge} months'),
          if (reservation.parentNames != null &&
              reservation.parentNames!.isNotEmpty)
            _buildInfoRow('Parent Names', reservation.parentNames!),
          _buildInfoRow(
            'Status',
            _getReservationStatusText(reservation.status),
          ),
          _buildInfoRow(
            'Total Price',
            'Rp ${reservation.totalPrice.toStringAsFixed(0)}',
          ),
          if (reservation.notes != null && reservation.notes!.isNotEmpty)
            _buildInfoRow('Notes', reservation.notes!),
          _buildInfoRow(
            'Reserved At',
            TimeZoneUtil.formatISOToIndonesiaTime(
              reservation.createdAt.toIso8601String(),
              format: 'EEEE, d MMMM yyyy HH:mm',
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_note_outlined,
                  size: 48,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 12),
                Text(
                  'No Reservation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This session is not yet reserved by any customer',
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorTheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: ColorTheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ColorTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: ColorTheme.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Obx(() {
      final currentSession = sessionController.currentSession.value ?? session;
      final hasReservation = currentSession.reservation != null;
      final isBooked = currentSession.isBooked;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!hasReservation && !isBooked) ...[
                AppButton(
                  text: 'Add Manual Reservation',
                  icon: Icons.add_circle_outline,
                  onPressed: () {
                    _navigateToReservationForm(context, currentSession);
                  },
                ),
              ] else if (hasReservation) ...[
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'View Reservation',
                        icon: Icons.visibility,
                        onPressed: () {
                          // Navigasi dengan pattern yang konsisten dengan halaman lain
                          Get.toNamed(
                            AppRoutes.reservationDetail.replaceAll(
                              ':id',
                              currentSession.reservation!.id,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Edit Reservation',
                        icon: Icons.edit,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: isBooked ? 'Mark as Available' : 'Mark as Booked',
                      icon: isBooked ? Icons.event_available : Icons.event_busy,
                      onPressed: () {
                        _showToggleBookingConfirmation(
                          context,
                          currentSession,
                          !isBooked,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  String _getReservationTypeText(ReservationType type) {
    switch (type) {
      case ReservationType.ONLINE:
        return 'Online Booking';
      case ReservationType.MANUAL:
        return 'Manual Reservation';
    }
  }

  String _getReservationStatusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.PENDING:
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
      case ReservationStatus.PENDING_PAYMENT:
        return 'Pending';
    }
  }

  // Improved navigation method for creating manual reservation
  void _navigateToReservationForm(BuildContext context, Session session) {
    try {
      // Navigate directly to reservation form with session data
      Get.toNamed(
        AppRoutes.reservationForm,
        arguments: {
          'session': session,
          'type': 'manual',
          'sessionId': session.id,
          'timeSlot': session.timeSlot,
          'staff': session.staff,
        },
      )?.then((result) {
        // Handle result when returning from reservation form
        if (result != null && result is Map<String, dynamic>) {
          if (result['success'] == true) {
            // Refresh session data after successful reservation creation
            sessionController.getSessionById(session.id);

            // Show success message
            Get.snackbar(
              'Success',
              'Manual reservation created successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 3),
            );
          }
        }
      });
    } catch (e) {
      // Handle navigation error
      Get.snackbar(
        'Error',
        'Failed to navigate to reservation form: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Alternative method using dialog confirmation (keeping the original for reference)

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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                sessionController.updateSessionBookingStatus(
                  session.id,
                  newBookingStatus,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: newBookingStatus ? Colors.red : Colors.green,
              ),
              child: Text(newBookingStatus ? 'Book' : 'Unbook'),
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
            'Are you sure you want to delete this session? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                sessionController.deleteSession(session.id).then((success) {
                  if (success) {
                    Get.back(); // Return to previous screen
                    Get.snackbar(
                      'Success',
                      'Session deleted successfully',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                });
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
