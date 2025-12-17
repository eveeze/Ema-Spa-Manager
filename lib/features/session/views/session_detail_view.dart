// lib/features/session/views/session_detail_view.dart
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
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

    // UI-only: tetap panggil setelah frame pertama untuk menghindari error build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(context),
            body: _buildBody(context),
            bottomNavigationBar: _buildBottomActions(context),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppBar(
      title: Text(
        'Detail Sesi',
        style:
            theme.appBarTheme.titleTextStyle ??
            textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      scrolledUnderElevation: 0,
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurface),
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
                      const SizedBox(width: 12),
                      Text(
                        'Hapus Sesi',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return RefreshIndicator(
      onRefresh: () async => await sessionController.getSessionById(session.id),
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: spacing.lg),
        child: Obx(() {
          final currentSession =
              sessionController.currentSession.value ?? session;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: spacing.md),
              _buildStatusHeader(context, currentSession),
              SizedBox(height: spacing.lg),
              _buildSessionInfoCard(context, currentSession),
              SizedBox(height: spacing.lg),
              _buildTimeSlotInfoCard(context, currentSession),
              SizedBox(height: spacing.lg),
              _buildStaffInfoCard(context, currentSession),
              SizedBox(height: spacing.lg),
              _buildReservationCard(context, currentSession),
              SizedBox(height: spacing.xxl + 64),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, Session session) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final semantic = theme.extension<AppSemanticColors>();

    final bool isBooked = session.isBooked;

    final Color okColor = semantic?.success ?? colorScheme.tertiary;
    final Color warningColor = colorScheme.error;

    final Color containerColor =
        isBooked
            ? colorScheme.errorContainer.withValues(alpha: 0.85)
            : okColor.withValues(alpha: 0.14);
    final Color contentColor =
        isBooked ? colorScheme.onErrorContainer : okColor;

    final IconData icon =
        isBooked ? Icons.event_busy_rounded : Icons.event_available_rounded;

    final String title = isBooked ? 'Sesi Terpesan' : 'Sesi Tersedia';
    final String subtitle =
        isBooked
            ? 'Sesi ini sedang terisi oleh pemesanan.'
            : 'Sesi ini masih tersedia untuk pemesanan.';

    return Card(
      elevation: 0,
      color: containerColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(
          color: (isBooked ? warningColor : okColor).withValues(alpha: 0.18),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: spacing.xxl,
              width: spacing.xxl,
              decoration: BoxDecoration(
                color: (isBooked ? warningColor : okColor).withValues(
                  alpha: 0.14,
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: (isBooked ? warningColor : okColor).withValues(
                    alpha: 0.22,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: contentColor, size: 26),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.70),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: spacing.xl,
                  width: spacing.xl,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.70),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.70),
              height: 1,
            ),
            SizedBox(height: spacing.md),
            Column(children: children),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96, maxWidth: 140),
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: SelectableText(
              value,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard(BuildContext context, Session session) {
    return _buildInfoCard(
      context: context,
      title: 'Informasi Sesi',
      icon: Icons.info_outline_rounded,
      children: [
        _buildInfoRow(context, 'ID Sesi', session.id),
        _buildInfoRow(
          context,
          'Status',
          session.isBooked ? 'Terpesan' : 'Tersedia',
        ),
        _buildInfoRow(
          context,
          'Dibuat',
          TimeZoneUtil.formatISOToIndonesiaTime(
            session.createdAt.toIso8601String(),
            format: 'EEEE, d MMMM yyyy HH:mm',
          ),
        ),
        _buildInfoRow(
          context,
          'Diperbarui',
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
      title: 'Informasi Slot Waktu',
      icon: Icons.access_time_rounded,
      children: [
        if (timeSlot != null) ...[
          _buildInfoRow(
            context,
            'Tanggal',
            TimeZoneUtil.formatISOToIndonesiaTime(
              timeSlot.startTime.toIso8601String(),
              format: 'EEEE, d MMMM yyyy',
            ),
          ),
          _buildInfoRow(
            context,
            'Mulai',
            TimeZoneUtil.formatISOToIndonesiaTime(
              timeSlot.startTime.toIso8601String(),
              format: 'HH:mm',
            ),
          ),
          _buildInfoRow(
            context,
            'Selesai',
            TimeZoneUtil.formatISOToIndonesiaTime(
              timeSlot.endTime.toIso8601String(),
              format: 'HH:mm',
            ),
          ),
          _buildInfoRow(
            context,
            'Durasi',
            '${timeSlot.endTime.difference(timeSlot.startTime).inMinutes} menit',
          ),
        ] else
          _buildInfoRow(context, 'ID Slot Waktu', session.timeSlotId),
      ],
    );
  }

  Widget _buildStaffInfoCard(BuildContext context, Session session) {
    final staff = session.staff;

    return _buildInfoCard(
      context: context,
      title: 'Informasi Terapis',
      icon: Icons.person_outline_rounded,
      children: [
        if (staff != null) ...[
          _buildInfoRow(context, 'Nama', staff.name),
          _buildInfoRow(context, 'Email', staff.email),
          _buildInfoRow(context, 'Telepon', staff.phoneNumber),
          _buildInfoRow(
            context,
            'Status',
            staff.isActive ? 'Aktif' : 'Nonaktif',
          ),
        ] else
          _buildInfoRow(context, 'ID Terapis', session.staffId),
      ],
    );
  }

  Widget _buildEmptyReservationState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.70),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 84,
            width: 84,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.70),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.event_note_outlined,
              size: 44,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          SizedBox(height: spacing.md),
          Text(
            'Belum Ada Reservasi',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.sm),
          Text(
            'Sesi ini belum dipesan oleh pelanggan.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
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
      title: 'Informasi Reservasi',
      icon:
          reservation != null
              ? Icons.event_note_rounded
              : Icons.event_note_outlined,
      children: [
        if (reservation != null) ...[
          _buildInfoRow(context, 'ID Reservasi', reservation.id),
          _buildInfoRow(
            context,
            'Jenis',
            _getReservationTypeText(reservation.reservationType),
          ),
          _buildInfoRow(context, 'Nama Bayi', reservation.babyName),
          _buildInfoRow(context, 'Usia Bayi', '${reservation.babyAge} bulan'),
          if (reservation.parentNames != null &&
              reservation.parentNames!.isNotEmpty)
            _buildInfoRow(context, 'Nama Orang Tua', reservation.parentNames!),
          _buildInfoRow(
            context,
            'Status',
            _getReservationStatusText(reservation.status),
          ),
          _buildInfoRow(
            context,
            'Total',
            'Rp ${reservation.totalPrice.toStringAsFixed(0)}',
          ),
          if (reservation.notes != null && reservation.notes!.isNotEmpty)
            _buildInfoRow(context, 'Catatan', reservation.notes!),
          _buildInfoRow(
            context,
            'Direservasi',
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Obx(() {
      final currentSession = sessionController.currentSession.value ?? session;
      final hasReservation = currentSession.reservation != null;
      final isBooked = currentSession.isBooked;

      return SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.all(spacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.70),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hasReservation && !isBooked)
                AppButton(
                  text: 'Tambah Reservasi Manual',
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
                        text: 'Lihat',
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
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: AppButton(
                        text: 'Ubah',
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
              if (hasReservation) SizedBox(height: spacing.sm),
              AppButton(
                text: isBooked ? 'Tandai Tersedia' : 'Tandai Terpesan',
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
        ),
      );
    });
  }

  void _showCustomSnackbar(
    String title,
    String message, {
    bool isError = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      margin: EdgeInsets.all(
        (theme.extension<AppSpacing>() ?? const AppSpacing()).md,
      ),
      borderRadius: AppRadii.lg,
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
        _showCustomSnackbar('Berhasil', 'Reservasi manual berhasil dibuat.');
      }
    });
  }

  void _showToggleBookingConfirmation(
    BuildContext context,
    Session session,
    bool newBookingStatus,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            newBookingStatus
                ? Icons.event_busy_outlined
                : Icons.event_available_outlined,
            color: newBookingStatus ? colorScheme.error : colorScheme.primary,
          ),
          title: Text(
            newBookingStatus ? 'Tandai Terpesan?' : 'Tandai Tersedia?',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          content: Text(
            newBookingStatus
                ? 'Sesi ini akan ditandai sebagai terpesan.'
                : 'Sesi ini akan ditandai kembali sebagai tersedia.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            AppButton(
              text: 'Batal',
              onPressed: () => Get.back(),
              type: AppButtonType.text,
              size: AppButtonSize.small,
            ),
            AppButton(
              text: newBookingStatus ? 'Ya, Tandai' : 'Ya, Ubah',
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
          title: Text(
            'Hapus Sesi?',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Tindakan ini bersifat permanen dan tidak bisa dibatalkan. Yakin ingin menghapus sesi ini?',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            AppButton(
              text: 'Batal',
              onPressed: () => Get.back(),
              type: AppButtonType.text,
              size: AppButtonSize.small,
            ),
            AppButton(
              text: 'Hapus',
              type: AppButtonType.text,
              size: AppButtonSize.small,
              onPressed: () {
                Get.back();
                sessionController.deleteSession(session.id).then((success) {
                  if (success) {
                    Get.back();
                    _showCustomSnackbar('Berhasil', 'Sesi berhasil dihapus.');
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
      type == ReservationType.ONLINE ? 'Reservasi Online' : 'Reservasi Manual';

  String _getReservationStatusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.PENDING:
      case ReservationStatus.PENDING_PAYMENT:
        return 'Menunggu';
      case ReservationStatus.CONFIRMED:
        return 'Dikonfirmasi';
      case ReservationStatus.IN_PROGRESS:
        return 'Berlangsung';
      case ReservationStatus.COMPLETED:
        return 'Selesai';
      case ReservationStatus.CANCELLED:
        return 'Dibatalkan';
      case ReservationStatus.EXPIRED:
        return 'Kedaluwarsa';
    }
  }
}
