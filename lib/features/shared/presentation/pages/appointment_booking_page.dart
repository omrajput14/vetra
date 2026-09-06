import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/animal/presentation/providers/animal_provider.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/appointment/presentation/providers/appointment_provider.dart';
import 'package:vetra/features/auth/presentation/providers/auth_provider.dart';

class AppointmentBookingPage extends StatefulWidget {
  final Object? extraData;

  const AppointmentBookingPage({super.key, this.extraData});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final _formKey = GlobalKey<FormState>();
  AnimalModel? _selectedAnimal;
  Map<String, dynamic>? _selectedVetMap;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  VisitType _selectedVisitType = VisitType.generalCheckup;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _vetIdController = TextEditingController();
  String? _preselectedVetName;
  String? _preselectedAnimalId;
  bool _isEmergencyContext = false;

  @override
  void initState() {
    super.initState();
    if (widget.extraData is Map<String, dynamic>) {
      final map = widget.extraData as Map<String, dynamic>;
      _preselectedVetName = map['vetName'] as String?;
      if (map['vetId'] != null) {
        _vetIdController.text = map['vetId'].toString();
      }
      if (map['animalId'] != null && map['animalId'].toString().isNotEmpty) {
        _preselectedAnimalId = map['animalId'].toString();
      }
      if (map['isEmergency'] == true || map['visitType'] == VisitType.emergency) {
        _isEmergencyContext = true;
        _selectedVisitType = VisitType.emergency;
        _selectedDate = DateTime.now(); // Emergency is immediate (today)
      }
      if (map['reason'] != null) {
        _reasonController.text = map['reason'].toString();
      }
    } else if (widget.extraData is String) {
      final str = widget.extraData as String;
      _preselectedAnimalId = str;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await animalNotifier.loadAnimals();
      await authNotifier.fetchNearbyVets();

      if (animalNotifier.animals.isNotEmpty) {
        setState(() {
          if (_preselectedAnimalId != null && _preselectedAnimalId!.isNotEmpty) {
            final match = animalNotifier.animals.where(
              (a) => a.id == _preselectedAnimalId || a.tagNumber == _preselectedAnimalId,
            );
            if (match.isNotEmpty) {
              _selectedAnimal = match.first;
            } else {
              _selectedAnimal = animalNotifier.animals.first;
            }
          } else {
            _selectedAnimal = animalNotifier.animals.first;
          }
        });
      }

      if (_vetIdController.text.isEmpty && authNotifier.vetsList.isNotEmpty) {
        setState(() {
          _selectedVetMap = authNotifier.vetsList.first;
          _vetIdController.text = _selectedVetMap!['id'].toString();
          _preselectedVetName = _selectedVetMap!['fullName'].toString();
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

  String? _getShiftWarningForDate(DateTime date) {
    if (_selectedVetMap == null) return null;
    final isAvailable = _selectedVetMap!['isAvailable'] as bool? ?? true;
    if (!isAvailable) {
      return 'Notice: This veterinarian is currently on leave / unavailable for routine consultations.';
    }

    final scheduleStr = _selectedVetMap!['shiftSchedule']?.toString();
    if (scheduleStr != null && scheduleStr.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(scheduleStr);
        final dayKeys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
        final dayKey = dayKeys[date.weekday - 1];
        if (map.containsKey(dayKey)) {
          final dayData = map[dayKey] as Map<String, dynamic>;
          final isWorking = dayData['isWorking'] as bool? ?? true;
          if (!isWorking) {
            final dayName = DateFormat('EEEE').format(date);
            return 'Notice: Dr. ${_selectedVetMap!['fullName']} is off-duty on ${dayName}s. Emergency care is still accepted, but routine visits may need rescheduling.';
          }
        }
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final formattedTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';
    final shiftWarning = _getShiftWarningForDate(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text(
          _isEmergencyContext ? 'Book Emergency Care' : 'Book Checkup Appointment',
          style: AppTypography.screenTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([animalNotifier, appointmentNotifier, authNotifier]),
        builder: (context, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_isEmergencyContext) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.alertCritical.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.alertCritical, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emergency, color: AppColors.alertCritical, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n?.immediateVetAttentionRecommended ??
                                'Immediate veterinary attention recommended.',
                            style: AppTypography.captionMetadata.copyWith(
                              color: AppColors.alertCritical,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                _buildVetTrustCard(context, l10n),
                const SizedBox(height: 20),
                Text('1. Select Livestock Animal', style: AppTypography.sectionHeading),
                const SizedBox(height: 8),
                () {
                  final uniqueAnimals = <AnimalModel>[];
                  final seenIds = <String>{};
                  for (final a in animalNotifier.animals) {
                    if (seenIds.add(a.id)) {
                      uniqueAnimals.add(a);
                    }
                  }

                  if (uniqueAnimals.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cautionAmber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'No registered animals found. Please add an animal first.',
                        style: AppTypography.captionMetadata.copyWith(color: AppColors.cautionAmber),
                      ),
                    );
                  }

                  final effectiveSelected = uniqueAnimals.any((a) => a.id == _selectedAnimal?.id)
                      ? uniqueAnimals.firstWhere((a) => a.id == _selectedAnimal?.id)
                      : uniqueAnimals.first;

                  return DropdownButtonFormField<AnimalModel>(
                    initialValue: effectiveSelected,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: uniqueAnimals.map((a) {
                      return DropdownMenuItem<AnimalModel>(
                        value: a,
                        child: Text('${a.animalName ?? "Animal"} (${a.tagNumber}) - ${a.species}'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedAnimal = val),
                    validator: (val) => val == null ? (l10n?.selectAnimalFirst ?? 'Please select an animal') : null,
                  );
                }(),
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
                if (shiftWarning != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cautionAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cautionAmber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.cautionAmber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            shiftWarning,
                            style: AppTypography.captionMetadata.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                    hintText: 'Describe symptoms or clinical concern details...',
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter reason for visit' : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: appointmentNotifier.isLoading
                      ? 'Submitting...'
                      : (_isEmergencyContext ? 'Confirm Emergency Request' : 'Confirm & Request Appointment'),
                  onPressed: appointmentNotifier.isLoading ? null : () => _submitForm(context, formattedDate, formattedTime, l10n),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVetTrustCard(BuildContext context, AppLocalizations? l10n) {
    if (authNotifier.vetsList.isEmpty && _selectedVetMap == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cautionAmber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cautionAmber.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.cautionAmber, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n?.noVerifiedVetsNearby ?? 'No verified veterinarians are currently available nearby.',
                style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    final vetName = _preselectedVetName ?? (_selectedVetMap != null ? _selectedVetMap!['fullName']?.toString() : 'Select Veterinarian');
    final clinicName = _selectedVetMap != null ? _selectedVetMap!['clinicName']?.toString() : null;
    final clinicAddress = _selectedVetMap != null ? _selectedVetMap!['clinicAddress']?.toString() : null;
    final qualification = _selectedVetMap != null ? _selectedVetMap!['qualification']?.toString() : null;
    final photoUrl = _selectedVetMap != null ? _selectedVetMap!['profilePhotoUrl']?.toString() : null;
    final isVerified = _selectedVetMap != null && (_selectedVetMap!['verificationStatus'] == 'VERIFIED' || _selectedVetMap!['verified'] == true);
    final isAvailable = _selectedVetMap != null ? (_selectedVetMap!['isAvailable'] as bool? ?? true) : true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? const Icon(Icons.person, color: AppColors.primary, size: 28)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vetName ?? 'Select Veterinarian',
                            style: AppTypography.cardTitle.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 12, color: Colors.green),
                                SizedBox(width: 3),
                                Text('VERIFIED', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (qualification != null && qualification.isNotEmpty)
                      Text(qualification, style: AppTypography.captionMetadata.copyWith(color: AppColors.textSecondary)),
                    if (clinicName != null && clinicName.isNotEmpty)
                      Text(clinicName, style: AppTypography.captionMetadata.copyWith(fontWeight: FontWeight.bold)),
                    if (clinicAddress != null && clinicAddress.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMetadata),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(clinicAddress, style: AppTypography.captionMetadata, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isAvailable ? AppColors.primary : AppColors.alertCritical).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(isAvailable ? Icons.check_circle_outline : Icons.pause_circle_outline,
                        size: 14, color: isAvailable ? AppColors.primary : AppColors.alertCritical),
                    const SizedBox(width: 4),
                    Text(
                      isAvailable ? 'On Duty' : 'On Leave / Unavailable',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? AppColors.primary : AppColors.alertCritical,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showVetSelectionSheet(context, l10n),
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text('Switch Veterinarian', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVetSelectionSheet(BuildContext context, AppLocalizations? l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Choose Veterinarian', style: AppTypography.sectionHeading),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(sheetContext)),
                ],
              ),
              const Divider(),
              () {
                final uniqueVets = <Map<String, dynamic>>[];
                final seenVetKeys = <String>{};
                for (final v in authNotifier.vetsList) {
                  final name = (v['fullName'] ?? v['name'])?.toString().trim() ?? '';
                  final regNo = v['registrationNumber']?.toString().trim() ?? '';
                  final clinic = (v['clinicName'] ?? v['clinic'])?.toString().trim() ?? '';

                  if (name.startsWith('[RETIRED') || name.startsWith('[TEST')) continue;

                  final identityKey = name.isNotEmpty
                      ? 'name:${name.toLowerCase()}|${clinic.toLowerCase()}'
                      : (regNo.isNotEmpty ? 'reg:${regNo.toLowerCase()}' : (v['id']?.toString() ?? ''));
                  if (identityKey.isNotEmpty && !seenVetKeys.add(identityKey)) continue;

                  uniqueVets.add(v);
                }

                if (uniqueVets.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        l10n?.noVerifiedVetsNearby ?? 'No verified veterinarians are currently available nearby.',
                        style: AppTypography.captionMetadata,
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: uniqueVets.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final v = uniqueVets[idx];
                      final isSelected = _vetIdController.text == v['id']?.toString();
                      final photoUrl = v['profilePhotoUrl']?.toString();
                      final isVerified = v['verificationStatus'] == 'VERIFIED' || v['verified'] == true;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? const Icon(Icons.person, color: AppColors.primary)
                              : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(v['fullName'] ?? 'Veterinarian', style: AppTypography.cardTitle.copyWith(fontSize: 15))),
                            if (isVerified)
                              const Icon(Icons.verified, size: 14, color: Colors.green),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${v['clinicName'] ?? "Clinic"} • ${v['qualification'] ?? "BVSc"}', style: AppTypography.captionMetadata),
                            if (v['clinicAddress'] != null)
                              Text(v['clinicAddress'].toString(), style: AppTypography.captionMetadata.copyWith(fontSize: 11)),
                          ],
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
                            : const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMetadata),
                        onTap: () {
                          setState(() {
                            _selectedVetMap = v;
                            _vetIdController.text = v['id'].toString();
                            _preselectedVetName = v['fullName'].toString();
                          });
                          Navigator.pop(sheetContext);
                        },
                      );
                    },
                  ),
                );
              }(),
            ],
          ),
        );
      },
    );
  }

  void _submitForm(BuildContext context, String formattedDate, String formattedTime, AppLocalizations? l10n) async {
    if (!_formKey.currentState!.validate() || _selectedAnimal == null) return;

    if (authNotifier.vetsList.isEmpty && _vetIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.noVerifiedVetsNearby ?? 'No verified veterinarians are currently available nearby.'),
          backgroundColor: AppColors.alertCritical,
        ),
      );
      return;
    }

    final targetVetId = _vetIdController.text.trim().isNotEmpty
        ? _vetIdController.text.trim()
        : authNotifier.vetsList.first['id'].toString();

    final success = await appointmentNotifier.createAppointment(
      animalId: _selectedAnimal!.id,
      veterinarianId: targetVetId,
      appointmentDate: formattedDate,
      appointmentTime: formattedTime,
      visitType: _selectedVisitType,
      reason: _reasonController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Appointment requested successfully!'), backgroundColor: Colors.green),
      );
      this.context.pushReplacement('/farmer-appointments');
    } else {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text(appointmentNotifier.errorMessage ?? 'Failed to request appointment'), backgroundColor: Colors.red),
      );
    }
  }
}
