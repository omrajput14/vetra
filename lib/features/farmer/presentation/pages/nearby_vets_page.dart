import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/cards/vet_card.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/services/call_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NearbyVetsPage extends ConsumerStatefulWidget {
  const NearbyVetsPage({super.key});

  @override
  ConsumerState<NearbyVetsPage> createState() => _NearbyVetsPageState();
}

class _NearbyVetsPageState extends ConsumerState<NearbyVetsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authNotifier.fetchNearbyVets();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: authNotifier,
      builder: (context, _) {
        final vets = authNotifier.vetsList;

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Text(
              l10n?.nearbyVetsDirectory ?? 'Nearby Vets Directory',
              style: AppTypography.screenTitle,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                onPressed: () => authNotifier.fetchNearbyVets(),
              ),
              IconButton(
                icon: const Icon(Icons.map, color: AppColors.primary),
                onPressed: () => context.push('/outbreak-map'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => await authNotifier.fetchNearbyVets(),
            child: vets.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderHairline),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              size: 52,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n?.noVerifiedVets ?? 'No verified veterinarians available',
                              style: AppTypography.cardTitle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n?.noVerifiedVetsDesc ?? 'Please check again later.',
                              style: AppTypography.captionMetadata,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final v = vets[index];
                      final vetId = v['id']?.toString() ?? '';
                      final vetName = v['name']?.toString() ?? v['fullName']?.toString() ?? 'Dr. Veterinarian';
                      final spec = v['specialization']?.toString() ?? v['qualification']?.toString() ?? 'Veterinary Officer';
                      final clinic = v['clinic']?.toString() ?? v['clinicName']?.toString() ?? 'Clinical Practice';
                      final phoneNumber = v['phoneNumber']?.toString() ?? v['phone']?.toString();
                      final isEmergency = v['emergencyAvailable'] == true;
                      final rating = (v['rating'] is num) ? (v['rating'] as num).toDouble() : 5.0;
                      final isVerified = v['verified'] == true ||
                          v['verificationStatus'] == 'VERIFIED' ||
                          v['verificationStatus'] == null;

                      return VetCard(
                        name: vetName,
                        designation: '$spec • $clinic',
                        rating: rating,
                        phoneNumber: phoneNumber,
                        emergencyAvailable: isEmergency,
                        isVerified: isVerified,
                        onCallTap: () => CallService.instance.handleCall(
                          context,
                          phoneNumber,
                          l10n: l10n,
                        ),
                        onBookTap: () => context.push(
                          '/appointment-booking',
                          extra: {'vetId': vetId, 'vetName': vetName},
                        ),
                      );
                    },
                  ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_task, color: Colors.white),
            label: Text(
              l10n?.bookAppointment ?? 'Book Appointment',
              style: AppTypography.buttonLabel.copyWith(color: Colors.white),
            ),
            onPressed: () => context.push('/appointment-booking'),
          ),
          bottomNavigationBar: FarmerBottomNavigation(
            currentIndex: 3,
            onTap: (index) {
              if (index == 0) context.go('/farmer-dashboard');
              if (index == 1) context.go('/my-animals');
              if (index == 2) context.go('/alerts');
              if (index == 4) context.go('/profile');
            },
          ),
        );
      },
    );
  }
}
