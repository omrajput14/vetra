import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../animal/data/models/animal_dto.dart';
import '../../../animal/presentation/providers/animal_provider.dart';
import '../../data/models/disease_report_dto.dart';
import '../providers/disease_report_provider.dart';

class ReportDiseasePage extends ConsumerStatefulWidget {
  final String? initialAnimalId;

  const ReportDiseasePage({super.key, this.initialAnimalId});

  @override
  ConsumerState<ReportDiseasePage> createState() => _ReportDiseasePageState();
}

class _ReportDiseasePageState extends ConsumerState<ReportDiseasePage> {
  final TextEditingController _notesController = TextEditingController();
  String? _selectedAnimalId;
  String _selectedCondition = 'General Suspected Illness';
  final Set<String> _selectedSymptoms = {};
  bool _submittedSuccess = false;
  DiseaseReportModel? _submittedReport;

  static const List<Map<String, String>> _commonConditions = [
    {'en': 'General Suspected Illness', 'mr': 'सामान्य संशयित आजार', 'hi': 'सामान्य संदिग्ध बीमारी'},
    {'en': 'Foot and Mouth Disease (FMD)', 'mr': 'लाळ्या खुरकूत (FMD)', 'hi': 'खुरपका-मुंहपका रोग (FMD)'},
    {'en': 'Lumpy Skin Disease (LSD)', 'mr': 'लम्पी त्वचा रोग (LSD)', 'hi': 'लम्पी स्किन डिजीज (LSD)'},
    {'en': 'Bovine Respiratory Disease (BRD)', 'mr': 'श्वसन विकार (BRD)', 'hi': 'श्वसन रोग (BRD)'},
    {'en': 'Black Quarter (BQ)', 'mr': 'फाशी / एकटांग्या (BQ)', 'hi': 'लंगड़ा बुखार (BQ)'},
    {'en': 'Haemorrhagic Septicaemia (HS)', 'mr': 'घटसर्प (HS)', 'hi': 'गलघोंटू (HS)'},
    {'en': 'Anthrax', 'mr': 'सुरा / अँथ्रॅक्स', 'hi': 'एंथ्रेक्स'},
    {'en': 'Other / Unspecified Health Issue', 'mr': 'इतर आरोग्य समस्या', 'hi': 'अन्य स्वास्थ्य समस्या'},
  ];

  static const List<Map<String, dynamic>> _symptomOptions = [
    {'id': 'High Fever', 'icon': '🌡️', 'en': 'High Fever', 'mr': 'तीव्र ताप', 'hi': 'तेज़ बुखार'},
    {'id': 'Reduced Appetite', 'icon': '🍽️', 'en': 'Off-feed / Low Appetite', 'mr': 'चारा न खाणे', 'hi': 'कम भूख / चारा न खाना'},
    {'id': 'Excess Salivation', 'icon': '💧', 'en': 'Excess Salivation', 'mr': 'तोंडातून लाळ गळणे', 'hi': 'मुंह से लार टपकना'},
    {'id': 'Lameness', 'icon': '🦿', 'en': 'Lameness / Limping', 'mr': 'लंगडणे / चालण्यास त्रास', 'hi': 'लंगड़ापन'},
    {'id': 'Nasal Discharge', 'icon': '🤧', 'en': 'Nasal Discharge / Cough', 'mr': 'नाक वाहणे / खोकला', 'hi': 'नाक बहना / खांसी'},
    {'id': 'Drop in Milk Production', 'icon': '🥛', 'en': 'Drop in Milk Yield', 'mr': 'दूध उत्पादनात घट', 'hi': 'दूध में अचानक कमी'},
    {'id': 'Mouth or Foot Lesions', 'icon': '🫧', 'en': 'Mouth / Foot Lesions', 'mr': 'तोंडात / खुरात फोड', 'hi': 'मुंह या खुर में छाले'},
    {'id': 'Diarrhea', 'icon': '💩', 'en': 'Diarrhea', 'mr': 'हगवण / जुलाब', 'hi': 'दस्त / दस्त लगना'},
    {'id': 'Body Swelling', 'icon': '🔍', 'en': 'Lumps / Body Swelling', 'mr': 'अंगावर गाठी / सूज', 'hi': 'शरीर में सूजन / गांठ'},
    {'id': 'Rapid Breathing', 'icon': '🫁', 'en': 'Heavy / Rapid Breathing', 'mr': 'धाप लागणे / धापा', 'hi': 'सांस लेने में कठिनाई'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedAnimalId = widget.initialAnimalId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure animals are loaded
      if (animalNotifier.animals.isEmpty) {
        await animalNotifier.loadAnimals();
      }

      if (_selectedAnimalId == null && animalNotifier.animals.isNotEmpty) {
        setState(() {
          _selectedAnimalId = animalNotifier.selectedAnimalId ?? animalNotifier.animals.first.id;
        });
      }

      // Fetch real GPS location for surveillance if not already set
      if (diseaseReportNotifier.currentLocation == null) {
        diseaseReportNotifier.fetchCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _getConditionLabel(Map<String, String> cond, String lang) {
    return cond[lang] ?? cond['en'] ?? '';
  }

  String _getSymptomLabel(Map<String, dynamic> sym, String lang) {
    return sym[lang] ?? sym['en'] ?? '';
  }

  Future<void> _handleSubmitReport() async {
    final activeLocale = ref.read(localeProvider);
    final lang = activeLocale.languageCode;

    if (_selectedAnimalId == null || _selectedAnimalId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'mr'
                ? 'कृपया नोंदीतील प्राणी निवडा'
                : (lang == 'hi' ? 'कृपया एक पंजीकृत पशु चुनें' : 'Please select a registered animal'),
          ),
          backgroundColor: AppColors.alertCritical,
        ),
      );
      return;
    }

    if (_selectedSymptoms.isEmpty && _notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'mr'
                ? 'कृपया लक्षणे निवडा किंवा निरीक्षणे लिहा'
                : (lang == 'hi' ? 'कृपया लक्षण चुनें या विवरण लिखें' : 'Please select observed symptoms or enter notes'),
          ),
          backgroundColor: AppColors.alertCritical,
        ),
      );
      return;
    }

    // Require GPS Coordinates
    final location = diseaseReportNotifier.currentLocation;
    if (location == null) {
      final fetched = await diseaseReportNotifier.fetchCurrentLocation();
      if (fetched == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'mr'
                  ? 'रोग सर्वेक्षणासाठी जीपीएस लोकेशन आवश्यक आहे. कृपया लोकेशन सुरू करा.'
                  : (lang == 'hi'
                      ? 'रोग निगरानी के लिए जीपीएस स्थान आवश्यक है। कृपया स्थान चालू करें।'
                      : 'GPS location is required for epidemiological surveillance reporting. Please enable location.'),
            ),
            backgroundColor: AppColors.alertCritical,
          ),
        );
        return;
      }
    }

    final effectiveLocation = diseaseReportNotifier.currentLocation!;

    final success = await diseaseReportNotifier.submitDiseaseReport(
      animalId: _selectedAnimalId!,
      diseaseName: _selectedCondition,
      latitude: effectiveLocation.latitude,
      longitude: effectiveLocation.longitude,
      symptoms: _selectedSymptoms.toList(),
      notes: _notesController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _submittedSuccess = true;
        _submittedReport = diseaseReportNotifier.lastCreatedReport;
      });
    } else if (mounted && diseaseReportNotifier.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(diseaseReportNotifier.errorMessage!),
          backgroundColor: AppColors.alertCritical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeLocale = ref.watch(localeProvider);
    final lang = activeLocale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang == 'mr'
                  ? 'रोग लक्षण नोंदवा'
                  : (lang == 'hi' ? 'रोग रिपोर्ट दर्ज करें' : 'Report Health Issue'),
              style: AppTypography.screenTitle.copyWith(fontSize: 18),
            ),
            Text(
              lang == 'mr'
                  ? 'साथीचे रोग नियंत्रण व सर्वेक्षण'
                  : (lang == 'hi' ? 'रोग निगरानी एवं प्रकोप नियंत्रण' : 'Disease Surveillance & Outbreak Detection'),
              style: AppTypography.captionMetadata.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([animalNotifier, diseaseReportNotifier]),
        builder: (context, _) {
          if (_submittedSuccess && _submittedReport != null) {
            return _buildSuccessState(lang, _submittedReport!);
          }

          final animals = animalNotifier.animals;
          final isSubmitting = diseaseReportNotifier.isSubmitting;
          final isFetchingLoc = diseaseReportNotifier.isFetchingLocation;
          final currentLocation = diseaseReportNotifier.currentLocation;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Surveillance Header Banner
              _buildSurveillanceNotice(lang),
              const SizedBox(height: 16),

              // 2. Animal Selection
              _buildSectionTitle(
                lang == 'mr'
                    ? '१. बाधित प्राणी निवडा'
                    : (lang == 'hi' ? '१. प्रभावित पशु चुनें' : '1. Select Affected Animal'),
              ),
              const SizedBox(height: 8),
              if (animals.isEmpty)
                _buildNoAnimalsCard(lang)
              else
                _buildAnimalDropdown(animals, lang),
              const SizedBox(height: 20),

              // 3. Selectable Symptoms
              _buildSectionTitle(
                lang == 'mr'
                    ? '२. दिसून आलेली लक्षणे'
                    : (lang == 'hi' ? '२. देखे गए लक्षण' : '2. Observed Symptoms'),
              ),
              const SizedBox(height: 4),
              Text(
                lang == 'mr'
                    ? 'लागू असणारी सर्व लक्षणे निवडा:'
                    : (lang == 'hi' ? 'सभी लागू लक्षण चुनें:' : 'Select all symptoms observed on the animal:'),
                style: AppTypography.captionMetadata,
              ),
              const SizedBox(height: 10),
              _buildSymptomChips(lang),
              const SizedBox(height: 20),

              // 4. Suspected Condition
              _buildSectionTitle(
                lang == 'mr'
                    ? '३. संशयित आजार (प्राथमिक)'
                    : (lang == 'hi' ? '३. संदिग्ध रोग (प्रारंभिक)' : '3. Suspected Condition'),
              ),
              const SizedBox(height: 4),
              Text(
                lang == 'mr'
                    ? 'शेतकरी नोंदणी प्राथमिक संशयित स्वरूपाची असते. अधिकृत खात्री पशुवैद्यकीय डॉक्टर करतील.'
                    : (lang == 'hi'
                        ? 'यह एक प्रारंभिक संदिग्ध रिपोर्ट है। आधिकारिक पुष्टि पशु चिकित्सक द्वारा की जाती है।'
                        : 'Preliminary field suspicion. Official clinical confirmation is rendered by a licensed veterinarian.'),
                style: AppTypography.captionMetadata.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              _buildConditionDropdown(lang),
              const SizedBox(height: 20),

              // 5. Notes / Description
              _buildSectionTitle(
                lang == 'mr'
                    ? '४. अधिक माहिती / निरीक्षणे (पर्यायी)'
                    : (lang == 'hi' ? '४. अतिरिक्त विवरण / अवलोकन (वैकल्पिक)' : '4. Additional Observations / Notes'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: lang == 'mr'
                      ? 'उदा. २ दिवसांपासून लक्षणे, चारा बदल, शेजारील प्राण्यांची स्थिती...'
                      : (lang == 'hi'
                          ? 'उदा. 2 दिनों से लक्षण, आहार में बदलाव, आस-पास के पशुओं की स्थिति...'
                          : 'e.g. Symptoms started 2 days ago, recent feed change, neighboring herd status...'),
                  hintStyle: AppTypography.captionMetadata,
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderHairline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderHairline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),

              // 6. GPS Location Card
              _buildSectionTitle(
                lang == 'mr'
                    ? '५. जीपीएस स्थान (साथरोग सर्वेक्षण)'
                    : (lang == 'hi' ? '५. जीपीएस स्थान (रोग निगरानी)' : '5. Surveillance GPS Location'),
              ),
              const SizedBox(height: 8),
              _buildGpsCard(lang, currentLocation, isFetchingLoc),
              const SizedBox(height: 24),

              // 7. Submit Button
              PrimaryButton(
                label: isSubmitting
                    ? (lang == 'mr'
                        ? 'माहिती पाठवत आहे...'
                        : (lang == 'hi' ? 'रिपोर्ट सबमिट हो रही है...' : 'Transmitting Report...'))
                    : (lang == 'mr'
                        ? 'रोग अहवाल सबमिट करा'
                        : (lang == 'hi' ? 'रोग रिपोर्ट सबमिट करें' : 'Submit Disease Report')),
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : _handleSubmitReport,
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.cardTitle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSurveillanceNotice(String lang) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'mr'
                      ? 'जलद साथीचे रोग नियंत्रण'
                      : (lang == 'hi' ? 'त्वरित रोग निगरानी एवं चेतावनी' : 'Rapid Disease Surveillance & Early Warning'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Text(
                  lang == 'mr'
                      ? 'तुमचा अहवाल थेट VETRA च्या साथरोग नियंत्रण यंत्रणेला पाठवला जातो, ज्यामुळे परिसरातील संभाव्य प्रादुर्भाव रोखण्यास मदत होते.'
                      : (lang == 'hi'
                          ? 'आपकी रिपोर्ट सीधे VETRA आउटब्रेक डिटेक्शन इंजन को भेजी जाती है जिससे समय रहते बीमारी का फैलाव रोका जा सके।'
                          : 'Your report is directly analyzed by the VETRA Outbreak Detection Engine to identify potential livestock-health risks early.'),
                  style: AppTypography.captionMetadata.copyWith(fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalDropdown(List<AnimalModel> animals, String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAnimalId != null && animals.any((a) => a.id == _selectedAnimalId)
              ? _selectedAnimalId
              : (animals.isNotEmpty ? animals.first.id : null),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
          items: animals.map((a) {
            return DropdownMenuItem<String>(
              value: a.id,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.pets, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${a.animalName} (${a.tagNumber})',
                          style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${a.species.toUpperCase()} • ${a.breed}',
                          style: AppTypography.captionMetadata.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedAnimalId = val;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildNoAnimalsCard(String lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cautionAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cautionAmber.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.cautionAmber, size: 28),
          const SizedBox(height: 6),
          Text(
            lang == 'mr'
                ? 'नोंदणीकृत प्राणी सापडले नाहीत'
                : (lang == 'hi' ? 'कोई पंजीकृत पशु नहीं मिला' : 'No registered animals found'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            lang == 'mr'
                ? 'रोग अहवाल देण्यासाठी प्रथम प्राणी नोंदवा.'
                : (lang == 'hi' ? 'रिपोर्ट दर्ज करने से पहले पशु जोड़ें।' : 'Please register an animal before filing a report.'),
            style: AppTypography.captionMetadata,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomChips(String lang) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _symptomOptions.map((sym) {
        final id = sym['id'] as String;
        final icon = sym['icon'] as String;
        final label = _getSymptomLabel(sym, lang);
        final isSelected = _selectedSymptoms.contains(id);

        return FilterChip(
          label: Text('$icon $label'),
          selected: isSelected,
          selectedColor: AppColors.alertCritical.withValues(alpha: 0.15),
          checkmarkColor: AppColors.alertCritical,
          backgroundColor: AppColors.surfaceCard,
          side: BorderSide(
            color: isSelected ? AppColors.alertCritical : AppColors.borderHairline,
            width: isSelected ? 1.5 : 1.0,
          ),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.alertCritical : AppColors.textPrimary,
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedSymptoms.add(id);
              } else {
                _selectedSymptoms.remove(id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildConditionDropdown(String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCondition,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
          items: _commonConditions.map((cond) {
            final enValue = cond['en']!;
            final displayLabel = _getConditionLabel(cond, lang);
            return DropdownMenuItem<String>(
              value: enValue,
              child: Text(
                displayLabel,
                style: AppTypography.bodyDefault.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedCondition = val;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildGpsCard(String lang, dynamic currentLocation, bool isFetchingLoc) {
    final hasLoc = currentLocation != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasLoc
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.alertCritical.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasLoc
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.alertCritical.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasLoc ? Icons.location_on : Icons.location_off,
            color: hasLoc ? AppColors.primary : AppColors.alertCritical,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasLoc
                      ? (lang == 'mr'
                          ? 'जीपीएस स्थान प्राप्त झाले'
                          : (lang == 'hi' ? 'जीपीएस स्थान प्राप्त हुआ' : 'GPS Location Captured'))
                      : (lang == 'mr'
                          ? 'जीपीएस स्थान आवश्यक आहे'
                          : (lang == 'hi' ? 'जीपीएस स्थान आवश्यक है' : 'GPS Location Required')),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: hasLoc ? AppColors.primary : AppColors.alertCritical,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasLoc
                      ? '${currentLocation.latitude.toStringAsFixed(4)}° N, ${currentLocation.longitude.toStringAsFixed(4)}° E'
                      : (lang == 'mr'
                          ? 'प्रादुर्भाव नकाशा विश्लेषणासाठी जीपीएस सुरू करा'
                          : (lang == 'hi'
                              ? 'प्रकोप विश्लेषण हेतु जीपीएस चालू करें'
                              : 'Enable GPS for surveillance mapping')),
                  style: AppTypography.captionMetadata.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          if (isFetchingLoc)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
              tooltip: 'Refresh GPS',
              onPressed: () => diseaseReportNotifier.fetchCurrentLocation(),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(String lang, DiseaseReportModel report) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                lang == 'mr'
                    ? 'रोग अहवाल यशस्वीरित्या नोंदवला!'
                    : (lang == 'hi' ? 'रोग रिपोर्ट सफलतापूर्वक दर्ज!' : 'Disease Report Submitted Successfully!'),
                textAlign: TextAlign.center,
                style: AppTypography.cardTitle.copyWith(fontSize: 18, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                lang == 'mr'
                    ? 'अहवाल सुरक्षित जतन केला आहे. नेटवर्क उपलब्ध होताच साथरोग नियंत्रण प्रणालीत आपोआप सिंक होईल.'
                    : (lang == 'hi'
                        ? 'रिपोर्ट सुरक्षित सहेज ली गई है। इंटरनेट उपलब्ध होते ही यह VETRA सर्विलांस इंजन में स्वतः सिंक हो जाएगी।'
                        : 'Report saved securely. It will automatically synchronize with the VETRA Outbreak Detection Engine once connected.'),
                textAlign: TextAlign.center,
                style: AppTypography.captionMetadata.copyWith(fontSize: 12),
              ),
              const Divider(height: 28),
              _buildReportDetailRow(
                lang == 'mr' ? 'अहवाल क्रमांक' : (lang == 'hi' ? 'रिपोर्ट आईडी' : 'Report ID'),
                report.id.length > 8 ? report.id.substring(0, 8).toUpperCase() : report.id,
              ),
              const SizedBox(height: 6),
              _buildReportDetailRow(
                lang == 'mr' ? 'प्राणी' : (lang == 'hi' ? 'पशु' : 'Animal'),
                '${report.animalName ?? "Animal"} (${report.tagNumber ?? ""})',
              ),
              const SizedBox(height: 6),
              _buildReportDetailRow(
                lang == 'mr' ? 'स्थिती' : (lang == 'hi' ? 'स्थिति' : 'Status'),
                report.diagnosisStatus,
                isBadge: true,
              ),
              const SizedBox(height: 6),
              _buildReportDetailRow(
                lang == 'mr' ? 'स्थान' : (lang == 'hi' ? 'स्थान' : 'Location'),
                '${report.latitude.toStringAsFixed(4)}° N, ${report.longitude.toStringAsFixed(4)}° E',
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: lang == 'mr' ? 'पूर्ण / डॅशबोर्डकडे जा' : (lang == 'hi' ? 'संपन्न / डैशबोर्ड' : 'Done / Return to Dashboard'),
                onPressed: () {
                  diseaseReportNotifier.clearLastReport();
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportDetailRow(String label, String value, {bool isBadge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.captionMetadata.copyWith(fontWeight: FontWeight.w600)),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.cautionAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.cautionAmber.withValues(alpha: 0.5)),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.cautionAmber,
              ),
            ),
          )
        else
          Text(value, style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
