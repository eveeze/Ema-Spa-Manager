// lib/features/reservation/views/reservation_form_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:emababyspa/common/theme/color_theme.dart';
import 'package:emababyspa/common/layouts/main_layout.dart';
import 'package:emababyspa/common/widgets/app_button.dart';
import 'package:emababyspa/features/reservation/controllers/reservation_controller.dart';
import 'package:emababyspa/features/service/controllers/service_controller.dart';
import 'package:emababyspa/data/models/session.dart';
import 'package:emababyspa/data/models/service.dart';
import 'package:emababyspa/utils/timezone_utils.dart';

class ReservationFormView extends StatefulWidget {
  const ReservationFormView({super.key});

  @override
  State<ReservationFormView> createState() => _ReservationFormViewState();
}

class _ReservationFormViewState extends State<ReservationFormView> {
  final reservationController = Get.find<ReservationController>();
  final serviceController = Get.find<ServiceController>();

  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerInstagramController = TextEditingController();
  final _babyNameController = TextEditingController();
  final _babyAgeController = TextEditingController();
  final _parentNamesController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentNotesController = TextEditingController();

  // Form state
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
        _loadServiceData();
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
    // Load all services since all staff can perform all services
    serviceController.fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomActions(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Create Manual Reservation',
        style: TextStyle(
          color: ColorTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: ColorTheme.primary),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, ColorTheme.primary.withValues(alpha: 0.05)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedSession != null) _buildSessionInfoCard(),
              const SizedBox(height: 20),
              _buildCustomerInfoCard(),
              const SizedBox(height: 20),
              _buildBabyInfoCard(),
              const SizedBox(height: 20),
              _buildServiceSelectionCard(),
              const SizedBox(height: 20),
              _buildPaymentInfoCard(),
              const SizedBox(height: 20),
              _buildNotesCard(),
              const SizedBox(height: 100), // Space for bottom actions
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionInfoCard() {
    return _buildInfoCard(
      title: 'Session Information',
      icon: Icons.event,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Session ID', selectedSession!.id),
          if (selectedSession!.timeSlot != null) ...[
            _buildInfoRow(
              'Date',
              TimeZoneUtil.formatISOToIndonesiaTime(
                selectedSession!.timeSlot!.startTime.toIso8601String(),
                format: 'EEEE, d MMMM yyyy',
              ),
            ),
            _buildInfoRow(
              'Time',
              '${TimeZoneUtil.formatISOToIndonesiaTime(selectedSession!.timeSlot!.startTime.toIso8601String(), format: 'HH:mm')} - ${TimeZoneUtil.formatISOToIndonesiaTime(selectedSession!.timeSlot!.endTime.toIso8601String(), format: 'HH:mm')}',
            ),
          ],
          if (selectedSession!.staff != null) ...[
            _buildInfoRow('Staff', selectedSession!.staff!.name),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return _buildInfoCard(
      title: 'Customer Information',
      icon: Icons.person,
      child: Column(
        children: [
          _buildTextFormField(
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
            controller: _customerAddressController,
            label: 'Address (Optional)',
            hint: 'Enter customer address',
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
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

  Widget _buildBabyInfoCard() {
    return _buildInfoCard(
      title: 'Baby Information',
      icon: Icons.child_care,
      child: Column(
        children: [
          _buildTextFormField(
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
            controller: _parentNamesController,
            label: 'Parent Names (Optional)',
            hint: 'Enter parent names',
            icon: Icons.family_restroom_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelectionCard() {
    return _buildInfoCard(
      title: 'Service Selection',
      icon: Icons.spa,
      child: Obx(() {
        // Use the correct property name from ServiceController
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
                Icon(Icons.spa_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No Services Available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No services found. Please check your service configuration.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
                prefixIcon: Icon(Icons.spa_outlined, color: ColorTheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ColorTheme.primary, width: 2),
                ),
              ),
              value: selectedService,
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
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (service.description.isNotEmpty == true)
                            Text(
                              service.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
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
                  selectedPriceTierId = null; // Reset price tier selection
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
              _buildPriceTierSelection(),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildPriceTierSelection() {
    if (selectedService?.priceTiers == null ||
        selectedService!.priceTiers!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Tier',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        // Fixed: Removed unnecessary .toList() in spread operator
        ...selectedService!.priceTiers!.map((priceTier) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    selectedPriceTierId == priceTier.id
                        ? ColorTheme.primary
                        : Colors.grey.shade300,
                width: selectedPriceTierId == priceTier.id ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RadioListTile<String>(
              title: Text(
                // Fixed: Use tierName instead of name
                priceTier.tierName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed: Removed description as it doesn't exist in PriceTier model
                  // If you need description, you should add it to the PriceTier model
                  Text(
                    'Age: ${priceTier.minBabyAge}-${priceTier.maxBabyAge} months',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    'Rp ${priceTier.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.primary,
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
              activeColor: ColorTheme.primary,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentInfoCard() {
    return _buildInfoCard(
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
                color: ColorTheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorTheme.primary, width: 2),
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
            title: const Text('Payment Received'),
            subtitle: Text(
              isPaid ? 'Payment has been received' : 'Payment not yet received',
              style: TextStyle(
                color: isPaid ? Colors.green.shade600 : Colors.orange.shade600,
              ),
            ),
            value: isPaid,
            onChanged: (bool value) {
              setState(() {
                isPaid = value;
              });
            },
            activeColor: ColorTheme.primary,
          ),
          if (isPaid && selectedPaymentMethod != 'CASH') ...[
            const SizedBox(height: 16),
            _buildPaymentProofSection(),
          ],
          const SizedBox(height: 16),
          _buildTextFormField(
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

  Widget _buildPaymentProofSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Proof',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (paymentProofFile != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment proof selected',
                    style: TextStyle(
                      color: Colors.green.shade700,
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
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorTheme.primary,
              side: BorderSide(color: ColorTheme.primary),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesCard() {
    return _buildInfoCard(
      title: 'Additional Notes',
      icon: Icons.note,
      child: _buildTextFormField(
        controller: _notesController,
        label: 'Notes (Optional)',
        hint: 'Enter any additional notes or special requests',
        icon: Icons.note_outlined,
        maxLines: 3,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
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
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
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
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: ColorTheme.primary),
        prefixText: prefixText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Widget _buildBottomActions() {
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

        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedService == null) {
      Get.snackbar(
        'Error',
        'Please select a service',
        backgroundColor: ColorTheme.error.withValues(alpha: 0.1),
        colorText: ColorTheme.error,
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
