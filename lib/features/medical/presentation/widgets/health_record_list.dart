import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../animal/data/models/animal_health_record_dto.dart';
import '../../../animal/presentation/providers/animal_provider.dart';

String formatRecordDate(String? iso) {
  final d = iso == null ? null : DateTime.tryParse(iso);
  return d == null ? (iso ?? '') : DateFormat('d MMM yyyy').format(d.toLocal());
}

/// One animal's health records from the server, narrowed by [where].
class HealthRecordList extends StatefulWidget {
  final String title;
  final String animalId;
  final bool Function(AnimalHealthRecordModel) where;
  final String Function(AnimalHealthRecordModel) subtitle;
  final String emptyMessage;
  final IconData icon;
  final void Function(BuildContext, AnimalHealthRecordModel)? onTap;

  const HealthRecordList({
    super.key,
    required this.title,
    required this.animalId,
    required this.where,
    required this.subtitle,
    required this.emptyMessage,
    required this.icon,
    this.onTap,
  });

  @override
  State<HealthRecordList> createState() => _HealthRecordListState();
}

class _HealthRecordListState extends State<HealthRecordList> {
  @override
  void initState() {
    super.initState();
    // After the first frame: loadTimeline notifies at once, which would rebuild the
    // passport underneath while this route is still building.
    if (widget.animalId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => animalNotifier.loadTimeline(widget.animalId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title, style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: animalNotifier,
        builder: (context, _) {
          final records = animalNotifier.getTimeline(widget.animalId).where(widget.where).toList();
          if (records.isEmpty && animalNotifier.isTimelineLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.animalId.isEmpty || records.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  widget.animalId.isEmpty ? 'Open this from an animal\'s passport.' : widget.emptyMessage,
                  style: AppTypography.captionMetadata,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = records[i];
              return ListTile(
                tileColor: AppColors.surfaceCard,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                leading: Icon(widget.icon, color: AppColors.primary),
                title: Text(r.vaccineName ?? r.title, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                subtitle: Text(widget.subtitle(r), style: AppTypography.captionMetadata),
                onTap: widget.onTap == null ? null : () => widget.onTap!(context, r),
              );
            },
          );
        },
      ),
    );
  }
}
