import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "../../../../core/design_system/app_colors.dart";
import "../../../../core/design_system/app_typography.dart";
import "../../data/models/mortality_dto.dart";
import "../providers/mortality_provider.dart";

class VetMortalityDetailPage extends StatefulWidget {
  final MortalityReportModel? report;
  final String? reportId;

  const VetMortalityDetailPage({super.key, this.report, this.reportId});

  @override
  State<VetMortalityDetailPage> createState() => _VetMortalityDetailPageState();
}

class _VetMortalityDetailPageState extends State<VetMortalityDetailPage> {
  late MortalityReportModel _currentReport;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      _currentReport = widget.report!;
      _initialized = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mortalityNotifier.loadDiseaseCatalog();
      final id = widget.report?.id ?? widget.reportId ?? mortalityNotifier.selectedCase?.id;
      if (id != null && id.isNotEmpty) {
        mortalityNotifier.loadAudits(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mortalityNotifier,
      builder: (context, _) {
        final selected = mortalityNotifier.selectedCase;
        if (selected != null && (!_initialized || selected.id == _currentReport.id)) {
          _currentReport = selected;
          _initialized = true;
        }

        if (!_initialized) {
          return Scaffold(
            backgroundColor: AppColors.surfaceBackground,
            appBar: AppBar(
              backgroundColor: AppColors.surfaceCard,
              title: const Text("Case Details"),
            ),
            body: const Center(child: Text("Mortality report not found.")),
          );
        }

        final report = _currentReport;
        final isPending = report.status == "REPORTED" || report.status == "FARMER_REPORTED";

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Text("Mortality Validation", style: AppTypography.screenTitle.copyWith(fontSize: 20)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusBanner(report),
              const SizedBox(height: 16),
              _buildAnimalCard(report),
              const SizedBox(height: 14),
              _buildFarmerReportCard(report),
              if (!isPending) ...[
                const SizedBox(height: 14),
                _buildVetReviewCard(report),
              ],
              const SizedBox(height: 14),
              _buildAuditTrailCard(),
              const SizedBox(height: 24),
              if (isPending) _buildActionButtons(report),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner(MortalityReportModel report) {
    Color bannerColor;
    IconData bannerIcon;
    String statusText;

    if (report.status == "VET_CONFIRMED" || report.status == "CONFIRMED") {
      bannerColor = Colors.green;
      bannerIcon = Icons.check_circle_outline;
      statusText = "Veterinarian Confirmed Death";
    } else if (report.status == "REJECTED") {
      bannerColor = AppColors.alertCritical;
      bannerIcon = Icons.cancel_outlined;
      statusText = "Mortality Report Rejected";
    } else {
      bannerColor = AppColors.cautionAmber;
      bannerIcon = Icons.pending_actions_outlined;
      statusText = "Pending Epidemiological Validation";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: bannerColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusText, style: AppTypography.cardTitle.copyWith(color: bannerColor, fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  "Report ID: ${report.id.substring(0, report.id.length > 8 ? 8 : report.id.length)}",
                  style: AppTypography.captionMetadata,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard(MortalityReportModel report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text("Animal Profile", style: AppTypography.sectionHeading.copyWith(fontSize: 16)),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow("Ear Tag Number", report.tagNumber.isNotEmpty ? report.tagNumber : "Unidentified"),
          if (report.animalName != null && report.animalName!.isNotEmpty)
            _buildInfoRow("Animal Name", report.animalName!),
          if (report.qrCodeId != null && report.qrCodeId!.isNotEmpty)
            _buildInfoRow("QR Code ID", report.qrCodeId!),
        ],
      ),
    );
  }

  Widget _buildFarmerReportCard(MortalityReportModel report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text("Farmer Incident Report", style: AppTypography.sectionHeading.copyWith(fontSize: 16)),
            ],
          ),
          const Divider(height: 20),
          if (report.farmerName != null) _buildInfoRow("Reporting Farmer", report.farmerName!),
          _buildInfoRow("Reported Cause", report.causeCategory.replaceAll("_", " ")),
          if (report.diseaseName != null && report.diseaseName!.isNotEmpty)
            _buildInfoRow("Farmer Suspected Disease", report.diseaseName!),
          if (report.causeDescription != null && report.causeDescription!.isNotEmpty)
            _buildInfoRow("Observation Description", report.causeDescription!),
          _buildInfoRow("Under Treatment", report.recentlyTreated ? "Yes" : "No"),
          if (report.treatmentNotes != null && report.treatmentNotes!.isNotEmpty)
            _buildInfoRow("Treatment Notes", report.treatmentNotes!),
          if (report.notes != null && report.notes!.isNotEmpty)
            _buildInfoRow("Additional Notes", report.notes!),
          if (report.latitude != null && report.longitude != null)
            _buildInfoRow(
              "GPS Location",
              "${report.latitude!.toStringAsFixed(4)}, ${report.longitude!.toStringAsFixed(4)} (±${report.locationAccuracy?.toStringAsFixed(0) ?? "?"}m)",
            ),
          _buildInfoRow("Reported Timestamp", _formatDate(report.reportedAt)),
        ],
      ),
    );
  }

  Widget _buildVetReviewCard(MortalityReportModel report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, size: 20, color: AppColors.vetAccent),
              const SizedBox(width: 8),
              Text("Veterinarian Review Finding", style: AppTypography.sectionHeading.copyWith(fontSize: 16)),
            ],
          ),
          const Divider(height: 20),
          if (report.vetReviewedByName != null)
            _buildInfoRow("Reviewing Doctor", report.vetReviewedByName!),
          if (report.vetReviewedAt != null)
            _buildInfoRow("Review Date", _formatDate(report.vetReviewedAt!)),
          if (report.vetCauseCategory != null)
            _buildInfoRow("Confirmed Cause Category", report.vetCauseCategory!.replaceAll("_", " ")),
          if (report.vetDiseaseName != null)
            _buildInfoRow("Confirmed Disease", report.vetDiseaseName!),
          _buildInfoRow("Post-Mortem Conducted", report.postMortemConducted ? "Yes" : "No"),
          if (report.vetClinicalNotes != null && report.vetClinicalNotes!.isNotEmpty)
            _buildInfoRow("Clinical / Necropsy Notes", report.vetClinicalNotes!),
          if (report.vetRejectionReason != null && report.vetRejectionReason!.isNotEmpty)
            _buildInfoRow("Rejection Rationale", report.vetRejectionReason!),
        ],
      ),
    );
  }

  Widget _buildAuditTrailCard() {
    final audits = mortalityNotifier.caseAudits;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text("Case Audit History", style: AppTypography.sectionHeading.copyWith(fontSize: 16)),
            ],
          ),
          const Divider(height: 20),
          if (audits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text("No prior audit events recorded for this case.", style: AppTypography.captionMetadata),
            )
          else
            Column(
              children: audits.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.circle, size: 8, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${a.action}: ${a.oldStatus} → ${a.newStatus}",
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(_formatDate(a.createdAt), style: AppTypography.captionMetadata.copyWith(fontSize: 11)),
                              ],
                            ),
                            if (a.veterinarianName != null)
                              Text("By: ${a.veterinarianName}", style: AppTypography.captionMetadata),
                            if (a.clinicalNotes != null && a.clinicalNotes!.isNotEmpty)
                              Text(a.clinicalNotes!, style: AppTypography.captionMetadata.copyWith(fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MortalityReportModel report) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text("Validate & Confirm Mortality", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: () => _showConfirmDialog(context, report),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.alertCritical,
              side: const BorderSide(color: AppColors.alertCritical, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text("Reject Case Report", style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _showRejectDialog(context, report),
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog(BuildContext parentContext, MortalityReportModel report) {
    String causeCategory = "KNOWN_DISEASE";
    String? selectedDisease = report.diseaseName;
    bool postMortem = false;
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final catalog = mortalityNotifier.diseaseCatalog;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Confirm Mortality", style: AppTypography.screenTitle.copyWith(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text("Verified Cause Category", style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: causeCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: "KNOWN_DISEASE", child: Text("Known Disease")),
                        DropdownMenuItem(value: "SUSPECTED_DISEASE", child: Text("Suspected Infectious Disease")),
                        DropdownMenuItem(value: "ACCIDENT_INJURY", child: Text("Accident / Injury")),
                        DropdownMenuItem(value: "POISONING", child: Text("Poisoning / Toxicity")),
                        DropdownMenuItem(value: "PREDATION", child: Text("Predation")),
                        DropdownMenuItem(value: "UNKNOWN", child: Text("Inconclusive / Unknown")),
                        DropdownMenuItem(value: "OTHER", child: Text("Other")),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheetState(() => causeCategory = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    Text("Confirmed Disease (Optional)", style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: (selectedDisease != null && catalog.contains(selectedDisease)) ? selectedDisease : null,
                      hint: const Text("Select confirmed pathogen / disease"),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: catalog.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (val) {
                        setSheetState(() => selectedDisease = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Post-Mortem / Necropsy Exam Conducted"),
                      value: postMortem,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setSheetState(() => postMortem = val ?? false),
                    ),
                    const SizedBox(height: 10),
                    Text("Veterinary Clinical Notes", style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Enter clinical observations, lesions, or laboratory findings...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          final messenger = ScaffoldMessenger.of(parentContext);
                          final dto = ConfirmMortalityDto(
                            causeCategory: causeCategory,
                            diseaseName: selectedDisease,
                            clinicalNotes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                            postMortemConducted: postMortem,
                          );
                          final ok = await mortalityNotifier.confirmCase(report.id, dto);
                          if (ok) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text("Mortality validated & confirmed!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            mortalityNotifier.loadAudits(report.id);
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(mortalityNotifier.errorMessage ?? "Failed to confirm"),
                                backgroundColor: AppColors.alertCritical,
                              ),
                            );
                          }
                        },
                        child: const Text("Confirm & Submit Validation", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRejectDialog(BuildContext parentContext, MortalityReportModel report) {
    final reasonController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Reject Mortality Report"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Specify why this mortality report is invalid or rejected:",
                style: AppTypography.captionMetadata,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: "Rejection Reason *",
                  hintText: "e.g. Animal confirmed alive, duplicate report",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Clinical Notes (Optional)",
                  hintText: "Additional practitioner comments",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCritical, foregroundColor: Colors.white),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text("Please provide a rejection reason."), backgroundColor: AppColors.alertCritical),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                final messenger = ScaffoldMessenger.of(parentContext);
                final dto = RejectMortalityDto(
                  rejectionReason: reason,
                  clinicalNotes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                );
                final ok = await mortalityNotifier.rejectCase(report.id, dto);
                if (ok) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text("Case report has been rejected."), backgroundColor: AppColors.alertCritical),
                  );
                  mortalityNotifier.loadAudits(report.id);
                } else {
                  messenger.showSnackBar(
                    SnackBar(content: Text(mortalityNotifier.errorMessage ?? "Failed to reject"), backgroundColor: AppColors.alertCritical),
                  );
                }
              },
              child: const Text("Confirm Rejection"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTypography.captionMetadata.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: AppTypography.bodySmall),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final date = "${dt.day.toString().padLeft(2, "0")}/${dt.month.toString().padLeft(2, "0")}/${dt.year}";
      final time = "${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}";
      return "$date $time";
    } catch (_) {
      return iso;
    }
  }
}
