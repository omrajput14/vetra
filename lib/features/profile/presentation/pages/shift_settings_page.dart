import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DayShiftConfig {
  final String dayName;
  final String dayKey;
  bool isWorking;
  TimeOfDay startTime;
  TimeOfDay endTime;

  DayShiftConfig({
    required this.dayName,
    required this.dayKey,
    required this.isWorking,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'isWorking': isWorking,
      'start': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'end': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
    };
  }

  factory DayShiftConfig.fromJson(String dayName, String dayKey, Map<String, dynamic> json) {
    final isWorking = json['isWorking'] as bool? ?? true;
    final startStr = json['start'] as String? ?? '09:00';
    final endStr = json['end'] as String? ?? '17:00';

    final startParts = startStr.split(':');
    final endParts = endStr.split(':');

    final start = TimeOfDay(
      hour: int.tryParse(startParts[0]) ?? 9,
      minute: startParts.length > 1 ? (int.tryParse(startParts[1]) ?? 0) : 0,
    );
    final end = TimeOfDay(
      hour: int.tryParse(endParts[0]) ?? 17,
      minute: endParts.length > 1 ? (int.tryParse(endParts[1]) ?? 0) : 0,
    );

    return DayShiftConfig(
      dayName: dayName,
      dayKey: dayKey,
      isWorking: isWorking,
      startTime: start,
      endTime: end,
    );
  }
}

class ShiftSettingsPage extends StatefulWidget {
  const ShiftSettingsPage({super.key});

  @override
  State<ShiftSettingsPage> createState() => _ShiftSettingsPageState();
}

class _ShiftSettingsPageState extends State<ShiftSettingsPage> {
  bool _isAvailable = true;
  bool _emergencyAvailable = true;
  bool _isSaving = false;
  String? _validationError;

  late List<DayShiftConfig> _schedule;

  @override
  void initState() {
    super.initState();
    _initScheduleFromUser();
  }

  void _initScheduleFromUser() {
    final user = authNotifier.currentUser;
    _isAvailable = user?.isAvailable ?? true;
    _emergencyAvailable = user?.emergencyAvailable ?? true;

    final defaultSchedule = [
      DayShiftConfig(dayName: 'Monday', dayKey: 'monday', isWorking: true, startTime: const TimeOfDay(hour: 9, minute: 0), endTime: const TimeOfDay(hour: 17, minute: 0)),
      DayShiftConfig(dayName: 'Tuesday', dayKey: 'tuesday', isWorking: true, startTime: const TimeOfDay(hour: 9, minute: 0), endTime: const TimeOfDay(hour: 17, minute: 0)),
      DayShiftConfig(dayName: 'Wednesday', dayKey: 'wednesday', isWorking: true, startTime: const TimeOfDay(hour: 9, minute: 0), endTime: const TimeOfDay(hour: 17, minute: 0)),
      DayShiftConfig(dayName: 'Thursday', dayKey: 'thursday', isWorking: true, startTime: const TimeOfDay(hour: 9, minute: 0), endTime: const TimeOfDay(hour: 17, minute: 0)),
      DayShiftConfig(dayName: 'Friday', dayKey: 'friday', isWorking: true, startTime: const TimeOfDay(hour: 9, minute: 0), endTime: const TimeOfDay(hour: 17, minute: 0)),
      DayShiftConfig(dayName: 'Saturday', dayKey: 'saturday', isWorking: true, startTime: const TimeOfDay(hour: 9, minute: 0), endTime: const TimeOfDay(hour: 14, minute: 0)),
      DayShiftConfig(dayName: 'Sunday', dayKey: 'sunday', isWorking: false, startTime: const TimeOfDay(hour: 9, minute: 0), endTime: const TimeOfDay(hour: 13, minute: 0)),
    ];

    if (user?.shiftSchedule != null && user!.shiftSchedule!.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(user.shiftSchedule!);
        _schedule = defaultSchedule.map((def) {
          if (map.containsKey(def.dayKey) && map[def.dayKey] is Map<String, dynamic>) {
            return DayShiftConfig.fromJson(def.dayName, def.dayKey, map[def.dayKey] as Map<String, dynamic>);
          }
          return def;
        }).toList();
        return;
      } catch (_) {}
    }

    _schedule = defaultSchedule;
  }

  bool _validateSchedule() {
    for (final day in _schedule) {
      if (day.isWorking) {
        final startMinutes = day.startTime.hour * 60 + day.startTime.minute;
        final endMinutes = day.endTime.hour * 60 + day.endTime.minute;
        if (endMinutes <= startMinutes) {
          setState(() {
            _validationError = '${day.dayName}: Closing time must be later than opening time.';
          });
          return false;
        }
      }
    }
    setState(() => _validationError = null);
    return true;
  }

  Future<void> _handleSave() async {
    if (!_validateSchedule()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_validationError ?? 'Invalid schedule timing detected'),
          backgroundColor: AppColors.alertCritical,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final Map<String, dynamic> scheduleMap = {};
    for (final day in _schedule) {
      scheduleMap[day.dayKey] = day.toJson();
    }
    final scheduleJson = jsonEncode(scheduleMap);

    final success = await authNotifier.updateProfile(
      isAvailable: _isAvailable,
      emergencyAvailable: _emergencyAvailable,
      shiftSchedule: scheduleJson,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shift settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      if (Navigator.of(context).canPop()) {
        context.pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authNotifier.errorMessage ?? 'Failed to save shift settings'),
          backgroundColor: AppColors.alertCritical,
        ),
      );
    }
  }

  void _applyStandardWeekdays() {
    setState(() {
      for (final day in _schedule) {
        if (day.dayKey != 'saturday' && day.dayKey != 'sunday') {
          day.isWorking = true;
          day.startTime = const TimeOfDay(hour: 9, minute: 0);
          day.endTime = const TimeOfDay(hour: 17, minute: 0);
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Applied 09:00 - 17:00 standard hours to Mon-Fri')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text(l10n?.availabilityShiftSettings ?? 'Shift Settings', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          tooltip: 'Back to Profile',
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: Text(
              l10n?.save ?? 'Save',
              style: AppTypography.cardTitle.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Master Duty Toggle Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _isAvailable ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderHairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (_isAvailable ? AppColors.primary : AppColors.cautionAmber).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isAvailable ? Icons.check_circle : Icons.pause_circle_filled,
                            color: _isAvailable ? AppColors.primary : AppColors.cautionAmber,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('General Consultation Duty', style: AppTypography.cardTitle),
                            Text(
                              _isAvailable ? 'Active for farmer bookings' : 'Currently paused / On leave',
                              style: AppTypography.captionMetadata.copyWith(
                                color: _isAvailable ? AppColors.primary : AppColors.cautionAmber,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isAvailable = val),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.alertCritical.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emergency, color: AppColors.alertCritical, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('24/7 Emergency Response', style: AppTypography.cardTitle),
                            Text('Receive critical disease alerts & calls', style: AppTypography.captionMetadata),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _emergencyAvailable,
                      activeThumbColor: AppColors.alertCritical,
                      onChanged: (val) => setState(() => _emergencyAvailable = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Weekly Schedule Header & Quick Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Working Hours', style: AppTypography.sectionHeading),
              TextButton.icon(
                onPressed: _applyStandardWeekdays,
                icon: const Icon(Icons.auto_fix_high, size: 16, color: AppColors.primary),
                label: const Text('Mon–Fri Standard', style: TextStyle(fontSize: 12, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_validationError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.alertCritical.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.alertCritical),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.alertCritical, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validationError!,
                      style: AppTypography.captionMetadata.copyWith(color: AppColors.alertCritical, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 3. Day By Day Shift Cards
          ..._schedule.map((dayConfig) => _buildDayCard(dayConfig)),

          const SizedBox(height: 24),

          // 4. Save & Cancel Action Buttons
          PrimaryButton(
            label: _isSaving ? 'Saving Changes...' : 'Save Shift Settings',
            onPressed: _isSaving ? null : _handleSave,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _isSaving ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.borderHairline),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Center(
              child: Text(l10n?.cancel ?? 'Cancel Changes', style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDayCard(DayShiftConfig day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: day.isWorking ? AppColors.primary.withValues(alpha: 0.2) : AppColors.borderHairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    day.isWorking ? Icons.calendar_today : Icons.event_busy,
                    size: 20,
                    color: day.isWorking ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    day.dayName,
                    style: AppTypography.cardTitle.copyWith(
                      color: day.isWorking ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (day.isWorking ? AppColors.primary : AppColors.textSecondary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      day.isWorking ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: day.isWorking ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: day.isWorking,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        day.isWorking = val;
                        _validateSchedule();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          if (day.isWorking) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: day.startTime,
                      );
                      if (picked != null) {
                        setState(() {
                          day.startTime = picked;
                          _validateSchedule();
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderHairline),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Open', style: AppTypography.captionMetadata),
                          Text(day.startTime.format(context), style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('—', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: day.endTime,
                      );
                      if (picked != null) {
                        setState(() {
                          day.endTime = picked;
                          _validateSchedule();
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderHairline),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Close', style: AppTypography.captionMetadata),
                          Text(day.endTime.format(context), style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
