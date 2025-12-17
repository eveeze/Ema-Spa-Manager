// lib/features/reservation/views/reservation_form_view.dart
import 'dart:io';

import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/data/models/service.dart';
import 'package:emababyspa/data/models/session.dart';
import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ReservationFormView extends StatefulWidget {
  const ReservationFormView({super.key});

  @override
  State<ReservationFormView> createState() => _ReservationFormViewState();
}

class _ReservationFormViewState extends State<ReservationFormView> {
  final reservationController = Get.find<ReservationController>();
  final serviceController = Get.find<ServiceController>();
  final themeController = Get.find<ThemeController>();

  final _formKey = GlobalKey<FormState>();

  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerInstagramController = TextEditingController();
  final _babyNameController = TextEditingController();
  final _babyAgeController = TextEditingController();
  final _parentNamesController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentNotesController = TextEditingController();

  Session? selectedSession;
  Service? selectedService;
  String? selectedPriceTierId;
  String selectedPaymentMethod = 'CASH';
  bool isPaid = false;
  File? paymentProofFile;

  final List<String> paymentMethods = [
    'CASH',
    'BANK_TRANSFER',
    'QRIS',
    'E_WALLET',
    "CREDIT_CARD",
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      selectedSession = args['session'];
      if (selectedSession != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadServiceData();
        });
      }
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _customerInstagramController.dispose();
    _babyNameController.dispose();
    _babyAgeController.dispose();
    _parentNamesController.dispose();
    _notesController.dispose();
    _paymentNotesController.dispose();
    super.dispose();
  }

  void _loadServiceData() {
    serviceController.fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MainLayout(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        bottomNavigationBar: _buildBottomActions(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ✅ Stabil: warna AppBar tidak berubah saat scroll (Material 3 "scrolledUnder")
    return AppBar(
      title: const Text('Buat Reservasi Manual'),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Form(
      key: _formKey,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              spacing.lg,
              spacing.lg,
              spacing.lg,
              spacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTopIntro(context),
                SizedBox(height: spacing.lg),

                if (selectedSession != null) ...[
                  _buildSessionInfoCard(context),
                  SizedBox(height: spacing.lg),
                ],

                _buildCustomerInfoCard(context),
                SizedBox(height: spacing.lg),

                _buildBabyInfoCard(context),
                SizedBox(height: spacing.lg),

                _buildServiceSelectionCard(context),
                SizedBox(height: spacing.lg),

                _buildPaymentInfoCard(context),
                SizedBox(height: spacing.lg),

                _buildNotesCard(context),
                SizedBox(height: spacing.xxl + spacing.xl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIntro(BuildContext context) {
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
              Icons.edit_note_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Reservasi',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'Lengkapi data customer, bayi, layanan, dan pembayaran. Pastikan semua input sudah benar sebelum submit.',
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

  Widget _buildSessionInfoCard(BuildContext context) {
    final session = selectedSession!;
    return _buildSectionCard(
      context: context,
      title: 'Informasi Sesi',
      icon: Icons.event_rounded,
      subtitle: 'Ringkasan sesi yang dipakai untuk reservasi ini.',
      child: Column(
        children: [
          _buildKV(context, 'ID Sesi', session.id, emphasize: true),
          if (session.timeSlot != null) ...[
            _buildDivider(context),
            _buildKV(
              context,
              'Tanggal',
              TimeZoneUtil.formatISOToIndonesiaTime(
                session.timeSlot!.startTime.toIso8601String(),
                format: 'EEEE, d MMMM yyyy',
              ),
            ),
            _buildDivider(context),
            _buildKV(
              context,
              'Waktu',
              '${TimeZoneUtil.formatISOToIndonesiaTime(session.timeSlot!.startTime.toIso8601String(), format: 'HH:mm')} - ${TimeZoneUtil.formatISOToIndonesiaTime(session.timeSlot!.endTime.toIso8601String(), format: 'HH:mm')}',
            ),
          ],
          if (session.staff != null) ...[
            _buildDivider(context),
            _buildKV(context, 'Terapis', session.staff!.name),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return _buildSectionCard(
      context: context,
      title: 'Data Customer',
      icon: Icons.person_rounded,
      subtitle: 'Identitas customer untuk kebutuhan reservasi & komunikasi.',
      child: Column(
        children: [
          _buildTextFormField(
            context: context,
            controller: _customerNameController,
            label: 'Nama Customer',
            hint: 'Contoh: Siti Aisyah',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Nama customer wajib diisi';
              if (value.trim().length < 2) return 'Nama minimal 2 karakter';
              return null;
            },
          ),
          SizedBox(height: spacing.md),
          _buildTextFormField(
            context: context,
            controller: _customerPhoneController,
            label: 'Nomor HP',
            hint: 'Contoh: 081234567890',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Nomor HP wajib diisi';
              if (value.trim().length < 10) return 'Minimal 10 digit';
              return null;
            },
          ),
          SizedBox(height: spacing.md),
          _buildTextFormField(
            context: context,
            controller: _customerAddressController,
            label: 'Alamat (Opsional)',
            hint: 'Alamat singkat / patokan',
            icon: Icons.location_on_outlined,
            maxLines: 2,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: spacing.md),
          _buildTextFormField(
            context: context,
            controller: _customerInstagramController,
            label: 'Instagram (Opsional)',
            hint: 'username instagram',
            icon: Icons.alternate_email_rounded,
            prefixText: '@',
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  Widget _buildBabyInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();

    return _buildSectionCard(
      context: context,
      title: 'Data Bayi',
      icon: Icons.child_friendly_rounded,
      subtitle: 'Informasi bayi untuk validasi usia & kebutuhan layanan.',
      child: Column(
        children: [
          _buildTextFormField(
            context: context,
            controller: _babyNameController,
            label: 'Nama Bayi',
            hint: 'Contoh: Aira',
            icon: Icons.child_care_outlined,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Nama bayi wajib diisi';
              return null;
            },
          ),
          SizedBox(height: spacing.md),
          _buildTextFormField(
            context: context,
            controller: _babyAgeController,
            label: 'Usia Bayi (bulan)',
            hint: 'Contoh: 6',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Usia bayi wajib diisi';
              final age = int.tryParse(value.trim());
              if (age == null || age < 0 || age > 60)
                return 'Usia valid 0–60 bulan';
              return null;
            },
          ),
          SizedBox(height: spacing.md),
          _buildTextFormField(
            context: context,
            controller: _parentNamesController,
            label: 'Nama Orang Tua (Opsional)',
            hint: 'Contoh: Bunda Siti & Ayah Budi',
            icon: Icons.family_restroom_outlined,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelectionCard(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return _buildSectionCard(
      context: context,
      title: 'Pilih Layanan',
      icon: Icons.spa_rounded,
      subtitle: 'Pilih layanan lalu tentukan tier harga (jika tersedia).',
      child: Obx(() {
        final services = serviceController.services;

        if (serviceController.isLoadingServices.value) {
          return Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (services.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.75),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.spa_outlined,
                  size: 44,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: spacing.sm),
                Text(
                  'Belum ada layanan',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'Tidak ada layanan yang tersedia. Cek konfigurasi layanan terlebih dahulu.',
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<Service>(
              decoration: _inputDecoration(
                context,
                label: 'Layanan',
                hint: 'Pilih layanan',
                icon: Icons.spa_outlined,
              ),
              value: selectedService,
              isExpanded: true,
              selectedItemBuilder: (context) {
                return services.map<Widget>((s) {
                  return Text(s.name, overflow: TextOverflow.ellipsis);
                }).toList();
              },
              items:
                  services.map((service) {
                    return DropdownMenuItem<Service>(
                      value: service,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            service.name,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (service.description.isNotEmpty == true)
                            Text(
                              service.description,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedService = value;
                  selectedPriceTierId = null;
                });
              },
              validator:
                  (value) => value == null ? 'Silakan pilih layanan' : null,
            ),
            if (selectedService != null) ...[
              SizedBox(height: spacing.md),
              _buildPriceTierSelection(context),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildPriceTierSelection(BuildContext context) {
    final service = selectedService;
    if (service?.priceTiers == null || service!.priceTiers!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tier Harga',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: spacing.sm),
        ...service.priceTiers!.map((priceTier) {
          final isSelected = selectedPriceTierId == priceTier.id;

          return Container(
            margin: EdgeInsets.only(bottom: spacing.sm),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? colorScheme.primaryContainer.withValues(alpha: 0.22)
                      : colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color:
                    isSelected
                        ? colorScheme.primary.withValues(alpha: 0.55)
                        : colorScheme.outlineVariant.withValues(alpha: 0.75),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: RadioListTile<String>(
              value: priceTier.id,
              groupValue: selectedPriceTierId,
              onChanged: (value) => setState(() => selectedPriceTierId = value),
              activeColor: colorScheme.primary,
              title: Text(
                priceTier.tierName,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: spacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usia: ${priceTier.minBabyAge}-${priceTier.maxBabyAge} bulan',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      currency.format(priceTier.price),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.xs,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final semantic = theme.extension<AppSemanticColors>();

    final paidOn = semantic?.success ?? colorScheme.tertiary;
    final unpaidOn = semantic?.warning ?? colorScheme.secondary;

    return _buildSectionCard(
      context: context,
      title: 'Pembayaran',
      icon: Icons.payment_rounded,
      subtitle: 'Atur metode pembayaran dan unggah bukti (jika diperlukan).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: _inputDecoration(
              context,
              label: 'Metode Pembayaran',
              hint: 'Pilih metode',
              icon: Icons.payment_outlined,
            ),
            value: selectedPaymentMethod,
            items:
                paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
            onChanged:
                (value) =>
                    setState(() => selectedPaymentMethod = value ?? 'CASH'),
          ),
          SizedBox(height: spacing.md),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.75),
              ),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.xs,
              ),
              title: Text(
                'Pembayaran Diterima',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(
                isPaid ? 'Sudah dibayar' : 'Belum dibayar',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isPaid ? paidOn : unpaidOn,
                ),
              ),
              value: isPaid,
              onChanged: (value) => setState(() => isPaid = value),
              activeColor: colorScheme.primary,
            ),
          ),
          if (isPaid && selectedPaymentMethod != 'CASH') ...[
            SizedBox(height: spacing.md),
            _buildPaymentProofSection(context),
          ],
          SizedBox(height: spacing.md),
          _buildTextFormField(
            context: context,
            controller: _paymentNotesController,
            label: 'Catatan Pembayaran (Opsional)',
            hint: 'Contoh: transfer via BCA, atas nama ...',
            icon: Icons.note_outlined,
            maxLines: 2,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProofSection(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final semantic = theme.extension<AppSemanticColors>();

    final ok = semantic?.success ?? colorScheme.tertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bukti Pembayaran',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: spacing.sm),
        if (paymentProofFile != null) ...[
          Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              color: ok.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: ok.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: ok),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    'Bukti pembayaran sudah dipilih',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => paymentProofFile = null),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: _pickPaymentProof,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Unggah Bukti'),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return _buildSectionCard(
      context: context,
      title: 'Catatan Tambahan',
      icon: Icons.notes_rounded,
      subtitle: 'Opsional. Tambahkan permintaan khusus atau informasi penting.',
      child: _buildTextFormField(
        context: context,
        controller: _notesController,
        label: 'Catatan (Opsional)',
        hint: 'Contoh: bayi sedang pilek ringan, mohon ditangani pelan',
        icon: Icons.note_outlined,
        maxLines: 3,
        textInputAction: TextInputAction.done,
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
                      color: colorScheme.outlineVariant.withValues(alpha: 0.75),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(
                        subtitle,
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
            SizedBox(height: spacing.md),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: colorScheme.primary),
    );
  }

  Widget _buildTextFormField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? prefixText,
    TextInputAction? textInputAction,
  }) {
    final decoration = _inputDecoration(
      context,
      label: label,
      hint: hint,
      icon: icon,
    ).copyWith(prefixText: prefixText);

    return TextFormField(
      controller: controller,
      decoration: decoration,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textInputAction: textInputAction,
    );
  }

  Widget _buildKV(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final colorScheme = theme.colorScheme;

    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    final valueStyle = (emphasize
            ? theme.textTheme.titleMedium
            : theme.textTheme.bodyMedium)
        ?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: emphasize ? FontWeight.w900 : FontWeight.w800,
        );

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
                value.isEmpty ? '—' : value,
                style: valueStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 0,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.75),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? const AppSpacing();
    final colorScheme = theme.colorScheme;

    // ✅ Button berdampingan, hemat space
    return Container(
      padding: EdgeInsets.all(
        spacing.lg,
      ).copyWith(bottom: spacing.lg + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.85),
          ),
        ),
      ),
      child: Obx(() {
        final isSubmitting = reservationController.isFormSubmitting.value;

        return Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Batal',
                icon: Icons.close_rounded,
                onPressed: isSubmitting ? null : () => Get.back(),
                type: AppButtonType.secondary,
                isFullWidth: true,
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              flex: 2,
              child: AppButton(
                text: 'Buat Reservasi',
                icon: Icons.check_circle_outline_rounded,
                isLoading: isSubmitting,
                onPressed: _canSubmit() ? _submitForm : null,
                isFullWidth: true,
                type: AppButtonType.primary,
              ),
            ),
          ],
        );
      }),
    );
  }

  bool _canSubmit() {
    return selectedSession != null &&
        selectedService != null &&
        !reservationController.isFormSubmitting.value;
  }

  Future<void> _pickPaymentProof() async {
    final colorScheme = Theme.of(context).colorScheme;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() => paymentProofFile = File(pickedFile.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        backgroundColor: colorScheme.errorContainer,
        colorText: colorScheme.onErrorContainer,
      );
    }
  }

  Future<void> _submitForm() async {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedService == null) {
      Get.snackbar(
        'Error',
        'Please select a service',
        backgroundColor: colorScheme.errorContainer,
        colorText: colorScheme.onErrorContainer,
      );
      return;
    }

    await reservationController.createManualReservation(
      customerName: _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.trim(),
      customerAddress:
          _customerAddressController.text.trim().isEmpty
              ? null
              : _customerAddressController.text.trim(),
      customerInstagram:
          _customerInstagramController.text.trim().isEmpty
              ? null
              : _customerInstagramController.text.trim(),
      babyName: _babyNameController.text.trim(),
      babyAge: int.parse(_babyAgeController.text.trim()),
      parentNames:
          _parentNamesController.text.trim().isEmpty
              ? null
              : _parentNamesController.text.trim(),
      serviceId: selectedService!.id,
      sessionId: selectedSession!.id,
      priceTierId: selectedPriceTierId,
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
      paymentMethod: selectedPaymentMethod,
      isPaid: isPaid,
      paymentNotes:
          _paymentNotesController.text.trim().isEmpty
              ? null
              : _paymentNotesController.text.trim(),
      paymentProofFile: paymentProofFile,
    );
  }
}
