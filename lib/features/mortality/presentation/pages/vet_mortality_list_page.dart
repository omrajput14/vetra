import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "../../../../core/design_system/app_colors.dart";
import "../../../../core/design_system/app_typography.dart";
import "../../data/models/mortality_dto.dart";
import "../providers/mortality_provider.dart";

class VetMortalityListPage extends StatefulWidget {
  const VetMortalityListPage({super.key});

  @override
  State<VetMortalityListPage> createState() => _VetMortalityListPageState();
}

class _VetMortalityListPageState extends State<VetMortalityListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mortalityNotifier.loadPendingCases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text("Mortality Case Reviews", style: AppTypography.screenTitle.copyWith(fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => mortalityNotifier.loadPendingCases(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: mortalityNotifier,
        builder: (context, _) {
          if (mortalityNotifier.isLoading && mortalityNotifier.pendingCases.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final cases = mortalityNotifier.pendingCases;

          if (cases.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => mortalityNotifier.loadPendingCases(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_outlined, size: 54, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text("No Pending Mortality Cases", style: AppTypography.sectionHeading),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "All farmer-reported animal deaths in your jurisdiction have been validated.",
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => mortalityNotifier.loadPendingCases(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cases.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pending Review (${cases.length})",
                          style: AppTypography.sectionHeading.copyWith(fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.cautionAmber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cautionAmber),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.cautionAmber),
                              const SizedBox(width: 4),
                              Text("Action Required", style: AppTypography.captionMetadata.copyWith(color: AppColors.cautionAmber, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final report = cases[index - 1];
                return _buildCaseCard(context, report);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, MortalityReportModel report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderHairline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            mortalityNotifier.setSelectedCase(report);
            context.push("/vet-mortality-detail", extra: report);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.pets, size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.tagNumber.isNotEmpty ? report.tagNumber : "No Tag",
                              style: AppTypography.cardTitle.copyWith(fontSize: 16),
                            ),
                            if (report.animalName != null && report.animalName!.isNotEmpty)
                              Text(report.animalName!, style: AppTypography.captionMetadata),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cautionAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cautionAmber),
                      ),
                      child: Text(
                        "PENDING",
                        style: AppTypography.captionMetadata.copyWith(
                          color: AppColors.cautionAmber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      report.farmerName != null ? "Farmer: ${report.farmerName}" : "Farmer Report",
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.coronavirus_outlined, size: 16, color: AppColors.alertCritical),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        report.diseaseName != null && report.diseaseName!.isNotEmpty
                            ? "Suspected: ${report.diseaseName}"
                            : "Cause: ${report.causeCategory.replaceAll("_", " ")}",
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (report.recentlyTreated) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.medical_services_outlined, size: 16, color: AppColors.vetAccent),
                      const SizedBox(width: 6),
                      Text("Recently Under Treatment", style: AppTypography.captionMetadata.copyWith(color: AppColors.vetAccent)),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(report.reportedAt),
                      style: AppTypography.captionMetadata,
                    ),
                    Row(
                      children: [
                        Text(
                          "Review Case",
                          style: AppTypography.buttonLabel.copyWith(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
