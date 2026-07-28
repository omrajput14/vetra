import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/animal/presentation/providers/animal_provider.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/appointment/presentation/providers/appointment_provider.dart';

class AppointmentBookingPage extends StatefulWidget {
  final Object? extraData;

  const AppointmentBookingPage({super.key, this.extraData});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final _formKey = GlobalKey<FormState>();
  AnimalModel? _selectedAnimal;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  VisitType _selectedVisitType = VisitType.generalCheckup;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _vetIdController = TextEditingController();
  String? _preselectedVetName;

  @override
  void initState() {
    super.initState();
    if (widget.extraData is Map<String, dynamic>) {
      final map = widget.extraData as Map<String, dynamic>;
      _preselectedVetName = map['vetName'] as String?;
      if (map['vetId'] != null) {
        _vetIdController.text = map['vetId'].toString();
      }
    } else if (widget.extraData is String) {
      _preselectedVetName = widget.extraData as String;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await animalNotifier.loadAnimals();
      if (animalNotifier.animals.isNotEmpty) {
        setState(() {
          _selectedAnimal = animalNotifier.animals.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _vetIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final formattedTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Book Checkup Appointment', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([animalNotifier, appointmentNotifier]),
        builder: (context, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_preselectedVetName != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_hospital, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Selected Veterinarian', style: AppTypography.captionMetadata),
                              Text(_preselectedVetName!, style: AppTypography.cardTitle.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text('1. Select Livestock Animal', style: AppTypography.sectionHeading),
                const SizedBox(height: 8),
                animalNotifier.animals.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cautionAmber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'No registered animals found. Please add an animal first.',
                          style: AppTypography.captionMetadata.copyWith(color: AppColors.cautionAmber),
                        ),
                      )
                    : DropdownButtonFormField<AnimalModel>(
                        initialValue: _selectedAnimal,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceCard,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: animalNotifier.animals.map((a) {
                          return DropdownMenuItem(
                            value: a,
                            child: Text('${a.animalName ?? "Animal"} (${a.tagNumber}) - ${a.species}'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedAnimal = val),
                        validator: (val) => val == null ? 'Please select an animal' : null,
                      ),
                const SizedBox(height: 20),
                Text('2. Date & Time', style: AppTypography.sectionHeading),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderHairline),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(formattedDate, style: AppTypography.bodyDefault),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (picked != null) setState(() => _selectedTime = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderHairline),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(_selectedTime.format(context), style: AppTypography.bodyDefault),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('3. Visit Type', style: AppTypography.sectionHeading),
                const SizedBox(height: 8),
                DropdownButtonFormField<VisitType>(
                  initialValue: _selectedVisitType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: VisitType.values.map((v) {
                    return DropdownMenuItem(
                      value: v,
                      child: Text(v.toDisplayString()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedVisitType = val);
                  },
                ),
                const SizedBox(height: 20),
                Text('4. Reason for Appointment', style: AppTypography.sectionHeading),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Describe symptoms or routine checkup details...',
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter reason for visit' : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: appointmentNotifier.isLoading ? 'Submitting...' : 'Confirm & Request Appointment',
                  onPressed: appointmentNotifier.isLoading ? null : () => _submitForm(formattedDate, formattedTime),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submitForm(String formattedDate, String formattedTime) async {
    if (!_formKey.currentState!.validate() || _selectedAnimal == null) return;

    final success = await appointmentNotifier.createAppointment(
      animalId: _selectedAnimal!.id,
      veterinarianId: _vetIdController.text.trim().isNotEmpty 
          ? _vetIdController.text.trim() 
          : '00000000-0000-0000-0000-000000000000',
      appointmentDate: formattedDate,
      appointmentTime: formattedTime,
      visitType: _selectedVisitType,
      reason: _reasonController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment requested successfully!'), backgroundColor: Colors.green),
        );
        context.pushReplacement('/farmer-appointments');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appointmentNotifier.errorMessage ?? 'Failed to request appointment'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
