// lib/features/reservation/views/reservation_form_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/data/models/session.dart';
import 'package:emababyspa/data/models/service.dart';
import 'package:emababyspa/utils/timezone_utils.dart';
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

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
          if (mounted) {
            _loadServiceData();
          }
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
    return MainLayout(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        bottomNavigationBar: _buildBottomActions(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final appBarTheme = Theme.of(context).appBarTheme;
    return AppBar(
      title: Text(
        'Create Manual Reservation',
        style: appBarTheme.titleTextStyle,
      ),
      backgroundColor: appBarTheme.backgroundColor,
      elevation: appBarTheme.elevation,
      iconTheme: appBarTheme.iconTheme,
      foregroundColor: appBarTheme.foregroundColor,
    );
  }

  Widget _buildBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.background,
            colorScheme.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedSession != null) _buildSessionInfoCard(context),
              const SizedBox(height: 20),
              _buildCustomerInfoCard(context),
              const SizedBox(height: 20),
              _buildBabyInfoCard(context),
              const SizedBox(height: 20),
              _buildServiceSelectionCard(context),
              const SizedBox(height: 20),
              _buildPaymentInfoCard(context),
              const SizedBox(height: 20),
              _buildNotesCard(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionInfoCard(BuildContext context) {
    return _buildInfoCard(
      context: context,
      title: 'Session Information',
      icon: Icons.event,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(context, 'Session ID', selectedSession!.id),
          if (selectedSession!.timeSlot != null) ...[
            _buildInfoRow(
              context,
              'Date',
              TimeZoneUtil.formatISOToIndonesiaTime(
                selectedSession!.timeSlot!.startTime.toIso8601String(),
                format: 'EEEE, d MMMM yyyy',
              ),
            ),
            _buildInfoRow(
              context,
              'Time',
              '${TimeZoneUtil.formatISOToIndonesiaTime(selectedSession!.timeSlot!.startTime.toIso8601String(), format: 'HH:mm')} - ${TimeZoneUtil.formatISOToIndonesiaTime(selectedSession!.timeSlot!.endTime.toIso8601String(), format: 'HH:mm')}',
            ),
          ],
          if (selectedSession!.staff != null) ...[
            _buildInfoRow(context, 'Staff', selectedSession!.staff!.name),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(BuildContext context) {
    return _buildInfoCard(
      context: context,
      title: 'Customer Information',
      icon: Icons.person,
      child: Column(
        children: [
          _buildTextFormField(
            context: context,
            controller: _customerNameController,
            label: 'Customer Name',
            hint: 'Enter customer full name',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Customer name is required';
              }
              if (value.trim().length < 2) {
                return 'Customer name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            context: context,
            controller: _customerPhoneController,
            label: 'Phone Number',
            hint: 'Enter phone number (e.g., 08123456789)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (value.trim().length < 10) {
                return 'Phone number must be at least 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            context: context,
            controller: _customerAddressController,
            label: 'Address (Optional)',
            hint: 'Enter customer address',
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            context: context,
            controller: _customerInstagramController,
            label: 'Instagram (Optional)',
            hint: 'Enter Instagram username',
            icon: Icons.camera_alt_outlined,
            prefixText: '@',
          ),
        ],
      ),
    );
  }

  Widget _buildBabyInfoCard(BuildContext context) {
    return _buildInfoCard(
      context: context,
      title: 'Baby Information',
      icon: Icons.child_care,
      child: Column(
        children: [
          _buildTextFormField(
            context: context,
            controller: _babyNameController,
            label: 'Baby Name',
            hint: 'Enter baby name',
            icon: Icons.child_friendly_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Baby name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            context: context,
            controller: _babyAgeController,
            label: 'Baby Age (months)',
            hint: 'Enter baby age in months',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Baby age is required';
              }
              final age = int.tryParse(value.trim());
              if (age == null || age < 0 || age > 60) {
                return 'Please enter a valid age (0-60 months)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            context: context,
            controller: _parentNamesController,
            label: 'Parent Names (Optional)',
            hint: 'Enter parent names',
            icon: Icons.family_restroom_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelectionCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _buildInfoCard(
      context: context,
      title: 'Service Selection',
      icon: Icons.spa,
      child: Obx(() {
        final services = serviceController.services;

        if (serviceController.isLoadingServices.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (services.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.spa_outlined,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  'No Services Available',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No services found. Please check your service configuration.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
              decoration: InputDecoration(
                labelText: 'Select Service',
                prefixIcon: Icon(
                  Icons.spa_outlined,
                  color: colorScheme.primary,
                ),
              ),
              value: selectedService,
              isExpanded: true,
              // ✨ --- PERBAIKAN UTAMA DI SINI --- ✨
              // Builder ini untuk mendefinisikan widget yang tampil SETELAH item dipilih.
              // Kita gunakan Text sederhana agar pas dan tidak overflow.
              selectedItemBuilder: (BuildContext context) {
                return services.map<Widget>((Service item) {
                  return Text(item.name, overflow: TextOverflow.ellipsis);
                }).toList();
              },
              // Builder 'items' tetap sama untuk menampilkan detail di dalam list.
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (service.description.isNotEmpty == true)
                            Text(
                              service.description,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (Service? value) {
                setState(() {
                  selectedService = value;
                  selectedPriceTierId = null;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a service';
                }
                return null;
              },
            ),
            if (selectedService != null) ...[
              const SizedBox(height: 16),
              _buildPriceTierSelection(context),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildPriceTierSelection(BuildContext context) {
    if (selectedService?.priceTiers == null ||
        selectedService!.priceTiers!.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Tier',
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        ...selectedService!.priceTiers!.map((priceTier) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    selectedPriceTierId == priceTier.id
                        ? colorScheme.primary
                        : colorScheme.outline,
                width: selectedPriceTierId == priceTier.id ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RadioListTile<String>(
              title: Text(
                priceTier.tierName,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Age: ${priceTier.minBabyAge}-${priceTier.maxBabyAge} months',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Rp ${priceTier.price.toStringAsFixed(0)}',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              value: priceTier.id,
              groupValue: selectedPriceTierId,
              onChanged: (String? value) {
                setState(() {
                  selectedPriceTierId = value;
                });
              },
              activeColor: colorScheme.primary,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return _buildInfoCard(
      context: context,
      title: 'Payment Information',
      icon: Icons.payment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Payment Method',
              prefixIcon: Icon(
                Icons.payment_outlined,
                color: colorScheme.primary,
              ),
            ),
            value: selectedPaymentMethod,
            items:
                paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedPaymentMethod = value ?? 'CASH';
              });
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('Payment Received', style: textTheme.bodyLarge),
            subtitle: Text(
              isPaid ? 'Payment has been received' : 'Payment not yet received',
              style: textTheme.bodyMedium?.copyWith(
                color: isPaid ? Colors.green.shade400 : Colors.orange.shade400,
              ),
            ),
            value: isPaid,
            onChanged: (bool value) {
              setState(() {
                isPaid = value;
              });
            },
            activeColor: colorScheme.primary,
            tileColor: colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          if (isPaid && selectedPaymentMethod != 'CASH') ...[
            const SizedBox(height: 16),
            _buildPaymentProofSection(context),
          ],
          const SizedBox(height: 16),
          _buildTextFormField(
            context: context,
            controller: _paymentNotesController,
            label: 'Payment Notes (Optional)',
            hint: 'Enter payment notes',
            icon: Icons.note_outlined,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProofSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDark = themeController.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Proof', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        if (paymentProofFile != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.green.shade700 : Colors.green.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: isDark ? Colors.green.shade300 : Colors.green.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment proof selected',
                    style: textTheme.bodyLarge?.copyWith(
                      color:
                          isDark
                              ? Colors.green.shade200
                              : Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      paymentProofFile = null;
                    });
                  },
                  child: const Text('Remove'),
                ),
              ],
            ),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: _pickPaymentProof,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Upload Payment Proof'),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return _buildInfoCard(
      context: context,
      title: 'Additional Notes',
      icon: Icons.note,
      child: _buildTextFormField(
        context: context,
        controller: _notesController,
        label: 'Notes (Optional)',
        hint: 'Enter any additional notes or special requests',
        icon: Icons.note_outlined,
        maxLines: 3,
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardTheme = Theme.of(context).cardTheme;

    return Container(
      decoration: BoxDecoration(
        color: cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
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
              color: colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
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
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        prefixText: prefixText,
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(':', style: textTheme.bodyMedium),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: 'Create Reservation',
                icon: Icons.add_circle_outline,
                isLoading: reservationController.isFormSubmitting.value,
                onPressed: _canSubmit() ? _submitForm : null,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed:
                    reservationController.isFormSubmitting.value
                        ? null
                        : () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          );
        }),
      ),
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
        setState(() {
          paymentProofFile = File(pickedFile.path);
        });
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
