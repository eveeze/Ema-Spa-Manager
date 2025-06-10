import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
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

    // Selalu fetch data baru saat halaman dibuka untuk memastikan data paling update
    controller.fetchReservationById(reservationId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? reservationId = Get.parameters['id'];

    // Menggunakan addPostFrameCallback untuk memanggil setelah frame pertama selesai build
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
        // Gunakan isLoading dari controller. Jika true dan belum ada reservasi, tampilkan loading.
        final isLoading = controller.isLoading.value && reservation == null;
        final errorMessage = controller.errorMessage.value;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage.isNotEmpty && reservation == null) {
          return Center(
            child: Text(
              'Error: $errorMessage',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          );
        }

        if (reservation == null) {
          // Kondisi fallback jika data belum siap
          return const Center(child: Text('Loading reservation...'));
        }

        // Kirim reservasi dan payment ke form
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

  // Untuk mengganti bukti bayar yang sudah ada
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

  // Untuk memilih dan menyiapkan bukti bayar baru (sebelum di-upload)
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

  // Untuk meng-upload bukti bayar yang baru dipilih
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

    // ======================================================================
    // ===== LOGIKA KONDISIONAL BARU UNTUK PEMBAYARAN =======================
    // ======================================================================

    final payment = widget.payment;

    // Kondisi 1: Ini adalah reservasi MANUAL yang statusnya PENDING dan metode bayarnya CASH.
    // Aksi yang paling tepat adalah menandainya sebagai lunas.
    final bool isManualPendingCash =
        widget.reservation.reservationType == ReservationType.MANUAL &&
        widget.reservation.status == ReservationStatus.PENDING &&
        payment?.paymentMethod == 'CASH';

    // Kondisi 2: Ini adalah reservasi MANUAL, status PENDING, dan metode bayarnya BUKAN CASH (misal, transfer).
    // Owner perlu mengelola bukti bayar.
    final bool isManualPendingNonCash =
        widget.reservation.reservationType == ReservationType.MANUAL &&
        widget.reservation.status == ReservationStatus.PENDING &&
        payment != null &&
        payment.paymentMethod != 'CASH';

    // Pengecekan apakah sudah ada URL bukti bayar di database.
    final bool hasPaymentProof =
        payment?.paymentProof != null && payment!.paymentProof!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(context, 'Reservation Status'),
            const SizedBox(height: 16),
            if (availableTransitions.isNotEmpty)
              DropdownButtonFormField<ReservationStatus>(
                value: _currentStatus,
                decoration: const InputDecoration(
                  labelText: 'Update Status',
                  border: OutlineInputBorder(),
                ),
                items:
                    dropdownStatuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          _reservationController.getStatusDisplayName(
                            status.name,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (newStatus) {
                  if (newStatus != null && newStatus != _currentStatus) {
                    Get.defaultDialog(
                      title: "Confirm Status Change",
                      middleText:
                          "Change status from ${_reservationController.getStatusDisplayName(_currentStatus.name)} to ${_reservationController.getStatusDisplayName(newStatus.name)}?",
                      textConfirm: "Yes, Change",
                      textCancel: "Cancel",
                      onConfirm: () {
                        Get.back();
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
              _buildReadOnlyField(
                'Status',
                _reservationController.getStatusDisplayName(
                  widget.reservation.status.name,
                ),
              ),
            const SizedBox(height: 24),

            // ==========================================================
            // ===== BLOK TAMPILAN BERDASARKAN LOGIKA BARU ==============
            // ==========================================================

            // --- TAMPILKAN TOMBOL "MARK AS PAID" UNTUK PEMBAYARAN CASH ---
            if (isManualPendingCash) ...[
              _buildSectionHeader(context, 'Payment Action (Cash)'),
              const SizedBox(height: 10),
              Text(
                'Reservasi ini menunggu pembayaran tunai. Tandai sebagai lunas jika pembayaran telah diterima.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Obx(
                () => AppButton(
                  text:
                      _reservationController.isUpdatingManualPayment.value
                          ? 'Processing...'
                          : 'Tandai Sudah Bayar (Cash)',
                  onPressed:
                      _reservationController.isUpdatingManualPayment.value
                          ? null
                          : () {
                            Get.defaultDialog(
                              title: "Konfirmasi Pembayaran",
                              middleText:
                                  "Anda yakin ingin menandai reservasi ini LUNAS?",
                              textConfirm: "Ya, Lunas",
                              textCancel: "Batal",
                              onConfirm: () {
                                Get.back();
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
              const SizedBox(height: 24),
            ],

            // --- TAMPILKAN LOGIKA UPLOAD/VERIFIKASI UNTUK NON-CASH ---
            if (isManualPendingNonCash) ...[
              _buildSectionHeader(context, 'Payment Verification (Non-Cash)'),
              const SizedBox(height: 10),

              // JIKA BUKTI SUDAH ADA: tampilkan bukti dan tombol verifikasi
              if (hasPaymentProof) ...[
                Text(
                  'Bukti pembayaran telah di-upload. Silakan lakukan verifikasi.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: payment.paymentProof!,
                    placeholder:
                        (context, url) => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          padding: const EdgeInsets.all(16),
                          child: const Icon(Icons.error),
                        ),
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Ganti Bukti Pembayaran',
                  onPressed: _pickAndUpdatePaymentProof,
                  icon: Icons.edit,
                  type: AppButtonType.secondary,
                  isLoading: _reservationController.isPaymentUploading.value,
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Verifikasi',
                          onPressed:
                              _reservationController.isStatusUpdating.value
                                  ? null
                                  : () => _reservationController
                                      .verifyManualPayment(payment.id, true),
                          icon: Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton(
                          text: 'Tolak',
                          onPressed:
                              _reservationController.isStatusUpdating.value
                                  ? null
                                  : () => _reservationController
                                      .verifyManualPayment(payment.id, false),
                          icon: Icons.cancel,
                          type: AppButtonType.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
              // JIKA BUKTI BELUM ADA: tampilkan opsi untuk upload
              else ...[
                Text(
                  'Reservasi ini menunggu bukti pembayaran. Anda dapat meng-uploadnya atas nama pelanggan.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (_paymentProofFile == null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Pilih File Bukti Bayar'),
                    onPressed: _pickAndPrepareNewPaymentProof,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.image, color: Colors.green),
                    title: Text(_paymentProofFile!.path.split('/').last),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _paymentProofFile = null),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => AppButton(
                      text:
                          _reservationController.isPaymentUploading.value
                              ? 'Mengupload...'
                              : 'Upload Bukti Bayar',
                      onPressed:
                          _reservationController.isPaymentUploading.value
                              ? null
                              : _uploadNewPaymentProof,
                      icon: Icons.cloud_upload,
                      isLoading:
                          _reservationController.isPaymentUploading.value,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
            ],

            // ========================================================
            // ===== SISA FORM (TIDAK BERUBAH) ========================
            // ========================================================
            _buildSectionHeader(context, 'Customer & Baby Details'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: 'Customer Name'),
              validator:
                  (value) =>
                      value!.isEmpty ? 'Customer name cannot be empty' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _babyNameController,
              decoration: const InputDecoration(labelText: 'Baby Name'),
              validator:
                  (value) =>
                      value!.isEmpty ? 'Baby name cannot be empty' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _babyAgeController,
              decoration: const InputDecoration(labelText: 'Baby Age (months)'),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _parentNamesController,
              decoration: const InputDecoration(
                labelText: 'Parent Names (Optional)',
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Session & Service Details'),
            const SizedBox(height: 16),
            _buildReadOnlyField(
              'Service',
              widget.reservation.serviceName ?? 'N/A',
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField('Staff', widget.reservation.staffName ?? 'N/A'),
            const SizedBox(height: 16),
            if (sessionDate != null)
              _buildReadOnlyField(
                'Date',
                TimeZoneUtil.formatDateTimeToIndonesiaDayDate(sessionDate),
              ),
            const SizedBox(height: 16),
            _buildReadOnlyField(
              'Time',
              widget.reservation.sessionTime ?? 'N/A',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Additional Notes'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 12.0,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
