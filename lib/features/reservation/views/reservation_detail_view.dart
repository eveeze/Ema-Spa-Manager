// lib/features/reservation/views/reservation_detail_view.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/data/models/payment.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReservationDetailView extends GetView<ReservationController> {
  const ReservationDetailView({super.key});

  Future<void> _loadReservationDetails(String reservationId) async {
    controller.clearSelectedReservation();
    await controller.fetchReservationById(reservationId);
  }

  @override
  Widget build(BuildContext context) {
    final reservationId = Get.parameters['id'] ?? '';
    Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (reservationId.isNotEmpty &&
          controller.selectedReservation.value?.id != reservationId) {
        _loadReservationDetails(reservationId);
      }
    });

    return MainLayout(
      parentRoute: AppRoutes.schedule,
      showBottomNavigation: true,
      showAppBar: true,
      appBarTitle: 'Detail Reservasi',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed:
              reservationId.isEmpty
                  ? null
                  : () => _loadReservationDetails(reservationId),
          tooltip: 'Muat Ulang',
        ),
      ],
      child: _buildBody(context, reservationId),
    );
  }

  Widget _buildBody(BuildContext context, String reservationId) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Obx(() {
      if (controller.isLoading.value &&
          controller.selectedReservation.value?.id != reservationId) {
        return const Center(child: CircularProgressIndicator());
      }

      final reservation = controller.selectedReservation.value;
      if (reservation == null) {
        return _buildErrorState(context, reservationId);
      }

      return RefreshIndicator(
        onRefresh: () => _loadReservationDetails(reservationId),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(spacing.lg),
          children: [
            _buildTopSummary(context, reservation),
            SizedBox(height: spacing.lg),
            _buildSectionCard(
              context: context,
              title: 'Sesi & Layanan',
              icon: Icons.event_note_rounded,
              children: [
                _kvRow(
                  context,
                  label: 'ID Reservasi',
                  value: reservation.id,
                  isEmphasis: true,
                ),
                _divider(context),
                if (reservation.sessionDate != null) ...[
                  _kvRow(
                    context,
                    label: 'Tanggal',
                    value: TimeZoneUtil.formatDateTimeToIndonesiaDayDate(
                      reservation.sessionDate!,
                    ),
                  ),
                  _divider(context),
                ],
                if (reservation.sessionTime != null) ...[
                  _kvRow(
                    context,
                    label: 'Waktu',
                    value: reservation.sessionTime!,
                  ),
                  _divider(context),
                ],
                _kvRow(
                  context,
                  label: 'Layanan',
                  value: reservation.serviceName ?? '—',
                ),
                _divider(context),
                _kvRow(
                  context,
                  label: 'Terapis',
                  value: reservation.staffName ?? '—',
                ),
                _divider(context),
                _kvRow(
                  context,
                  label: 'Tipe',
                  value:
                      reservation.reservationType == ReservationType.MANUAL
                          ? 'Manual'
                          : 'Online',
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            _buildSectionCard(
              context: context,
              title: 'Customer & Bayi',
              icon: Icons.child_care_rounded,
              children: [
                _kvRow(
                  context,
                  label: 'Customer',
                  value: reservation.customerName ?? '—',
                ),
                _divider(context),
                _kvRow(
                  context,
                  label: 'Nama Bayi',
                  value: reservation.babyName,
                  isEmphasis: true,
                ),
                _divider(context),
                _kvRow(
                  context,
                  label: 'Usia Bayi',
                  value: '${reservation.babyAge} bulan',
                ),
                if (reservation.parentNames?.isNotEmpty ?? false) ...[
                  _divider(context),
                  _kvRow(
                    context,
                    label: 'Orang Tua',
                    value: reservation.parentNames!,
                  ),
                ],
              ],
            ),
            SizedBox(height: spacing.lg),
            _buildPaymentSection(
              context,
              controller.selectedPaymentDetails.value,
            ),
            if (reservation.notes?.isNotEmpty ?? false) ...[
              SizedBox(height: spacing.lg),
              _buildSectionCard(
                context: context,
                title: 'Catatan',
                icon: Icons.notes_rounded,
                children: [
                  Text(
                    reservation.notes!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: spacing.xxl),
          ],
        ),
      );
    });
  }

  Widget _buildTopSummary(BuildContext context, Reservation reservation) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: spacing.xl + spacing.xs,
            width: spacing.xl + spacing.xs,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.75),
              ),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Ringkasan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    _buildStatusChip(context, reservation.status),
                  ],
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'Detail reservasi, sesi, dan pembayaran.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, Payment? payment) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    if (payment == null) {
      return _buildSectionCard(
        context: context,
        title: 'Pembayaran',
        icon: Icons.payment_outlined,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.70),
              ),
            ),
            child: Text(
              'Belum ada data pembayaran untuk reservasi ini.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return _buildSectionCard(
      context: context,
      title: 'Detail Pembayaran',
      icon: Icons.receipt_long_rounded,
      children: [
        _kvRow(context, label: 'ID Pembayaran', value: payment.id),
        _divider(context),
        _kvRow(context, label: 'Metode', value: payment.paymentMethod),
        _divider(context),
        _kvRow(
          context,
          label: 'Status',
          value: payment.paymentStatus.toUpperCase(),
        ),
        _divider(context),
        _kvRow(
          context,
          label: 'Jumlah',
          value: currency.format(payment.amount),
          isEmphasis: true,
        ),
        if (payment.paymentDate != null) ...[
          _divider(context),
          _kvRow(
            context,
            label: 'Tanggal',
            value: TimeZoneUtil.formatISOToLocalDateTimeFull(
              payment.paymentDate!.toIso8601String(),
            ),
          ),
        ],
        if (payment.paymentProof?.isNotEmpty ?? false) ...[
          SizedBox(height: spacing.sm),
          _buildProofTile(context, payment.paymentProof!),
        ],
      ],
    );
  }

  Widget _buildProofTile(BuildContext context, String url) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: () {
        Get.dialog(
          AlertDialog(
            content: CachedNetworkImage(
              imageUrl: url,
              placeholder:
                  (_, __) => const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) => const Text('Gagal memuat gambar'),
            ),
            actions: [
              TextButton(onPressed: Get.back, child: const Text('Tutup')),
            ],
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.70),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.image_outlined, color: colorScheme.onPrimaryContainer),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                'Lihat Bukti Pembayaran',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ReservationStatus status) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>();
    final colorScheme = theme.colorScheme;

    late Color bg;
    late Color fg;
    late IconData icon;

    switch (status) {
      case ReservationStatus.PENDING:
      case ReservationStatus.PENDING_PAYMENT:
        fg = semantic?.warning ?? colorScheme.secondary;
        bg = fg.withValues(alpha: 0.14);
        icon = Icons.schedule_rounded;
        break;
      case ReservationStatus.CONFIRMED:
        bg = colorScheme.primaryContainer;
        fg = colorScheme.onPrimaryContainer;
        icon = Icons.verified_rounded;
        break;
      case ReservationStatus.IN_PROGRESS:
        bg = colorScheme.tertiaryContainer;
        fg = colorScheme.onTertiaryContainer;
        icon = Icons.timelapse_rounded;
        break;
      case ReservationStatus.COMPLETED:
        fg = semantic?.success ?? colorScheme.tertiary;
        bg = fg.withValues(alpha: 0.14);
        icon = Icons.check_circle_rounded;
        break;
      case ReservationStatus.CANCELLED:
      case ReservationStatus.EXPIRED:
        bg = colorScheme.errorContainer;
        fg = colorScheme.onErrorContainer;
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (theme.extension<AppSpacing>() ?? const AppSpacing()).md,
        vertical: (theme.extension<AppSpacing>() ?? const AppSpacing()).xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          SizedBox(
            width: (theme.extension<AppSpacing>() ?? const AppSpacing()).xs,
          ),
          Text(
            controller.getStatusDisplayName(status.name),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
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
                  child: Icon(
                    icon,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _kvRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isEmphasis = false,
  }) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final colorScheme = theme.colorScheme;

    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    final valueStyle = (isEmphasis
            ? theme.textTheme.titleMedium
            : theme.textTheme.bodyMedium)
        ?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: isEmphasis ? FontWeight.w900 : FontWeight.w700,
        );

    final safeValue = value.isEmpty ? '—' : value;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: spacing.xxl + spacing.md),
            child: Text(label, style: labelStyle),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SelectableText(
                safeValue,
                style: valueStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 0,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.75),
    );
  }

  Widget _buildErrorState(BuildContext context, String reservationId) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colorScheme.error,
              size: 48,
            ),
            SizedBox(height: spacing.md),
            Text(
              'Gagal memuat data reservasi',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            Text(
              'Coba muat ulang untuk melihat detail terbaru.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.lg),
            AppButton(
              text: 'Coba Lagi',
              icon: Icons.refresh,
              onPressed:
                  reservationId.isEmpty
                      ? null
                      : () => _loadReservationDetails(reservationId),
            ),
          ],
        ),
      ),
    );
  }
}
