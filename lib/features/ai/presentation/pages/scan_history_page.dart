import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../data/api/ai_scan_api_service.dart';
import '../../data/datasources/ai_scan_local_datasource.dart';
import '../../data/models/ai_scan_model.dart';
import '../providers/ai_scan_provider.dart';

/// The user's AI scans from the server, plus scans on this phone still waiting to upload.
class ScanHistoryPage extends StatefulWidget {
  final Future<List<AIScanModel>> Function()? loadServer;
  final Future<List<AIScanModel>> Function()? loadLocal;
  const ScanHistoryPage({super.key, this.loadServer, this.loadLocal});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  List<AIScanModel>? _scans;
  Map<String, String> _localImages = {};
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    List<AIScanModel> local = [], server = [];
    String? error;
    try {
      local = await (widget.loadLocal ?? AiScanLocalDatasource.instance.getAll)();
    } catch (_) {}
    try {
      server = await (widget.loadServer ?? AIScanApiService().listScans)();
    } catch (e) {
      error = e.toString();
    }
    final serverIds = server.map((s) => s.id).toSet();
    final merged = [...local.where((l) => !serverIds.contains(l.id)), ...server]
      ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    if (!mounted) return;
    setState(() {
      _scans = merged;
      _localImages = {for (final l in local) l.id: l.imageUrl};
      _serverError = error;
    });
  }

  String _subtitle(AIScanModel s) {
    final d = DateTime.tryParse(s.createdAt ?? '');
    final when = d == null ? '' : DateFormat('d MMM yyyy, h:mm a').format(d.toLocal());
    final result = s.status == 'PENDING_UPLOAD'
        ? 'Waiting to upload'
        : s.isAnalysisFailure
            ? 'Scan failed'
            : '${s.diagnosis} (${((s.confidenceScore ?? 0) * 100).round()}%)';
    final review = switch (s.status) {
      'VERIFIED' => 'Confirmed by ${s.vetDisplayName ?? 'a vet'}',
      'REJECTED' => 'Not confirmed by ${s.vetDisplayName ?? 'a vet'}',
      'COMPLETED' => 'Awaiting vet review',
      _ => '',
    };
    return [result, review, when].where((x) => x.isNotEmpty).join(' • ');
  }

  void _open(AIScanModel s) {
    aiScanNotifier.setLastScanResult(s);
    final local = _localImages[s.id];
    context.push('/scan-results', extra: {
      'animalId': s.animalId,
      // Empty when the photo is not on this phone, so the results page shows none rather than an old one.
      'imagePath': local != null && File(local).existsSync() ? local : '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final scans = _scans;
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('AI Scan History', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: scans == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_serverError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('Showing scans saved on this phone only. $_serverError',
                          style: AppTypography.captionMetadata.copyWith(color: AppColors.alertCritical)),
                    ),
                  if (scans.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Text('No AI scans yet. Use Scan Disease to check an animal.',
                          textAlign: TextAlign.center, style: AppTypography.captionMetadata),
                    ),
                  for (final s in scans)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        tileColor: AppColors.surfaceCard,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        leading: Icon(
                          s.status == 'PENDING_UPLOAD' ? Icons.cloud_upload_outlined : Icons.center_focus_strong,
                          color: s.isAnalysisFailure ? AppColors.alertCritical : AppColors.primary,
                        ),
                        title: Text(s.animalName ?? 'Animal scan', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                        subtitle: Text(_subtitle(s), style: AppTypography.captionMetadata),
                        trailing: s.status == 'PENDING_UPLOAD' || s.isAnalysisFailure ? null : const Icon(Icons.chevron_right),
                        onTap: s.status == 'PENDING_UPLOAD' || s.isAnalysisFailure ? null : () => _open(s),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
