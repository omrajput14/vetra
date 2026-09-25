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

/// Vet's queue of AI scans that no vet has approved or rejected yet (escalated ones first).
/// With [paraVet], the para-vet's home: scans waiting for a field check.
class VetScanReviewListPage extends StatefulWidget {
  final AIScanApiService? api;
  final bool paraVet;
  const VetScanReviewListPage({super.key, this.api, this.paraVet = false});

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
        _queue.addAll(page.where((s) => widget.paraVet ? s.awaitingParaVet : s.awaitingVetReview));
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

  String _subtitle(AIScanModel s) {
    final escalated = s.isEscalated
        ? 'Escalated by ${s.paraVetDisplayName ?? 'a para-vet'}'
            '${s.triageNotes != null ? ': ${s.triageNotes}' : ''}'
        : null;
    return [escalated, s.animalName, s.farmerDisplayName, _when(s.createdAt)]
        .whereType<String>()
        .where((x) => x.isNotEmpty)
        .join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    // Vets see what para-vets escalated first.
    final ordered = [..._queue.where((s) => s.isEscalated), ..._queue.where((s) => !s.isEscalated)];
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.paraVet ? 'Scans to Check' : 'AI Scans to Review', style: AppTypography.screenTitle),
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
              widget.paraVet
                  ? 'Farmers\' AI scans in your area. Check the animal, then send real cases to a vet '
                      '(it is reported as a suspected case) or close the ones that are not a disease.'
                  : 'Farmers\' AI scans need a vet\'s decision. Scans escalated by para-vets come first. '
                      'Approving adds the diagnosis to the animal\'s record and reports a confirmed case '
                      'for outbreak monitoring.',
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
            for (final s in ordered)
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
                  subtitle: Text(_subtitle(s), style: AppTypography.captionMetadata),
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
  final bool paraVet;
  const _RejectReasonDialog({this.paraVet = false});

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
      title: Text(widget.paraVet ? 'Close this scan' : 'Reject AI result'),
      content: TextField(
        controller: _reason,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(
            hintText: widget.paraVet
                ? 'What did you find? The farmer will see this.'
                : 'Why is the AI result wrong? The farmer will see this.'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.pop(context, _reason.text.trim()),
            child: Text(widget.paraVet ? 'Close scan' : 'Reject')),
      ],
    );
  }
}

/// One scan: the farmer's photo and the AI's reading, with Approve / Reject.
class VetScanReviewDetailPage extends StatefulWidget {
  final AIScanModel scan;
  final AIScanApiService? api;
  final bool paraVet;
  const VetScanReviewDetailPage({super.key, required this.scan, this.api, this.paraVet = false});

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

  void _escalate() => _decide(
        () => _api.escalateScan(widget.scan.id, notes: _advice.text.trim()),
        'Sent to a vet. It is now reported as a suspected case.',
      );

  Future<void> _reject() async {
    final reason = await showDialog<String>(
        context: context, builder: (_) => _RejectReasonDialog(paraVet: widget.paraVet));
    if (reason != null && reason.isNotEmpty) {
      _decide(() => _api.rejectScan(widget.scan.id, reason),
          widget.paraVet ? 'Closed. The farmer has been told why.' : 'Rejected. The farmer has been told why.');
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
        title: Text(widget.paraVet ? 'Check AI Scan' : 'Review AI Scan', style: AppTypography.screenTitle),
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
          if (s.isEscalated) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Escalated by ${s.paraVetDisplayName ?? 'a para-vet'} after a field check'
                '${s.triageNotes != null ? ': ${s.triageNotes}' : '.'}',
                style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (widget.paraVet)
            TextField(
              controller: _advice,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What you saw at the farm (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          if (!widget.paraVet) ...[
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
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: AppTypography.bodyDefault.copyWith(color: AppColors.alertCritical)),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _busy ? null : (widget.paraVet ? _escalate : _approve),
            icon: Icon(widget.paraVet ? Icons.forward_to_inbox_outlined : Icons.verified_outlined),
            label: Text(widget.paraVet ? 'Send to vet' : 'Approve'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _reject,
            icon: const Icon(Icons.block, color: AppColors.alertCritical),
            label: Text(widget.paraVet ? 'Close: not a disease' : 'Reject',
                style: const TextStyle(color: AppColors.alertCritical)),
          ),
        ],
      ),
    );
  }
}
