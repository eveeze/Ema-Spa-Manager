// lib/features/staff/views/staff_edit_view.dart
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/common/theme/semantic_colors.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/common/widgets/app_text_field.dart';
import 'package:emababyspa/common/widgets/custom_appbar.dart';
import 'package:emababyspa/data/models/staff.dart';
import 'package:emababyspa/features/staff/controllers/staff_controller.dart';
import 'package:emababyspa/utils/file_utils.dart';
import 'package:emababyspa/utils/permission_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class StaffEditView extends StatefulWidget {
  const StaffEditView({super.key});

  @override
  State<StaffEditView> createState() => _StaffEditViewState();
}

class _StaffEditViewState extends State<StaffEditView> {
  final StaffController controller = Get.find<StaffController>();
  final PermissionUtils permissionUtils = PermissionUtils();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  final Rx<Staff?> currentStaff = Rx<Staff?>(null);
  final RxBool isDataLoaded = false.obs;

  final RxBool isActiveRx = true.obs;
  final Rx<File?> profilePicture = Rx<File?>(null);

  final RxString nameError = RxString('');
  final RxString emailError = RxString('');
  final RxString phoneError = RxString('');

  String get staffId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStaffData();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // ===================== VALIDATION =====================

  bool _isValidName(String value) {
    final regex = RegExp(r'^[a-zA-Z\s]+$');
    return regex.hasMatch(value);
  }

  bool _isValidPhone(String value) {
    final regex = RegExp(r'^08\d{8,11}$'); // total 10–13 digit
    return regex.hasMatch(value);
  }

  bool validateForm(BuildContext context) {
    bool isValid = true;

    nameError.value = '';
    emailError.value = '';
    phoneError.value = '';

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      nameError.value = 'Nama wajib diisi';
      isValid = false;
    } else if (name.length < 3) {
      nameError.value = 'Nama minimal 3 karakter';
      isValid = false;
    } else if (!_isValidName(name)) {
      nameError.value = 'Nama hanya boleh huruf dan spasi';
      isValid = false;
    }

    if (email.isEmpty) {
      emailError.value = 'Email wajib diisi';
      isValid = false;
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = 'Format email tidak valid';
      isValid = false;
    }

    if (phone.isEmpty) {
      phoneError.value = 'Nomor HP wajib diisi';
      isValid = false;
    } else if (!_isValidPhone(phone)) {
      phoneError.value = 'Nomor HP harus diawali 08 dan 10–13 digit';
      isValid = false;
    }

    // file validation (optional)
    if (profilePicture.value != null) {
      if (!FileUtils.isAllowedImageType(profilePicture.value!)) {
        _showInlineSnack(
          context,
          title: 'Format Foto Tidak Didukung',
          message: 'Pilih file JPG, JPEG, atau PNG.',
          isSuccess: false,
        );
        return false;
      }
      if (!FileUtils.isFileSizeWithinLimit(profilePicture.value!, 5.0)) {
        _showInlineSnack(
          context,
          title: 'Ukuran Terlalu Besar',
          message: 'Foto profil maksimal 5MB.',
          isSuccess: false,
        );
        return false;
      }
    }

    return isValid;
  }

  // ===================== LOAD DATA =====================

  Future<void> _loadStaffData() async {
    if (staffId.isEmpty) {
      if (!mounted) return;
      _showInlineSnack(
        context,
        title: 'Gagal',
        message: 'ID staff tidak valid.',
        isSuccess: false,
      );
      Get.back();
      return;
    }

    try {
      controller.isLoading.value = true;

      Staff? staff;
      if (controller.staffList.isNotEmpty) {
        staff = controller.staffList.firstWhereOrNull((s) => s.id == staffId);
      }
      staff ??= await controller.fetchStaffById(staffId);

      if (staff == null) {
        if (!mounted) return;
        _showInlineSnack(
          context,
          title: 'Tidak Ditemukan',
          message: 'Data staff tidak ditemukan.',
          isSuccess: false,
        );
        Get.back();
        return;
      }

      currentStaff.value = staff;
      nameController.text = staff.name;
      emailController.text = staff.email;
      phoneController.text = staff.phoneNumber;
      addressController.text = staff.address ?? '';
      isActiveRx.value = staff.isActive;

      isDataLoaded.value = true;
    } catch (_) {
      if (!mounted) return;
      _showInlineSnack(
        context,
        title: 'Gagal Memuat',
        message: 'Terjadi kesalahan saat memuat data.',
        isSuccess: false,
      );
      Get.back();
    } finally {
      controller.isLoading.value = false;
    }
  }

  // ===================== SNACK =====================

  void _showInlineSnack(
    BuildContext context, {
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>();
    final tone = isSuccess ? (semantic?.success ?? cs.primary) : cs.error;

    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(14),
      borderRadius: 16,
      backgroundColor: tone.withOpacity(0.14),
      colorText: tone,
      icon: Icon(
        isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
        color: tone,
      ),
      shouldIconPulse: false,
    );
  }

  // ===================== BUILD (SAMA POLA STAFFFORMVIEW) =====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final semantic = theme.extension<AppSemanticColors>();

    Widget errorText(RxString error) {
      return Obx(() {
        if (error.value.isEmpty) return SizedBox(height: spacing.sm);
        return Padding(
          padding: EdgeInsets.only(
            top: spacing.xxs,
            left: spacing.sm,
            bottom: spacing.xxs,
          ),
          child: Text(
            error.value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      });
    }

    return MainLayout(
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: const CustomAppBar(title: 'Edit Staff', showBackButton: true),
        body: SafeArea(
          child: Obx(() {
            final loading = controller.isLoading.value && !isDataLoaded.value;

            if (loading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    semantic?.info ?? cs.primary,
                  ),
                  strokeWidth: 3,
                  strokeCap: StrokeCap.round,
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                spacing.md,
                spacing.lg,
                spacing.md,
                spacing.xxl,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final name = currentStaff.value?.name ?? 'Staff';
                      return _HeroHeader(
                        title: 'Edit Data Staff',
                        subtitle:
                            'Perbarui informasi $name agar operasional & komunikasi tetap rapi.',
                      );
                    }),
                    SizedBox(height: spacing.xl),

                    _ProfilePickerCard(
                      profilePicture: profilePicture,
                      networkUrl: currentStaff.value?.profilePicture,
                      onPick: () => _selectImage(context),
                      title: 'Foto Profil',
                      subtitle:
                          'Tap avatar untuk mengganti foto dari kamera atau galeri.',
                    ),
                    SizedBox(height: spacing.xl),

                    _SectionCard(
                      child: Column(
                        children: [
                          AppTextField(
                            controller: nameController,
                            label: 'Nama Lengkap',
                            placeholder: 'Contoh: Siti Nur Aisyah',
                            prefix: const Icon(Icons.person_outline_rounded),
                            isRequired: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp(r'[0-9]'),
                              ),
                            ],
                            onChanged: (value) {
                              final v = value.trim();
                              if (v.isNotEmpty &&
                                  v.length >= 3 &&
                                  _isValidName(v)) {
                                nameError.value = '';
                              }
                            },
                          ),
                          errorText(nameError),

                          AppTextField(
                            controller: emailController,
                            label: 'Email',
                            placeholder: 'staff@email.com',
                            prefix: const Icon(Icons.email_outlined),
                            keyboardType: TextInputType.emailAddress,
                            isRequired: true,
                            onChanged: (value) {
                              final v = value.trim();
                              if (GetUtils.isEmail(v)) emailError.value = '';
                            },
                          ),
                          errorText(emailError),

                          AppTextField(
                            controller: phoneController,
                            label: 'Nomor HP',
                            placeholder: '08xxxxxxxxxx',
                            prefix: const Icon(Icons.phone_outlined),
                            keyboardType: TextInputType.phone,
                            isRequired: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              final v = value.trim();
                              if (_isValidPhone(v)) phoneError.value = '';
                            },
                          ),
                          errorText(phoneError),

                          AppTextField(
                            controller: addressController,
                            label: 'Alamat (Opsional)',
                            placeholder: 'Tambahkan alamat jika diperlukan',
                            prefix: const Icon(Icons.location_on_outlined),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: spacing.lg),

                    _StatusCard(
                      isActiveRx: isActiveRx,
                      title: 'Status Aktif',
                      subtitleOn:
                          'Staff aktif dan dapat digunakan di operasional.',
                      subtitleOff:
                          'Staff nonaktif dan tidak digunakan sementara.',
                    ),

                    SizedBox(height: spacing.lg),

                    _InfoBanner(
                      icon: Icons.verified_user_outlined,
                      title: 'Catatan',
                      message:
                          'Pastikan email & nomor HP benar agar notifikasi berjalan lancar.',
                      toneColor: (semantic?.info ?? cs.secondary),
                    ),

                    SizedBox(height: spacing.xl),

                    Obx(
                      () => AppButton(
                        text: 'Simpan Perubahan',
                        isLoading: controller.isFormSubmitting.value,
                        type: AppButtonType.primary,
                        size: AppButtonSize.large,
                        isFullWidth: true,
                        icon: Icons.save_alt_outlined,
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (!validateForm(context)) return;

                          try {
                            await controller.updateStaff(
                              id: staffId,
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              phoneNumber: phoneController.text.trim(),
                              address:
                                  addressController.text.trim().isNotEmpty
                                      ? addressController.text.trim()
                                      : null,
                              isActive: isActiveRx.value,
                              profilePicture: profilePicture.value,
                            );

                            // ✅ INI AJA. Jangan snack di sini. Jangan delay. Jangan Get.isOverlaysOpen.
                            Get.back(
                              result: {
                                'success': true,
                                'message': 'Perubahan staff berhasil disimpan',
                              },
                            );
                          } catch (_) {
                            if (!mounted) return;
                            _showInlineSnack(
                              context,
                              title: 'Gagal',
                              message: 'Tidak dapat memperbarui data staff.',
                              isSuccess: false,
                            );
                          }
                        },
                      ),
                    ),

                    SizedBox(height: spacing.lg),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ===================== PHOTO PICKER =====================

  Future<void> _selectImage(BuildContext context) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    try {
      await Get.bottomSheet(
        SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              spacing.lg,
              spacing.sm,
              spacing.lg,
              spacing.lg,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadii.xl),
                topRight: Radius.circular(AppRadii.xl),
              ),
              boxShadow: AppShadows.soft(cs.shadow),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: spacing.xxl,
                  height: spacing.xxs,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                ),
                SizedBox(height: spacing.md),
                Text(
                  'Pilih Foto Profil',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.xxs),
                Text(
                  'Ambil dari kamera atau pilih dari galeri.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _PickOptionCard(
                        icon: Icons.camera_alt_outlined,
                        title: 'Kamera',
                        subtitle: 'Ambil foto baru',
                        onTap: () async {
                          Get.back();
                          final status = await Permission.camera.request();
                          if (status.isGranted) {
                            await _takePicture();
                          } else if (status.isPermanentlyDenied) {
                            permissionUtils.showPermissionDialog(
                              title: 'Izin Kamera Diperlukan',
                              message:
                                  'Aktifkan izin kamera di pengaturan aplikasi.',
                            );
                          } else {
                            permissionUtils.showToast('Izin kamera ditolak');
                          }
                        },
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: _PickOptionCard(
                        icon: Icons.photo_library_outlined,
                        title: 'Galeri',
                        subtitle: 'Pilih dari album',
                        onTap: () async {
                          Get.back();
                          Permission permission;
                          if (Platform.isAndroid) {
                            permission =
                                await _isAndroid13OrAbove()
                                    ? Permission.photos
                                    : Permission.storage;
                          } else {
                            permission = Permission.photos;
                          }
                          final status = await permission.request();
                          if (status.isGranted) {
                            await _pickFromGallery();
                          } else if (status.isPermanentlyDenied) {
                            permissionUtils.showPermissionDialog(
                              title: 'Izin Penyimpanan Diperlukan',
                              message:
                                  'Aktifkan izin penyimpanan/foto di pengaturan aplikasi.',
                            );
                          } else {
                            permissionUtils.showToast('Izin galeri ditolak');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.md),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
    } catch (_) {
      permissionUtils.showToast('Gagal membuka pemilih foto');
    }
  }

  Future<void> _takePicture() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (photo != null) profilePicture.value = File(photo.path);
    } catch (_) {
      permissionUtils.showToast('Gagal mengambil foto');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) profilePicture.value = File(image.path);
    } catch (_) {
      permissionUtils.showToast('Gagal memilih foto');
    }
  }

  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }
}

// ===================== UI PARTS (PUNYAMU TETAP) =====================

class _HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeroHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
        boxShadow: AppShadows.soft(cs.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: spacing.xxs),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
        boxShadow: AppShadows.soft(cs.shadow),
      ),
      child: child,
    );
  }
}

class _ProfilePickerCard extends StatelessWidget {
  final Rx<File?> profilePicture;
  final String? networkUrl;
  final VoidCallback onPick;

  final String title;
  final String subtitle;

  const _ProfilePickerCard({
    required this.profilePicture,
    required this.networkUrl,
    required this.onPick,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    final double avatar = spacing.xxl * 2.1;
    final double ringPad = spacing.xs;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
        boxShadow: AppShadows.soft(cs.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() {
            final file = profilePicture.value;

            ImageProvider? img;
            if (file != null) {
              img = FileImage(file);
            } else if (networkUrl != null && (networkUrl ?? '').isNotEmpty) {
              img = NetworkImage(networkUrl!);
            }

            return Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onPick,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: EdgeInsets.all(ringPad),
                  decoration: ShapeDecoration(
                    shape: CircleBorder(
                      side: BorderSide(color: cs.primary.withOpacity(0.24)),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.16),
                        cs.secondary.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shadows: AppShadows.soft(cs.shadow),
                  ),
                  child: Container(
                    width: avatar,
                    height: avatar,
                    decoration: ShapeDecoration(
                      shape: const CircleBorder(),
                      color: cs.surfaceVariant.withOpacity(0.35),
                      image:
                          img != null
                              ? DecorationImage(image: img, fit: BoxFit.cover)
                              : null,
                    ),
                    child:
                        img == null
                            ? Icon(
                              Icons.person_add_alt_1_rounded,
                              color: cs.primary,
                              size: spacing.xl,
                            )
                            : null,
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: spacing.md),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.xxs),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: avatar * 2.1),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: spacing.md),
          TextButton.icon(
            onPressed: onPick,
            icon: Icon(Icons.add_a_photo_outlined, color: cs.primary),
            label: Text(
              'Pilih Foto',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final RxBool isActiveRx;
  final String title;
  final String subtitleOn;
  final String subtitleOff;

  const _StatusCard({
    required this.isActiveRx,
    required this.title,
    required this.subtitleOn,
    required this.subtitleOff,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
        boxShadow: AppShadows.soft(cs.shadow),
      ),
      child: Obx(() {
        final isOn = isActiveRx.value;

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: spacing.xxs),
                  Text(
                    isOn ? subtitleOn : subtitleOff,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isOn,
              onChanged: (v) => isActiveRx.value = v,
              activeColor: cs.primary,
            ),
          ],
        );
      }),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color toneColor;

  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.message,
    required this.toneColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
        boxShadow: AppShadows.soft(cs.shadow),
      ),
      child: Row(
        children: [
          Icon(icon, color: toneColor),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: spacing.xxs),
                Text(
                  message,
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
}

class _PickOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PickOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Container(
          padding: EdgeInsets.all(spacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(spacing.md),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(color: cs.primary.withOpacity(0.18)),
                ),
                child: Icon(icon, color: cs.primary, size: spacing.xl),
              ),
              SizedBox(height: spacing.md),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.xxs),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
