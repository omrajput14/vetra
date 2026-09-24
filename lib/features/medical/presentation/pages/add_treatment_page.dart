import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../animal/presentation/providers/animal_provider.dart';

/// Saves a TREATMENT record on the animal's passport. The server records the
/// signed-in vet as the attending vet.
class AddTreatmentPage extends StatefulWidget {
  final String animalId;
  const AddTreatmentPage({super.key, this.animalId = ''});

  @override
  State<AddTreatmentPage> createState() => _AddTreatmentPageState();
}

class _AddTreatmentPageState extends State<AddTreatmentPage> {
  final _description = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final description = _description.text.trim();
    if (description.isEmpty) {
      setState(() => _error = 'Describe the treatment given.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final saved = await animalNotifier.addHealthRecord(widget.animalId, {
      'recordType': 'TREATMENT',
      'title': 'Treatment',
      'treatment': description,
    });
    if (!mounted) return;
    if (!saved) {
      setState(() {
        _saving = false;
        _error = animalNotifier.errorMessage ?? 'Could not save the treatment.';
      });
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Treatment saved to the animal\'s passport.')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Record Treatment', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: widget.animalId.isEmpty
          ? Center(child: Text('Open this from an animal\'s passport.', style: AppTypography.captionMetadata))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppTextField(
                  labelText: 'Treatment Description',
                  hintText: 'e.g. Wound dressing and antiseptic injection',
                  controller: _description,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: AppTypography.bodyDefault.copyWith(color: AppColors.alertCritical)),
                ],
                const SizedBox(height: 24),
                PrimaryButton(label: 'Submit Record', isLoading: _saving, onPressed: _saving ? null : _save),
              ],
            ),
    );
  }
}
