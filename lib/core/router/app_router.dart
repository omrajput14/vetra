import '../../features/mortality/presentation/pages/report_mortality_page.dart';
import '../../features/mortality/presentation/pages/vet_mortality_list_page.dart';
import '../../features/mortality/presentation/pages/vet_mortality_detail_page.dart';
import '../../features/mortality/data/models/mortality_dto.dart';
import 'package:go_router/go_router.dart';
import '../../features/disease/data/models/outbreak_dto.dart';
import '../../core/models/notification.dart';

import '../../core/models/user_role.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/farmer_login_page.dart';
import '../../features/auth/presentation/pages/farmer_register_page.dart';
import '../../features/auth/presentation/pages/vet_login_page.dart';
import '../../features/auth/presentation/pages/vet_register_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_role_selection_page.dart';
import '../../features/auth/presentation/pages/register_vet_details_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/farmer/presentation/pages/farmer_dashboard_page.dart';
import '../../features/farmer/presentation/pages/farmer_appointments_page.dart';
import '../../features/farmer/presentation/pages/my_animals_page.dart';
import '../../features/farmer/presentation/pages/my_animals_offline_state_page.dart';
import '../../features/farmer/presentation/pages/nearby_vets_page.dart';
import '../../features/veterinarian/presentation/pages/vet_dashboard_page.dart';
import '../../features/veterinarian/presentation/pages/vet_requests_page.dart';
import '../../features/veterinarian/presentation/pages/consultation_history_page.dart';
import '../../features/veterinarian/presentation/pages/vet_verification_page.dart';
import '../../features/veterinarian/presentation/pages/vet_outbreak_map_page.dart';

import '../../features/animal/presentation/pages/add_animal_page.dart';
import '../../features/animal/presentation/pages/edit_animal_page.dart';
import '../../features/animal/presentation/pages/animal_passport_page.dart';
import '../../features/animal/presentation/pages/animal_passport_qr_updated_page.dart';
import '../../features/animal/data/models/animal_dto.dart';
import '../../features/animal/data/models/animal_health_record_dto.dart';
import '../../features/ai/data/models/ai_scan_model.dart';
import '../../features/veterinarian/presentation/pages/vet_scan_review_page.dart';
import '../../features/animal/presentation/pages/animal_passport_offline_state_page.dart';
import '../../features/animal/presentation/pages/animal_timeline_page.dart';
import '../../features/animal/presentation/pages/animal_gallery_page.dart';
import '../../features/animal/presentation/pages/animal_documents_page.dart';
import '../../features/animal/presentation/pages/breeding_record_page.dart';
import '../../features/animal/presentation/pages/delete_animal_confirmation_page.dart';
import '../../features/animal/presentation/pages/transfer_animal_ownership_page.dart';
import '../../features/medical/presentation/pages/add_prescription_page.dart';
import '../../features/medical/presentation/pages/add_treatment_page.dart';
import '../../features/medical/presentation/pages/deworming_record_page.dart';
import '../../features/medical/presentation/pages/medical_history_details_page.dart';
import '../../features/medical/presentation/pages/vaccination_details_page.dart';
import '../../features/medical/presentation/pages/vaccination_schedule_page.dart';
import '../../features/ai/presentation/pages/analyzing_scan_page.dart';
import '../../features/ai/presentation/pages/disease_scanner_page.dart';
import '../../features/ai/presentation/pages/scan_accuracy_comparison_page.dart';
import '../../features/ai/presentation/pages/scan_history_page.dart';
import '../../features/ai/presentation/pages/scan_results_page.dart';
import '../../features/ai/presentation/pages/ai_advisor_page.dart';
import '../../features/disease/presentation/pages/biosecurity_recommendations_page.dart';
import '../../features/disease/presentation/pages/disease_information_page.dart';
import '../../features/disease/presentation/pages/nearby_outbreak_details_page.dart';
import '../../features/disease/presentation/pages/report_disease_page.dart';
import '../../features/maps/presentation/pages/outbreak_map_page.dart';
import '../../features/maps/presentation/pages/risk_zone_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/vet_profile_page.dart';
import '../../features/profile/presentation/pages/shift_settings_page.dart';
import '../../features/veterinarian/presentation/pages/clinical_schedule_page.dart';
import '../../features/settings/presentation/pages/settings_overview_page.dart';
import '../../features/settings/presentation/pages/notification_preferences_page.dart';
import '../../features/settings/presentation/pages/language_settings_page.dart';
import '../../features/settings/presentation/pages/security_page.dart';
import '../../features/settings/presentation/pages/privacy_page.dart';
import '../../features/settings/presentation/pages/help_support_page.dart';
import '../../features/settings/presentation/pages/about_legal_page.dart';
import '../../features/shared/presentation/pages/alert_details_page.dart';
import '../../features/shared/presentation/pages/alerts_page.dart';
import '../../features/shared/presentation/pages/appointment_booking_page.dart';
import '../../features/shared/presentation/pages/appointment_details_page.dart';
import '../../features/shared/presentation/pages/filters_page.dart';
import '../../features/shared/presentation/pages/global_search_page.dart';
import '../../features/shared/presentation/pages/notification_details_page.dart';
import '../../features/shared/presentation/pages/notifications_page.dart';
import '../../features/shared/presentation/pages/qr_scanner_vet_page.dart';
import '../../features/shared/presentation/pages/search_results_page.dart';
import '../../features/shared/presentation/pages/sync_issues_page.dart';
import '../../features/appointment/presentation/pages/appointment_chat_page.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isLoggedIn = authNotifier.isLoggedIn;
      final role = authNotifier.currentRole;

      // Allow splash & onboarding
      if (loc == '/splash' || loc == '/onboarding') return null;

      final isAuthRoute = loc == '/welcome' ||
          loc == '/farmer-login' ||
          loc == '/farmer-register' ||
          loc == '/vet-login' ||
          loc == '/vet-register' ||
          loc == '/login' ||
          loc == '/register-role';

      if (!isLoggedIn) {
        if (!isAuthRoute && loc != '/forgot-password' &&loc != '/language-settings') {
          return '/welcome';
        }
        return null;
      }

      // If logged in and visiting auth page, redirect to active role dashboard
      if (isAuthRoute) {
        if (role == UserRole.veterinarian) return '/vet-dashboard';
        if (role == UserRole.paraVet) return '/paravet-home';
        return '/farmer-dashboard';
      }

      // Role Guards — allowlist approach.
      //
      // Each set names routes *exclusively* owned by one role.  A logged-in
      // user attempting to access the opposite role's exclusive route is
      // redirected to their own dashboard.  Routes in neither set are shared
      // (accessible to both roles) and do NOT need to appear here.
      //
      // IMPORTANT: add new role-specific routes to the appropriate set below
      // so they are protected automatically — do NOT add them to a denylist
      // elsewhere, which risks silent leakage when new routes are introduced.
      const farmerOnlyPrefixes = {
        '/farmer-dashboard',
        '/my-animals',
        '/my-animals-offline',
        '/add-animal',
        '/edit-animal',
        '/delete-animal-confirmation',
        '/delete-animal',
        '/transfer-animal-ownership',
        '/nearby-vets',
        '/farmer-appointments',
        '/report-mortality',
        '/breeding-record',
      };
      const vetOnlyPrefixes = {
        '/vet-dashboard',
        '/vet-requests',
        '/consultation-history',
        '/clinical-schedule',
        '/diagnosis-entry',
        '/vet-verification',
        '/vet-outbreak-map',
        '/vet-profile',
        '/shift-settings',
        '/vet-mortality-inbox',
        '/vet-mortality-detail',
        '/qr-scanner-vet',
        '/add-prescription',
        '/add-treatment',
        '/vet-scan-review',
        '/vet-scan-reviews',
      };

      bool matchesExclusive(Set<String> routes, String location) =>
          routes.any((r) => location == r || location.startsWith('$r/'));

      // Para-vets only triage scans; everything else sends them back to their queue.
      const paraVetAllowed = {'/paravet-home', '/vet-scan-review', '/notifications', '/language-settings'};
      if (role == UserRole.paraVet) {
        return paraVetAllowed.contains(loc) ? null : '/paravet-home';
      }

      if (role == UserRole.farmer) {
        if (matchesExclusive(vetOnlyPrefixes, loc)) {
          return '/farmer-dashboard';
        }
      } else if (role == UserRole.veterinarian) {
        if (matchesExclusive(farmerOnlyPrefixes, loc)) {
          return '/vet-dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/farmer-login',
        builder: (context, state) => const FarmerLoginPage(),
      ),
      GoRoute(
        path: '/farmer-register',
        builder: (context, state) => const FarmerRegisterPage(),
      ),
      GoRoute(
        path: '/vet-login',
        builder: (context, state) => const VetLoginPage(),
      ),
      GoRoute(
        path: '/vet-register',
        builder: (context, state) => const VetRegisterPage(),
      ),
      GoRoute(
        path: '/login',
        redirect: (context, state) => '/welcome',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register-role',
        redirect: (context, state) => '/welcome',
        builder: (context, state) => const RegisterRoleSelectionPage(),
      ),
      GoRoute(
        path: '/register-vet-details',
        builder: (context, state) => const RegisterVetDetailsPage(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/farmer-dashboard',
        builder: (context, state) => const FarmerDashboardPage(),
      ),
      GoRoute(
        path: '/my-animals',
        builder: (context, state) => const MyAnimalsPage(),
      ),
      GoRoute(
        path: '/my-animals-offline',
        builder: (context, state) => const MyAnimalsOfflineStatePage(),
      ),
      GoRoute(
        path: '/nearby-vets',
        builder: (context, state) => const NearbyVetsPage(),
      ),
      GoRoute(
        path: '/vet-dashboard',
        builder: (context, state) => const VetDashboardPage(),
      ),
      GoRoute(
        path: '/vet-requests',
        builder: (context, state) => const VetRequestsPage(),
      ),
      GoRoute(
        path: '/consultation-history',
        builder: (context, state) => const ConsultationHistoryPage(),
      ),
      GoRoute(
        path: '/clinical-schedule',
        builder: (context, state) => const ClinicalSchedulePage(),
      ),
      GoRoute(
        path: '/vet-verification',
        builder: (context, state) => const VetVerificationPage(),
      ),
      GoRoute(
        path: '/add-animal',
        builder: (context, state) => const AddAnimalPage(),
      ),
      GoRoute(
        path: '/edit-animal',
        builder: (context, state) => EditAnimalPage(animalId: state.extra?.toString() ?? ''),
      ),
      GoRoute(
        path: '/animal-passport',
        builder: (context, state) => AnimalPassportPage(animalId: state.extra?.toString() ?? ''),
      ),
      GoRoute(
        path: '/animal-passport-qr-updated',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is AnimalModel) {
            return AnimalPassportQrUpdatedPage(animal: extra);
          } else if (extra is String) {
            return AnimalPassportQrUpdatedPage(animalId: extra);
          }
          return const AnimalPassportQrUpdatedPage();
        },
      ),
      GoRoute(
        path: '/animal-passport-offline',
        builder: (context, state) => const AnimalPassportOfflineStatePage(),
      ),
      GoRoute(
        path: '/animal-timeline',
        builder: (context, state) => const AnimalTimelinePage(),
      ),
      GoRoute(
        path: '/animal-gallery',
        builder: (context, state) => const AnimalGalleryPage(),
      ),
      GoRoute(
        path: '/animal-documents',
        builder: (context, state) => const AnimalDocumentsPage(),
      ),
      GoRoute(
        path: '/breeding-record',
        builder: (context, state) => const BreedingRecordPage(),
      ),
      GoRoute(
        path: '/delete-animal-confirmation',
        builder: (context, state) => DeleteAnimalConfirmationPage(animalId: state.extra?.toString()),
      ),
      GoRoute(
        path: '/delete-animal',
        builder: (context, state) => DeleteAnimalConfirmationPage(animalId: state.extra?.toString()),
      ),
      GoRoute(
        path: '/transfer-animal-ownership',
        builder: (context, state) => const TransferAnimalOwnershipPage(),
      ),
      GoRoute(
        path: '/add-prescription',
        builder: (context, state) => AddPrescriptionPage(animalId: state.extra?.toString() ?? ''),
      ),
      GoRoute(
        path: '/add-treatment',
        builder: (context, state) => AddTreatmentPage(animalId: state.extra?.toString() ?? ''),
      ),
      GoRoute(
        path: '/deworming-record',
        builder: (context, state) => DewormingRecordPage(animalId: state.extra?.toString() ?? ''),
      ),
      GoRoute(
        path: '/diagnosis-entry',
        // Diagnoses are recorded against a completed visit (Create Medical Record →
        // POST /medical-records), so this opens the vet's completed visits.
        builder: (context, state) => const ClinicalSchedulePage(initialFilter: 'COMPLETED'),
      ),
      GoRoute(
        path: '/medical-history-details',
        builder: (context, state) => const MedicalHistoryDetailsPage(),
      ),
      GoRoute(
        path: '/vaccination-details',
        builder: (context, state) => VaccinationDetailsPage(
          record: state.extra is AnimalHealthRecordModel ? state.extra as AnimalHealthRecordModel : null,
        ),
      ),
      GoRoute(
        path: '/vaccination-schedule',
        builder: (context, state) => VaccinationSchedulePage(animalId: state.extra?.toString() ?? ''),
      ),
      GoRoute(
        path: '/analyzing-scan',
        builder: (context, state) => AnalyzingScanPage(extraArgs: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: '/scan-results',
        builder: (context, state) => ScanResultsPage(extraData: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: '/report-mortality',
        builder: (context, state) {
          final extra = state.extra;
          String? animalId;
          if (extra is String) {
            animalId = extra;
          } else if (extra is Map<String, dynamic>) {
            animalId = extra['animalId'] as String?;
          }
          return ReportMortalityPage(initialAnimalId: animalId);
        },
      ),
      GoRoute(
        path: '/vet-mortality-inbox',
        builder: (context, state) => const VetMortalityListPage(),
      ),
      GoRoute(
        path: '/vet-mortality-detail',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is MortalityReportModel) {
            return VetMortalityDetailPage(report: extra);
          } else if (extra is String) {
            return VetMortalityDetailPage(reportId: extra);
          }
          return const VetMortalityDetailPage();
        },
      ),
      GoRoute(
        path: '/disease-scanner',
        builder: (context, state) => const DiseaseScannerPage(),
      ),
      GoRoute(
        path: '/ai-advisor',
        builder: (context, state) {
          final extra = state.extra;
          String animalId = '';
          String? sessionId;
          if (extra is String) {
            animalId = extra;
          } else if (extra is Map<String, dynamic>) {
            animalId = extra['animalId'] as String? ?? '';
            sessionId = extra['sessionId'] as String?;
          }
          return AIAdvisorPage(animalId: animalId, sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/scan-accuracy-comparison',
        builder: (context, state) => const ScanAccuracyComparisonPage(),
      ),
      // Routes the backend puts in push payloads (NotificationEventListener).
      GoRoute(path: '/ai-history', redirect: (context, state) => '/scan-history'),
      GoRoute(
        path: '/outbreaks',
        redirect: (context, state) =>
            authNotifier.currentRole == UserRole.veterinarian ? '/vet-outbreak-map' : '/outbreak-map',
      ),
      GoRoute(
        path: '/vet-scan-reviews',
        builder: (context, state) => const VetScanReviewListPage(),
      ),
      GoRoute(
        path: '/vet-scan-review',
        builder: (context, state) => state.extra is AIScanModel
            ? VetScanReviewDetailPage(
                scan: state.extra as AIScanModel,
                paraVet: authNotifier.currentRole == UserRole.paraVet)
            : const VetScanReviewListPage(),
      ),
      GoRoute(
        path: '/paravet-home',
        builder: (context, state) => const VetScanReviewListPage(paraVet: true),
      ),
      GoRoute(
        path: '/scan-history',
        builder: (context, state) => const ScanHistoryPage(),
      ),
      GoRoute(
        path: '/biosecurity-recommendations',
        builder: (context, state) => const BiosecurityRecommendationsPage(),
      ),
      GoRoute(
        path: '/disease-information',
        builder: (context, state) => const DiseaseInformationPage(),
      ),
      GoRoute(
        path: '/nearby-outbreak-details',
        builder: (context, state) {
          final outbreak = state.extra is OutbreakModel ? state.extra as OutbreakModel : null;
          return NearbyOutbreakDetailsPage(outbreak: outbreak);
        },
      ),
      GoRoute(
        path: '/report-disease',
        builder: (context, state) {
          final animalId = state.extra is String
              ? state.extra as String
              : state.uri.queryParameters['animalId'];
          return ReportDiseasePage(initialAnimalId: animalId);
        },
      ),
      GoRoute(
        path: '/vet-outbreak-map',
        builder: (context, state) => const VetOutbreakMapPage(),
      ),
      GoRoute(
        path: '/outbreak-map',
        builder: (context, state) => const OutbreakMapPage(),
      ),
      GoRoute(
        path: '/risk-zone',
        builder: (context, state) {
          final outbreak = state.extra is OutbreakModel ? state.extra as OutbreakModel : null;
          return RiskZonePage(initialOutbreak: outbreak);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/vet-profile',
        builder: (context, state) => const VetProfilePage(),
      ),
      GoRoute(
        path: '/shift-settings',
        builder: (context, state) => const ShiftSettingsPage(),
      ),
      GoRoute(
        path: '/settings-overview',
        builder: (context, state) => const SettingsOverviewPage(),
      ),
      GoRoute(
        path: '/notification-preferences',
        builder: (context, state) => const NotificationPreferencesPage(),
      ),
      GoRoute(
        path: '/language-settings',
        builder: (context, state) => const LanguageSettingsPage(),
      ),
      GoRoute(
        path: '/security-settings',
        builder: (context, state) => const SecurityPage(),
      ),
      GoRoute(
        path: '/privacy-settings',
        builder: (context, state) => const PrivacyPage(),
      ),
      GoRoute(
        path: '/help-support',
        builder: (context, state) => const HelpSupportPage(),
      ),
      GoRoute(
        path: '/about-legal',
        builder: (context, state) => const AboutLegalPage(),
      ),
      GoRoute(
        path: '/alert-details',
        builder: (context, state) => AlertDetailsPage(
          outbreak: state.extra is OutbreakModel ? state.extra as OutbreakModel : null,
        ),
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const AlertsPage(),
      ),
      GoRoute(
        path: '/farmer-appointments',
        builder: (context, state) => const FarmerAppointmentsPage(),
      ),
      GoRoute(
        path: '/appointment-booking',
        builder: (context, state) => AppointmentBookingPage(extraData: state.extra),
      ),
      GoRoute(
        path: '/appointment-details',
        builder: (context, state) => AppointmentDetailsPage(
          appointmentId: state.extra?.toString() ?? state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: '/appointment-chat',
        builder: (context, state) {
          final id = state.extra?.toString() ?? state.uri.queryParameters['id'] ?? '';
          return AppointmentChatPage(appointmentId: id);
        },
      ),
      GoRoute(
        path: '/filters',
        builder: (context, state) => const FiltersPage(),
      ),
      GoRoute(
        path: '/global-search',
        builder: (context, state) => const GlobalSearchPage(),
      ),
      GoRoute(
        path: '/notification-details',
        builder: (context, state) => NotificationDetailsPage(
          notification: state.extra is AppNotification ? state.extra as AppNotification : null,
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/qr-scanner-vet',
        builder: (context, state) => const QrScannerVetPage(),
      ),
      GoRoute(
        path: '/sync-issues',
        builder: (context, state) => const SyncIssuesPage(),
      ),
      GoRoute(
        path: '/search-results',
        builder: (context, state) => SearchResultsPage(query: state.extra is String ? state.extra as String : ''),
      ),
      GoRoute(
        path: '/admin-dashboard',
        redirect: (context, state) => '/welcome',
      ),
      GoRoute(
        path: '/user-management',
        redirect: (context, state) => '/welcome',
      ),
      GoRoute(
        path: '/admin-analytics',
        redirect: (context, state) => '/welcome',
      ),
      GoRoute(
        path: '/broadcast-notifications',
        redirect: (context, state) => '/welcome',
      ),
      GoRoute(
        path: '/ai-monitoring',
        redirect: (context, state) => '/welcome',
      ),
    ],
  );
}
