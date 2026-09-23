import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/offline/models/offline_operation.dart';
import '../../../../core/offline/operation_queue.dart';
import '../../../../core/offline/sync_status_notifier.dart';

/// Everything saved on this device that stopped syncing, with the reason and a Retry.
class SyncIssuesPage extends StatelessWidget {
  const SyncIssuesPage({super.key});

  static const _labels = {
    OfflineOperationType.createAnimal: 'Animal registration',
    OfflineOperationType.updateAnimal: 'Animal details update',
    OfflineOperationType.deleteAnimal: 'Animal removal',
    OfflineOperationType.createDiseaseReport: 'Disease report',
    OfflineOperationType.submitAiScan: 'AI scan upload',
    OfflineOperationType.reportMortality: 'Death report',
    OfflineOperationType.confirmMortality: 'Death confirmation',
    OfflineOperationType.rejectMortality: 'Death report rejection',
  };

  String _subject(OfflineOperation op) {
    try {
      final p = jsonDecode(op.payloadJson) as Map<String, dynamic>;
      final parts = [p['animalName'], p['tagNumber'] != null ? 'Tag ${p['tagNumber']}' : null, p['diseaseName']]
          .whereType<String>()
          .where((s) => s.isNotEmpty);
      return parts.join(' • ');
    } catch (_) {
      return '';
    }
  }

  String _reason(OfflineOperation op) {
    if (op.status == OperationStatus.cancelled) {
      return 'Not sent: it depends on another item that failed. Retry sends both.';
    }
    final attempts = '${op.retryCount} attempt${op.retryCount == 1 ? '' : 's'}';
    return 'Failed after $attempts: ${op.lastError ?? 'unknown error'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Sync issues', style: AppTypography.screenTitle),
        actions: [
          TextButton(
            onPressed: () => syncStatusNotifier.retryAllFailed(),
            child: const Text('Retry all'),
          ),
        ],
      ),
      body: StreamBuilder<List<OfflineOperation>>(
        stream: OperationQueue.instance.watchFailed(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <OfflineOperation>[];
          if (snapshot.connectionState == ConnectionState.waiting && items.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (items.isEmpty) {
            return Center(
              child: Text('Nothing is stuck. Everything saved on this device has synced.',
                  style: AppTypography.bodyDefault, textAlign: TextAlign.center),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final op = items[i];
              final subject = _subject(op);
              final saved = DateTime.fromMillisecondsSinceEpoch(op.createdAt);
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.alertCritical.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sync_problem_rounded, color: AppColors.alertCritical, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_labels[op.operationType] ?? op.operationType.name,
                              style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                        ),
                        Text(
                          op.status == OperationStatus.cancelled ? 'NOT SENT' : 'SYNC FAILED',
                          style: AppTypography.captionMetadata.copyWith(
                              color: AppColors.alertCritical, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (subject.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(subject, style: AppTypography.bodyDefault.copyWith(fontSize: 14)),
                    ],
                    const SizedBox(height: 6),
                    Text(_reason(op), style: AppTypography.captionMetadata.copyWith(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      'Saved on this device ${saved.day.toString().padLeft(2, '0')}/${saved.month.toString().padLeft(2, '0')} '
                      '${saved.hour.toString().padLeft(2, '0')}:${saved.minute.toString().padLeft(2, '0')}',
                      style: AppTypography.captionMetadata.copyWith(fontSize: 12),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => syncStatusNotifier.retryFailed(op.operationId),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
