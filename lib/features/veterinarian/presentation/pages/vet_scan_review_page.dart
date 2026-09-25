import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../ai/data/api/ai_scan_api_service.dart';
import '../../../ai/data/models/ai_scan_model.dart';

String _when(String? iso) {
  final d = DateTime.tryParse(iso ?? '');
  return d == null ? '' : DateFormat('d MMM yyyy, h:mm a').format(d.toLocal());
}

/// The farmer's photo: scans store it inline as a data URI; older ones may be a URL.
class ScanPhoto extends StatelessWidget {
  final String imageUrl;
  final double height;
  const ScanPhoto({super.key, required this.imageUrl, this.height = 220});

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (imageUrl.startsWith('data:image') && imageUrl.contains(',')) {
      try {
        child = Image.memory(base64Decode(imageUrl.substring(imageUrl.indexOf(',') + 1)), fit: BoxFit.cover);
      } catch (_) {
        child = const Icon(Icons.broken_image_outlined, size: 40, color: AppColors.textMetadata);
      }
    } else if (imageUrl.startsWith('http')) {
      child = Image.network(imageUrl, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 40));
    } else {
      child = const Icon(Icons.image_not_supported_outlined, size: 40, color: AppColors.textMetadata);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(height: height, width: double.infinity, color: AppColors.surfaceCard, child: child),
    );
  }
}

/// Vet's queue of AI scans that no vet has approved or rejected yet.
class VetScanReviewListPage extends StatefulWidget {
  final AIScanApiService? api;
  const VetScanReviewListPage({super.key, this.api});

  @override
  State<VetScanReviewListPage> createState() => _VetScanReviewListPageState();
}

class _VetScanReviewListPageState extends State<VetScanReviewListPage> {
  static const _pageSize = 10;
  late final AIScanApiService _api = widget.api ?? AIScanApiService();
  final List<AIScanModel> _queue = [];
  int _nextPage = 0;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _reload() async {
    setState(() {
      _queue.clear();
      _nextPage = 0;
      _hasMore = true;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _api.listScansPage(page: _nextPage, size: _pageSize);
      if (!mounted) return;
      setState(() {
        _queue.addAll(page.where((s) => s.awaitingVetReview));
        _nextPage++;
        _hasMore = page.length == _pageSize;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(AIScanModel scan) async {
    final reviewed = await context.push<bool>('/vet-scan-review', extra: scan);
    if (reviewed == true && mounted) setState(() => _queue.removeWhere((s) => s.id == scan.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('AI Scans to Review', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Farmers\' AI scans need a vet\'s decision. Approving adds the diagnosis to the animal\'s '
              'record and reports a confirmed case for outbreak monitoring.',
              style: AppTypography.captionMetadata,
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: AppTypography.bodyDefault.copyWith(color: AppColors.alertCritical)),
            if (_queue.isEmpty && !_loading && _error == null && !_hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Text('No scans waiting for review.',
                    textAlign: TextAlign.center, style: AppTypography.captionMetadata),
              ),
            for (final s in _queue)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: AppColors.surfaceCard,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  leading: SizedBox(width: 56, child: ScanPhoto(imageUrl: s.imageUrl, height: 56)),
                  title: Text(
                    '${s.diagnosis ?? 'Unclear'} (${((s.confidenceScore ?? 0) * 100).round()}%)',
                    style: AppTypography.cardTitle.copyWith(fontSize: 15),
                  ),
                  subtitle: Text(
                    [s.animalName, s.farmerDisplayName, _when(s.createdAt)].whereType<String>().where((x) => x.isNotEmpty).join(' • '),
                    style: AppTypography.captionMetadata,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _open(s),
                ),
              ),
            if (_loading) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
            if (!_loading && _hasMore)
              TextButton(onPressed: _loadMore, child: const Text('Load older scans')),
          ],
        ),
      ),
    );
  }
}

/// Asks why the AI is wrong; returns the reason (null when cancelled). Owns its controller so
/// it stays alive through the closing animation.
class _RejectReasonDialog extends StatefulWidget {
  const _RejectReasonDialog();

  @override
  State<_RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<_RejectReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject AI result'),
      content: TextField(
        controller: _reason,
        autofocus: true,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'Why is the AI result wrong? The farmer will see this.'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, _reason.text.trim()), child: const Text('Reject')),
      ],
    );
  }
}

/// One scan: the farmer's photo and the AI's reading, with Approve / Reject.
class VetScanReviewDetailPage extends StatefulWidget {
  final AIScanModel scan;
  final AIScanApiService? api;
  const VetScanReviewDetailPage({super.key, required this.scan, this.api});

  @override
  State<VetScanReviewDetailPage> createState() => _VetScanReviewDetailPageState();
}

class _VetScanReviewDetailPageState extends State<VetScanReviewDetailPage> {
  late final AIScanApiService _api = widget.api ?? AIScanApiService();
  final _advice = TextEditingController();
  final _diagnosis = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _advice.dispose();
    _diagnosis.dispose();
    super.dispose();
  }

  Future<void> _decide(Future<AIScanModel> Function() call, String done) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
      context.pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.toString();
        });
      }
    }
  }

  void _approve() => _decide(
        () => _api.approveScan(widget.scan.id,
            treatmentNotes: _advice.text.trim(), customDiagnosis: _diagnosis.text.trim()),
        'Approved. Added to the animal\'s record and reported as a confirmed case.',
      );

  Future<void> _reject() async {
    final reason = await showDialog<String>(context: context, builder: (_) => const _RejectReasonDialog());
    if (reason != null && reason.isNotEmpty) {
      _decide(() => _api.rejectScan(widget.scan.id, reason), 'Rejected. The farmer has been told why.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scan;
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Review AI Scan', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScanPhoto(imageUrl: s.imageUrl),
          const SizedBox(height: 12),
          Text([s.animalName, s.farmerDisplayName].whereType<String>().join(' • '), style: AppTypography.cardTitle),
          Text('Scanned ${_when(s.createdAt)}', style: AppTypography.captionMetadata),
          const SizedBox(height: 16),
          Text('AI reading', style: AppTypography.sectionHeading),
          const SizedBox(height: 6),
          Text('${s.diagnosis ?? 'Unclear'} · ${((s.confidenceScore ?? 0) * 100).round()}% confidence · ${s.severity}',
              style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.w700)),
          for (final o in s.observations) Text('•  $o', style: AppTypography.bodyDefault),
          const SizedBox(height: 16),
          TextField(
            controller: _diagnosis,
            decoration: const InputDecoration(
              labelText: 'Correct diagnosis (optional)',
              hintText: 'Leave empty to confirm the AI diagnosis',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _advice,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Treatment advice for the farmer (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: AppTypography.bodyDefault.copyWith(color: AppColors.alertCritical)),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _busy ? null : _approve,
            icon: const Icon(Icons.verified_outlined),
            label: const Text('Approve'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _reject,
            icon: const Icon(Icons.block, color: AppColors.alertCritical),
            label: const Text('Reject', style: TextStyle(color: AppColors.alertCritical)),
          ),
        ],
      ),
    );
  }
}
