// lib/features/reservation/views/reservation_edit_view.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart'; // ✅ AppSpacing & AppRadii
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/data/models/payment.dart';
import 'package:emababyspa/data/models/reservation.dart';
import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ReservationEditView extends GetView<ReservationController> {
  const ReservationEditView({super.key});

  void _loadDataIfNeeded(String? reservationId, BuildContext context) {
    if (reservationId == null || reservationId.isEmpty) {
      Get.snackbar(
        'Error',
        'Reservation ID is missing.',
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        colorText: Theme.of(context).colorScheme.onErrorContainer,
      );
      if (Get.previousRoute.isNotEmpty) Get.back();
      return;
    }

    controller.fetchReservationById(reservationId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? reservationId = Get.parameters['id'];

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadDataIfNeeded(reservationId, context),
    );

    return MainLayout(
      parentRoute: AppRoutes.schedule,
      showBottomNavigation: true,
      showAppBar: true,
      appBarTitle: 'Edit Reservation',
      child: Obx(() {
        final reservation = controller.selectedReservation.value;
        final payment = controller.selectedPaymentDetails.value;
        final isLoading = controller.isLoading.value && reservation == null;
        final errorMessage = controller.errorMessage.value;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage.isNotEmpty && reservation == null) {
          return Center(
            child: Text(
              'Error: $errorMessage',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }

        if (reservation == null) {
          return const Center(child: Text('Loading reservation...'));
        }

        return _ReservationEditForm(reservation: reservation, payment: payment);
      }),
    );
  }
}

class _ReservationEditForm extends StatefulWidget {
  final Reservation reservation;
  final Payment? payment;

  const _ReservationEditForm({required this.reservation, this.payment});

  @override
  _ReservationEditFormState createState() => _ReservationEditFormState();
}

class _ReservationEditFormState extends State<_ReservationEditForm> {
  final _formKey = GlobalKey<FormState>();
  final ReservationController _reservationController = Get.find();

  late TextEditingController _customerNameController;
  late TextEditingController _babyNameController;
  late TextEditingController _babyAgeController;
  late TextEditingController _parentNamesController;
  late TextEditingController _notesController;
  late ReservationStatus _currentStatus;

  File? _paymentProofFile;

  @override
  void initState() {
    super.initState();
    _initializeControllers(widget.reservation);
  }

  @override
  void didUpdateWidget(covariant _ReservationEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reservation != oldWidget.reservation) {
      _initializeControllers(widget.reservation);
    }
  }

  void _initializeControllers(Reservation reservation) {
    _customerNameController = TextEditingController(
      text: reservation.customerName ?? '',
    );
    _babyNameController = TextEditingController(text: reservation.babyName);
    _babyAgeController = TextEditingController(
      text: reservation.babyAge.toString(),
    );
    _parentNamesController = TextEditingController(
      text: reservation.parentNames ?? '',
    );
    _notesController = TextEditingController(text: reservation.notes ?? '');
    _currentStatus = reservation.status;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _babyNameController.dispose();
    _babyAgeController.dispose();
    _parentNamesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final int? babyAge = int.tryParse(_babyAgeController.text);
      if (babyAge == null) {
        Get.snackbar('Validation Error', 'Please enter a valid baby age.');
        return;
      }
      _reservationController.updateReservationDetails(
        id: widget.reservation.id,
        customerName: _customerNameController.text,
        babyName: _babyNameController.text,
        babyAge: babyAge,
        parentNames: _parentNamesController.text,
        notes: _notesController.text,
      );
    }
  }

  Future<void> _pickAndUpdatePaymentProof() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      _reservationController.updateExistingPaymentProof(
        widget.reservation.id,
        File(pickedFile.path),
      );
    }
  }

  Future<void> _pickAndPrepareNewPaymentProof() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _paymentProofFile = File(pickedFile.path);
      });
    }
  }

  void _uploadNewPaymentProof() {
    if (_paymentProofFile != null) {
      _reservationController.uploadManualPaymentProof(
        widget.reservation.id,
        _paymentProofFile!,
      );
    } else {
      Get.snackbar('Error', 'Please select a file to upload.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    final sessionDate = widget.reservation.sessionDate;

    final availableTransitions = _reservationController
        .getAvailableStatusTransitions(widget.reservation.status.name);

    final Set<ReservationStatus> dropdownStatuses = {
      _currentStatus,
      ...availableTransitions.map(
        (statusString) =>
            ReservationStatus.values.firstWhere((e) => e.name == statusString),
      ),
    };

    final payment = widget.payment;

    final bool isManualPendingCash =
        widget.reservation.reservationType == ReservationType.MANUAL &&
        widget.reservation.status == ReservationStatus.PENDING &&
        payment?.paymentMethod == 'CASH';

    final bool isManualPendingNonCash =
        widget.reservation.reservationType == ReservationType.MANUAL &&
        widget.reservation.status == ReservationStatus.PENDING &&
        payment != null &&
        payment.paymentMethod != 'CASH';

    final bool hasPaymentProof =
        payment?.paymentProof != null && payment!.paymentProof!.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.all(sp.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopIntro(context, widget.reservation),
            SizedBox(height: sp.lg),

            // =========================
            // STATUS SECTION (CARD)
            // =========================
            _buildSectionCard(
              context: context,
              title: 'Status Reservasi',
              icon: Icons.swap_horiz_rounded,
              subtitle:
                  availableTransitions.isNotEmpty
                      ? 'Ubah status reservasi sesuai progres layanan.'
                      : 'Status tidak dapat diubah saat ini.',
              child: Column(
                children: [
                  if (availableTransitions.isNotEmpty)
                    DropdownButtonFormField<ReservationStatus>(
                      value: _currentStatus,
                      decoration: InputDecoration(
                        labelText: 'Update Status',
                        prefixIcon: Icon(
                          Icons.timeline_rounded,
                          color: cs.primary,
                        ),
                      ),
                      items:
                          dropdownStatuses
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    _reservationController.getStatusDisplayName(
                                      status.name,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (newStatus) {
                        if (newStatus != null && newStatus != _currentStatus) {
                          _showConfirmDialog(
                            context: context,
                            title: 'Konfirmasi',
                            message:
                                'Ubah status dari ${_reservationController.getStatusDisplayName(_currentStatus.name)} '
                                'ke ${_reservationController.getStatusDisplayName(newStatus.name)}?',
                            confirmText: 'Ya, Ubah',
                            cancelText: 'Batal',
                            icon: Icons.swap_horiz_rounded,
                            onConfirm: () {
                              _reservationController.updateReservationStatus(
                                widget.reservation.id,
                                newStatus.name,
                              );
                            },
                          );
                        }
                      },
                    )
                  else
                    _readOnlyField(
                      context,
                      'Status',
                      _reservationController.getStatusDisplayName(
                        widget.reservation.status.name,
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: sp.lg),

            // =========================
            // PAYMENT SECTION (CONDITIONAL)
            // =========================
            if (isManualPendingCash)
              _buildSectionCard(
                context: context,
                title: 'Pembayaran (Cash)',
                icon: Icons.payments_rounded,
                subtitle:
                    'Reservasi ini menunggu pembayaran tunai. Tandai lunas setelah pembayaran diterima.',
                child: Obx(
                  () => AppButton(
                    text:
                        _reservationController.isUpdatingManualPayment.value
                            ? 'Processing...'
                            : 'Tandai Sudah Bayar (Cash)',
                    onPressed:
                        _reservationController.isUpdatingManualPayment.value
                            ? null
                            : () {
                              _showConfirmDialog(
                                context: context,
                                title: 'Konfirmasi Pembayaran',
                                message:
                                    'Anda yakin ingin menandai reservasi ini LUNAS?',
                                confirmText: 'Ya, Lunas',
                                cancelText: 'Batal',
                                icon: Icons.check_circle_outline_rounded,
                                onConfirm: () {
                                  _reservationController
                                      .updateManualReservationPaymentStatus(
                                        widget.reservation.id,
                                        paymentMethod: 'CASH',
                                      );
                                },
                              );
                            },
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ),

            if (isManualPendingCash) SizedBox(height: sp.lg),

            if (isManualPendingNonCash)
              _buildSectionCard(
                context: context,
                title: 'Verifikasi Pembayaran',
                icon: Icons.verified_user_rounded,
                subtitle:
                    hasPaymentProof
                        ? 'Bukti pembayaran tersedia. Verifikasi untuk melanjutkan.'
                        : 'Reservasi menunggu bukti pembayaran. Anda dapat mengunggahnya atas nama customer.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasPaymentProof) ...[
                      SizedBox(
                        height: sp.xxl * 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          child: CachedNetworkImage(
                            imageUrl: payment.paymentProof!,
                            fit: BoxFit.cover,
                            placeholder:
                                (_, __) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            errorWidget:
                                (_, __, ___) => Container(
                                  color: cs.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.broken_image,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      SizedBox(height: sp.md),
                      AppButton(
                        text: 'Ganti Bukti Pembayaran',
                        onPressed: _pickAndUpdatePaymentProof,
                        icon: Icons.edit,
                        type: AppButtonType.secondary,
                        isLoading:
                            _reservationController.isPaymentUploading.value,
                      ),
                      SizedBox(height: sp.sm),
                      Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Verifikasi',
                                onPressed:
                                    _reservationController
                                            .isStatusUpdating
                                            .value
                                        ? null
                                        : () {
                                          _showConfirmDialog(
                                            context: context,
                                            title: 'Verifikasi Pembayaran',
                                            message:
                                                'Setujui pembayaran ini dan tandai sebagai valid?',
                                            confirmText: 'Ya, Verifikasi',
                                            cancelText: 'Batal',
                                            icon: Icons.check_circle_rounded,
                                            onConfirm: () {
                                              _reservationController
                                                  .verifyManualPayment(
                                                    payment.id,
                                                    true,
                                                  );
                                            },
                                          );
                                        },
                                icon: Icons.check_circle,
                              ),
                            ),
                            SizedBox(width: sp.sm),
                            Expanded(
                              child: AppButton(
                                text: 'Tolak',
                                onPressed:
                                    _reservationController
                                            .isStatusUpdating
                                            .value
                                        ? null
                                        : () {
                                          _showConfirmDialog(
                                            context: context,
                                            title: 'Tolak Pembayaran',
                                            message:
                                                'Tolak bukti pembayaran ini? Customer perlu mengunggah ulang.',
                                            confirmText: 'Ya, Tolak',
                                            cancelText: 'Batal',
                                            icon: Icons.cancel_rounded,
                                            onConfirm: () {
                                              _reservationController
                                                  .verifyManualPayment(
                                                    payment.id,
                                                    false,
                                                  );
                                            },
                                          );
                                        },
                                icon: Icons.cancel,
                                type: AppButtonType.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      if (_paymentProofFile == null)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Pilih File Bukti Bayar'),
                          onPressed: _pickAndPrepareNewPaymentProof,
                        )
                      else ...[
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            side: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.75),
                            ),
                          ),
                          tileColor: cs.surfaceContainerHighest.withValues(
                            alpha: 0.55,
                          ),
                          leading: Icon(Icons.image, color: cs.primary),
                          title: Text(
                            _paymentProofFile!.path.split('/').last,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed:
                                () => setState(() => _paymentProofFile = null),
                          ),
                        ),
                        SizedBox(height: sp.md),
                        Obx(
                          () => AppButton(
                            text:
                                _reservationController.isPaymentUploading.value
                                    ? 'Mengupload...'
                                    : 'Upload Bukti Bayar',
                            onPressed:
                                _reservationController.isPaymentUploading.value
                                    ? null
                                    : () {
                                      _showConfirmDialog(
                                        context: context,
                                        title: 'Upload Bukti Pembayaran',
                                        message:
                                            'Upload bukti pembayaran yang dipilih untuk reservasi ini?',
                                        confirmText: 'Ya, Upload',
                                        cancelText: 'Batal',
                                        icon: Icons.cloud_upload_rounded,
                                        onConfirm: _uploadNewPaymentProof,
                                      );
                                    },
                            icon: Icons.cloud_upload,
                            isLoading:
                                _reservationController.isPaymentUploading.value,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

            if (isManualPendingNonCash) SizedBox(height: sp.lg),

            // =========================
            // CUSTOMER & BABY (CARD)
            // =========================
            _buildSectionCard(
              context: context,
              title: 'Customer & Bayi',
              icon: Icons.child_care_rounded,
              subtitle: 'Perbarui data customer dan detail bayi.',
              child: Column(
                children: [
                  TextFormField(
                    controller: _customerNameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Customer',
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: cs.primary,
                      ),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Customer name cannot be empty'
                                : null,
                  ),
                  SizedBox(height: sp.md),
                  TextFormField(
                    controller: _babyNameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Bayi',
                      prefixIcon: Icon(
                        Icons.child_care_outlined,
                        color: cs.primary,
                      ),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Baby name cannot be empty'
                                : null,
                  ),
                  SizedBox(height: sp.md),
                  TextFormField(
                    controller: _babyAgeController,
                    decoration: InputDecoration(
                      labelText: 'Usia Bayi (bulan)',
                      prefixIcon: Icon(Icons.cake_outlined, color: cs.primary),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Baby age cannot be empty';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: sp.md),
                  TextFormField(
                    controller: _parentNamesController,
                    decoration: InputDecoration(
                      labelText: 'Nama Orang Tua (Opsional)',
                      prefixIcon: Icon(
                        Icons.family_restroom_outlined,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: sp.lg),

            // =========================
            // SESSION & SERVICE (CARD)
            // =========================
            _buildSectionCard(
              context: context,
              title: 'Sesi & Layanan',
              icon: Icons.event_note_rounded,
              subtitle: 'Informasi sesi tidak dapat diubah dari halaman ini.',
              child: Column(
                children: [
                  _readOnlyField(
                    context,
                    'Layanan',
                    widget.reservation.serviceName ?? 'N/A',
                  ),
                  SizedBox(height: sp.sm),
                  _readOnlyField(
                    context,
                    'Terapis',
                    widget.reservation.staffName ?? 'N/A',
                  ),
                  SizedBox(height: sp.sm),
                  if (sessionDate != null)
                    _readOnlyField(
                      context,
                      'Tanggal',
                      TimeZoneUtil.formatDateTimeToIndonesiaDayDate(
                        sessionDate,
                      ),
                    ),
                  SizedBox(height: sp.sm),
                  _readOnlyField(
                    context,
                    'Waktu',
                    widget.reservation.sessionTime ?? 'N/A',
                  ),
                ],
              ),
            ),

            SizedBox(height: sp.lg),

            // =========================
            // NOTES (CARD)
            // =========================
            _buildSectionCard(
              context: context,
              title: 'Catatan',
              icon: Icons.notes_rounded,
              subtitle:
                  'Opsional. Tambahkan informasi penting atau permintaan.',
              child: TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  prefixIcon: Icon(Icons.note_outlined, color: cs.primary),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            SizedBox(height: sp.xl),

            Obx(
              () => AppButton(
                text:
                    _reservationController.isFormSubmitting.value
                        ? 'Saving...'
                        : 'Save Changes',
                onPressed:
                    _reservationController.isFormSubmitting.value
                        ? null
                        : _submitForm,
                icon: Icons.save_alt_outlined,
              ),
            ),
            SizedBox(height: sp.xxl),
          ],
        ),
      ),
    );
  }

  // =========================
  // UI HELPERS (CONSISTENT)
  // =========================

  Widget _buildTopIntro(BuildContext context, Reservation reservation) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      padding: EdgeInsets.all(sp.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.75)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: sp.xl + sp.xs,
            width: sp.xl + sp.xs,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.75),
              ),
            ),
            child: Icon(Icons.edit_note_rounded, color: cs.onSurfaceVariant),
          ),
          SizedBox(width: sp.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Reservasi',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: sp.xs),
                Text(
                  'Perbarui data customer, bayi, catatan, dan (jika manual) kelola pembayaran & status.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
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

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.75)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(sp.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: sp.xl,
                  width: sp.xl,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.70),
                    ),
                  ),
                  child: Icon(icon, size: 20, color: cs.onSurfaceVariant),
                ),
                SizedBox(width: sp.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: sp.xxs),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: sp.md),
            child,
          ],
        ),
      ),
    );
  }

  Widget _readOnlyField(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: sp.md, vertical: sp.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: sp.xs),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    String cancelText = 'Batal',
    IconData icon = Icons.help_outline_rounded,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.75)),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.75),
                ),
              ),
              child: Icon(icon, color: cs.onSurfaceVariant, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: cs.onSurface,
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
