// lib/features/time_slot/views/time_slot_view.dart
import 'package:emababyspa/features/schedule/controllers/schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/time_slot/controllers/time_slot_controller.dart';
import 'package:emababyspa/features/session/controllers/session_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/timezone_utils.dart';

class TimeSlotView extends StatefulWidget {
  const TimeSlotView({super.key});

  @override
  State<TimeSlotView> createState() => _TimeSlotViewState();
}

class _TimeSlotViewState extends State<TimeSlotView> {
  final controller = Get.find<TimeSlotController>();
  final sessionController = Get.find<SessionController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    final timeSlot = args['timeSlot'];
    // Fetch sessions using controller
    sessionController.fetchSessions(timeSlotId: timeSlot.id);
  }

  @override
  Widget build(BuildContext context) {
    // Get the time slot from arguments
    final args = Get.arguments as Map<String, dynamic>;
    final timeSlot = args['timeSlot'];

    // Format date and times using TimeZoneUtil
    final String dateFormatted = TimeZoneUtil.formatISOToIndonesiaTime(
      timeSlot.startTime.toIso8601String(),
      format: 'EEEE, d MMMM yyyy',
    );

    final String startTime = TimeZoneUtil.formatISOToIndonesiaTime(
      timeSlot.startTime.toIso8601String(),
    );

    final String endTime = TimeZoneUtil.formatISOToIndonesiaTime(
      timeSlot.endTime.toIso8601String(),
    );

    return MainLayout(
      child: Scaffold(
        appBar: _buildAppBar(context, timeSlot),
        body: _buildBody(context, timeSlot, dateFormatted, startTime, endTime),
      ),
    );
  }

  // Build app bar with actions
  PreferredSizeWidget _buildAppBar(BuildContext context, dynamic timeSlot) {
    return AppBar(
      title: Text(
        'Time Slot Details',
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
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit Time Slot',
          onPressed: () {
            // Navigate to edit page with time slot ID in route and pass time slot object
            Get.toNamed(
              AppRoutes.timeSlotEdit.replaceAll(':id', timeSlot.id.toString()),
              arguments: {'timeSlot': timeSlot},
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete Time Slot',
          onPressed: () {
            _showDeleteConfirmation(context, timeSlot);
          },
        ),
      ],
    );
  }

  // Build the main body content
  Widget _buildBody(
    BuildContext context,
    dynamic timeSlot,
    String dateFormatted,
    String startTime,
    String endTime,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data when pulled down
        await controller.fetchTimeSlotById(timeSlot.id);
        await sessionController.fetchSessions(timeSlotId: timeSlot.id);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(dateFormatted),
                const SizedBox(height: 16),
                // Use Obx to reactively update time slot header with session stats
                Obx(
                  () => _buildTimeSlotHeader(
                    startTime,
                    endTime,
                    timeSlot,
                    sessionController.sessions,
                  ),
                ),
                const SizedBox(height: 24),
                // Use Obx for reactive session list updates
                _buildSessionsSection(context, timeSlot),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build date header
  Widget _buildDateHeader(String dateFormatted) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: ColorTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 16, color: ColorTheme.primary),
          const SizedBox(width: 8),
          Text(
            dateFormatted,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: ColorTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Header section showing time slot details
  Widget _buildTimeSlotHeader(
    String startTime,
    String endTime,
    dynamic timeSlot,
    List<dynamic> sessions,
  ) {
    // Ensure sessions is always a non-null list
    final safeSessionsList = sessions;

    // Calculate session statistics
    final int totalSessions = safeSessionsList.length;
    final int bookedSessions =
        safeSessionsList.where((session) => session.isBooked == true).length;
    final int availableSessions = totalSessions - bookedSessions;
    final bool allBooked = totalSessions > 0 && bookedSessions == totalSessions;

    return Container(
      padding: const EdgeInsets.all(16),
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
          // Time header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: ColorTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Slot',
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$startTime - $endTime',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(allBooked),
            ],
          ),

          const SizedBox(height: 24),

          // Session statistics
          Row(
            children: [
              _buildStatCard(
                title: 'Total Sessions',
                value: '$totalSessions',
                icon: Icons.group_work_outlined,
                color: ColorTheme.primary,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Booked',
                value: '$bookedSessions',
                icon: Icons.event_busy,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Available',
                value: '$availableSessions',
                icon: Icons.event_available,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Status badge widget
  Widget _buildStatusBadge(bool allBooked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: allBooked ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: allBooked ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Text(
        allBooked ? 'Fully Booked' : 'Available',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: allBooked ? Colors.red.shade700 : Colors.green.shade700,
        ),
      ),
    );
  }

  // Stats card widget
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: ColorTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Sessions section with reactive Obx list
  Widget _buildSessionsSection(BuildContext context, dynamic timeSlot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Sessions', timeSlot),
        const SizedBox(height: 12),
        // Use Obx to reactively update the session list
        Obx(() {
          final sessions = sessionController.sessions;

          return sessions.isEmpty
              ? _buildEmptySessions(timeSlot)
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return _buildSessionItem(context, session);
                },
              );
        }),
      ],
    );
  }

  // Section header with optional action button
  Widget _buildSectionHeader(String title, dynamic timeSlot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorTheme.textPrimary,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            _showAddSessionDialog(Get.context!, timeSlot);
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add Sessions'),
          style: TextButton.styleFrom(foregroundColor: ColorTheme.primary),
        ),
      ],
    );
  }

  // Empty state for no sessions
  Widget _buildEmptySessions(dynamic timeSlot) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_note,
              size: 48,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Sessions Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add sessions to this time slot',
            style: TextStyle(fontSize: 14, color: ColorTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Add Sessions',
            icon: Icons.add_circle_outline,
            onPressed: () {
              _showAddSessionDialog(Get.context!, timeSlot);
            },
          ),
        ],
      ),
    );
  }

  // Session item card
  Widget _buildSessionItem(BuildContext context, dynamic session) {
    final bool isBooked = session.isBooked ?? false;

    // Safely get customer name from reservation if available
    String customerName = "Customer";
    if (session.reservation != null) {
      // Use babyName as customer identifier since customer object is not included
      if (session.reservation?.babyName != null &&
          session.reservation!.babyName.isNotEmpty) {
        customerName = session.reservation!.babyName;
      }
      // Or if you have parentNames field available:
      else if (session.reservation?.parentNames != null &&
          session.reservation!.parentNames!.isNotEmpty) {
        customerName = session.reservation!.parentNames!;
      }
    }

    // Safely get staff name
    String staffName = "Staff";
    if (session.staff != null && session.staff?.name != null) {
      staffName = session.staff!.name;
    }

    // Determine session type/service type - you might need to fetch service details separately
    String serviceType = "Regular Session";
    if (session.reservation != null) {
      // You can customize this based on your service data structure
      serviceType = "Spa Session for ${session.reservation!.babyName}";
    }

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteSessionConfirmation(context, session);
      },
      onDismissed: (direction) {
        sessionController.deleteSession(session.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Get.toNamed(
                  AppRoutes.sessionDetail,
                  arguments: {'session': session},
                );
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isBooked
                            ? [Colors.red.shade100, Colors.red.shade50]
                            : [Colors.green.shade100, Colors.green.shade50],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Session icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              isBooked
                                  ? Colors.red.shade50
                                  : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isBooked ? Icons.person : Icons.person_outline,
                          color: isBooked ? Colors.red : Colors.green,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Session details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceType,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isBooked
                                  ? 'Booked for $customerName'
                                  : 'Available for booking',
                              style: TextStyle(
                                fontSize: 14,
                                color: ColorTheme.textSecondary,
                              ),
                            ),
                            if (session.staffId != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 14,
                                    color: ColorTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Staff: $staffName',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ColorTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Booking status toggle
                      Switch(
                        value: isBooked,
                        activeColor: Colors.red,
                        onChanged: (value) {
                          _showToggleBookingConfirmation(
                            context,
                            session,
                            value,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Confirmation dialog for toggling session booking status
  Future<void> _showToggleBookingConfirmation(
    BuildContext context,
    dynamic session,
    bool newBookingStatus,
  ) async {
    final action = newBookingStatus ? 'book' : 'unbook';

    return showDialog<void>(
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

  // Confirmation dialog for deleting a session
  Future<bool> _showDeleteSessionConfirmation(
    BuildContext context,
    dynamic session,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Session'),
          content: const Text('Are you sure you want to delete this session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final success = await sessionController.deleteSession(session.id);
      if (success) {
        // Refresh data setelah penghapusan
        await sessionController.refreshSessions(session.timeSlotId);
        // Paksa update ScheduleView
        Get.find<ScheduleController>().refreshData(
          specificTimeSlotId: session.timeSlotId,
        );
      }
      return success;
    }
    return false;
  }

  void _showAddSessionDialog(BuildContext context, dynamic timeSlot) {
    // Navigate to the session form view with required arguments
    Get.toNamed(
      AppRoutes.sessionForm,
      arguments: {
        'timeSlotId': timeSlot.id.toString(),
        'existingSessions': sessionController.sessions,
      },
    );
    // No need for callback handling anymore as we're using reactive Obx
  }

  // Confirmation dialog for deleting a time slot
  void _showDeleteConfirmation(BuildContext context, dynamic timeSlot) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Time Slot'),
          content: const Text(
            'Are you sure you want to delete this time slot? This will also delete all associated sessions and cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Simpan timeSlotId sebelum dihapus
                final timeSlotId = timeSlot.id;

                final success = await controller.deleteTimeSlot(timeSlotId);
                if (success) {
                  // Refresh data di ScheduleController dengan method yang lebih komprehensif
                  final scheduleController = Get.find<ScheduleController>();
                  await scheduleController
                      .fetchScheduleData(); // Gunakan method baru

                  // Kembali ke halaman sebelumnya
                  Get.back();

                  Get.snackbar(
                    'Success',
                    'Time slot deleted successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to delete time slot',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
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
