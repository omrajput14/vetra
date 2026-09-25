import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_typography.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_exceptions.dart';
import '../../auth/presentation/providers/auth_provider.dart';

/// A vaccination drive (campaign) as a para-vet sees it.
class ParaVetDrive {
  final String id, campaignName, diseaseName, status;
  final int plannedDoses, administeredDoses;
  final String? startDate, targetDistrict;

  ParaVetDrive.fromJson(Map<String, dynamic> j)
      : id = j['id'].toString(),
        campaignName = j['campaignName']?.toString() ?? 'Vaccination drive',
        diseaseName = j['diseaseName']?.toString() ?? '',
        status = j['status']?.toString() ?? '',
        plannedDoses = (j['plannedDoses'] as num?)?.toInt() ?? 0,
        administeredDoses = (j['administeredDoses'] as num?)?.toInt() ?? 0,
        startDate = j['startDate']?.toString(),
        targetDistrict = j['targetDistrict']?.toString();
}

/// An animal inside a drive's area that still needs its dose.
class DriveAnimal {
  final String animalId;
  final String? animalName, tagNumber, species, farmerName, village;

  DriveAnimal.fromJson(Map<String, dynamic> j)
      : animalId = j['animalId'].toString(),
        animalName = j['animalName']?.toString(),
        tagNumber = j['tagNumber']?.toString(),
        species = j['species']?.toString(),
        farmerName = j['farmerName']?.toString(),
        village = j['village']?.toString();
}

/// Para-vet endpoints: profile/approval, drives, doses, sign-up.
class ParaVetApi {
  final Dio _dio = ApiClient.instance.dio;

  Future<T> _call<T>(Future<Response> Function() request, T Function(dynamic data) parse) async {
    try {
      final r = await request();
      return parse(r.data['data']);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Returns the approval status: PENDING, VERIFIED or REJECTED.
  Future<String> approvalStatus() =>
      _call(() => _dio.get('/api/v1/auth/paravet/me'), (d) => (d as Map)['verificationStatus'].toString());

  Future<List<ParaVetDrive>> drives() => _call(() => _dio.get('/api/v1/paravet/drives'),
      (d) => (d as List).map((e) => ParaVetDrive.fromJson(e as Map<String, dynamic>)).toList());

  Future<List<DriveAnimal>> animals(String driveId) => _call(() => _dio.get('/api/v1/paravet/drives/$driveId/animals'),
      (d) => (d as List).map((e) => DriveAnimal.fromJson(e as Map<String, dynamic>)).toList());

  /// Records one dose per animal; returns the drive's new total.
  Future<int> recordDoses(String driveId, List<String> animalIds) => _call(
      () => _dio.post('/api/v1/paravet/drives/$driveId/doses', data: {'animalIds': animalIds}),
      (d) => ((d as Map)['administeredDoses'] as num).toInt());

  Future<void> register(Map<String, dynamic> body) =>
      _call(() => _dio.post('/api/v1/auth/paravet/register', data: body), (_) {});
}

AppBar _bar(BuildContext context, String title, {bool back = true, List<Widget>? actions}) => AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(title, style: AppTypography.screenTitle),
      leading: back
          ? IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => context.pop())
          : null,
      actions: actions,
    );

/// Para-vet home: waiting-for-approval notice, or the two jobs (scans, vaccination drives).
class ParaVetHomePage extends StatefulWidget {
  final ParaVetApi? api;
  const ParaVetHomePage({super.key, this.api});

  @override
  State<ParaVetHomePage> createState() => _ParaVetHomePageState();
}

class _ParaVetHomePageState extends State<ParaVetHomePage> {
  late final ParaVetApi _api = widget.api ?? ParaVetApi();
  String? _status;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final s = await _api.approvalStatus();
      if (mounted) setState(() => _status = s);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Widget _tile(IconData icon, String title, String sub, String route) => Card(
        color: AppColors.surfaceCard,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Icon(icon, color: AppColors.primary, size: 32),
          title: Text(title, style: AppTypography.cardTitle),
          subtitle: Text(sub, style: AppTypography.captionMetadata),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(route),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final name = authNotifier.currentUser?.name ?? 'Para-vet';
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: _bar(context, 'Para-vet', back: false, actions: [
        IconButton(
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout, color: AppColors.textPrimary),
          onPressed: () {
            authNotifier.logout();
            context.go('/welcome');
          },
        ),
      ]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Welcome, $name', style: AppTypography.sectionHeading),
            const SizedBox(height: 16),
            if (_error != null) Text(_error!, style: AppTypography.bodyDefault.copyWith(color: AppColors.alertCritical)),
            if (_status == null && _error == null) const Center(child: CircularProgressIndicator()),
            if (_status != null && _status != 'VERIFIED')
              Card(
                color: AppColors.surfaceCard,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(_status == 'REJECTED' ? Icons.block : Icons.hourglass_top,
                          color: _status == 'REJECTED' ? AppColors.alertCritical : AppColors.primary),
                      const SizedBox(width: 8),
                      Text(_status == 'REJECTED' ? 'Not approved' : 'Waiting for approval',
                          style: AppTypography.cardTitle),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      _status == 'REJECTED'
                          ? 'The district office did not approve this account. Contact your district office.'
                          : 'The district office checks every new para-vet. You can start once they approve you; '
                              'you will get a notification.',
                      style: AppTypography.bodyDefault,
                    ),
                    TextButton(onPressed: _load, child: const Text('Check again')),
                  ]),
                ),
              ),
            if (_status == 'VERIFIED') ...[
              _tile(Icons.fact_check_outlined, 'Scans to check',
                  'Farmers\' AI scans in your district: send real cases to a vet, close the rest', '/paravet-scans'),
              const SizedBox(height: 8),
              _tile(Icons.vaccines_outlined, 'Vaccination drives',
                  'Drives near you: record each dose you give', '/paravet-drives'),
            ],
          ],
        ),
      ),
    );
  }
}

/// Open vaccination drives in the para-vet's area.
class ParaVetDrivesPage extends StatefulWidget {
  final ParaVetApi? api;
  const ParaVetDrivesPage({super.key, this.api});

  @override
  State<ParaVetDrivesPage> createState() => _ParaVetDrivesPageState();
}

class _ParaVetDrivesPageState extends State<ParaVetDrivesPage> {
  late final ParaVetApi _api = widget.api ?? ParaVetApi();
  late Future<List<ParaVetDrive>> _drives = _api.drives();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: _bar(context, 'Vaccination Drives'),
      body: FutureBuilder<List<ParaVetDrive>>(
        future: _drives,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString(), style: AppTypography.bodyDefault));
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final drives = snap.data!;
          if (drives.isEmpty) {
            return Center(child: Text('No vaccination drives near you right now.', style: AppTypography.captionMetadata));
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() => _drives = _api.drives()),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final d in drives)
                  Card(
                    color: AppColors.surfaceCard,
                    child: ListTile(
                      title: Text(d.campaignName, style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                      subtitle: Text(
                        '${d.diseaseName} • ${d.administeredDoses} of ${d.plannedDoses} doses given'
                        '${d.startDate != null ? ' • from ${d.startDate}' : ''}',
                        style: AppTypography.captionMetadata,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await context.push('/paravet-drive', extra: d);
                        if (mounted) setState(() => _drives = _api.drives());
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// One drive: tick the animals vaccinated today and record the doses.
class ParaVetDriveDetailPage extends StatefulWidget {
  final ParaVetDrive drive;
  final ParaVetApi? api;
  const ParaVetDriveDetailPage({super.key, required this.drive, this.api});

  @override
  State<ParaVetDriveDetailPage> createState() => _ParaVetDriveDetailPageState();
}

class _ParaVetDriveDetailPageState extends State<ParaVetDriveDetailPage> {
  late final ParaVetApi _api = widget.api ?? ParaVetApi();
  List<DriveAnimal>? _animals;
  final _picked = <String>{};
  late int _given = widget.drive.administeredDoses;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final a = await _api.animals(widget.drive.id);
      if (mounted) setState(() => _animals = a);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _record() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final total = await _api.recordDoses(widget.drive.id, _picked.toList());
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${_picked.length} dose(s) recorded. The district office sees them now.')));
      setState(() {
        _given = total;
        _animals = _animals!.where((a) => !_picked.contains(a.animalId)).toList();
        _picked.clear();
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.drive;
    final progress = d.plannedDoses == 0 ? 0.0 : (_given / d.plannedDoses).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: _bar(context, 'Record Doses'),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _busy || _picked.isEmpty ? null : _record,
            icon: const Icon(Icons.vaccines),
            label: Text('Record ${_picked.length} dose(s)'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(d.campaignName, style: AppTypography.cardTitle),
          const SizedBox(height: 4),
          Text('$_given of ${d.plannedDoses} doses given', style: AppTypography.captionMetadata),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text('Animals in the drive area that still need a dose', style: AppTypography.sectionHeading),
          if (_error != null) Text(_error!, style: AppTypography.bodyDefault.copyWith(color: AppColors.alertCritical)),
          if (_animals == null && _error == null)
            const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          if (_animals != null && _animals!.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text('Every animal in this area has had its dose.', style: AppTypography.captionMetadata),
            ),
          for (final a in _animals ?? const <DriveAnimal>[])
            CheckboxListTile(
              value: _picked.contains(a.animalId),
              onChanged: (v) => setState(() => v == true ? _picked.add(a.animalId) : _picked.remove(a.animalId)),
              title: Text('${a.animalName ?? 'Animal'} ${a.tagNumber != null ? '(${a.tagNumber})' : ''}'),
              subtitle: Text([a.species, a.farmerName, a.village].whereType<String>().join(' • ')),
            ),
        ],
      ),
    );
  }
}

/// Para-vet sign-up: account starts waiting for the district office's approval.
class ParaVetRegisterPage extends StatefulWidget {
  final ParaVetApi? api;
  const ParaVetRegisterPage({super.key, this.api});

  @override
  State<ParaVetRegisterPage> createState() => _ParaVetRegisterPageState();
}

class _ParaVetRegisterPageState extends State<ParaVetRegisterPage> {
  late final ParaVetApi _api = widget.api ?? ParaVetApi();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _district = TextEditingController();
  final _taluka = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _district, _taluka]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.length < 8 ||
        _district.text.trim().isEmpty) {
      setState(() => _error = 'Name, email, district and a password of at least 8 characters are needed.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _api.register({
        'fullName': _name.text.trim(),
        'email': _email.text.trim(),
        if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
        'password': _password.text,
        'district': _district.text.trim(),
        if (_taluka.text.trim().isNotEmpty) 'taluka': _taluka.text.trim(),
      });
      final ok = await authNotifier.loginVet(email: _email.text.trim(), password: _password.text);
      if (!mounted) return;
      if (ok) {
        context.go('/paravet-home');
      } else {
        setState(() => _error = authNotifier.errorMessage ?? 'Registered, but sign-in failed. Try signing in.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(TextEditingController c, String label, {bool obscure = false, TextInputType? type}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          obscureText: obscure,
          keyboardType: type,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: _bar(context, 'Para-vet Sign Up'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('The district office approves new para-vets before they can check scans or record doses.',
              style: AppTypography.captionMetadata),
          const SizedBox(height: 16),
          _field(_name, 'Full name'),
          _field(_email, 'Email', type: TextInputType.emailAddress),
          _field(_phone, 'Phone (optional)', type: TextInputType.phone),
          _field(_password, 'Password (at least 8 characters)', obscure: true),
          _field(_district, 'District (you will see scans from this district)'),
          _field(_taluka, 'Taluka (optional)'),
          if (_error != null) Text(_error!, style: AppTypography.bodyDefault.copyWith(color: AppColors.alertCritical)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _busy ? null : _submit, child: Text(_busy ? 'Creating account…' : 'Create account')),
        ],
      ),
    );
  }
}
