import 'package:go_router/go_router.dart';
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
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/farmer/presentation/pages/farmer_dashboard_page.dart';
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
import '../../features/medical/presentation/pages/diagnosis_entry_page.dart';
import '../../features/medical/presentation/pages/medical_history_details_page.dart';
import '../../features/medical/presentation/pages/vaccination_details_page.dart';
import '../../features/medical/presentation/pages/vaccination_schedule_page.dart';
import '../../features/ai/presentation/pages/analyzing_scan_page.dart';
import '../../features/ai/presentation/pages/disease_scanner_page.dart';
import '../../features/ai/presentation/pages/scan_accuracy_comparison_page.dart';
import '../../features/ai/presentation/pages/scan_history_page.dart';
import '../../features/disease/presentation/pages/biosecurity_recommendations_page.dart';
import '../../features/disease/presentation/pages/disease_information_page.dart';
import '../../features/disease/presentation/pages/nearby_outbreak_details_page.dart';
import '../../features/disease/presentation/pages/report_disease_page.dart';
import '../../features/maps/presentation/pages/outbreak_map_page.dart';
import '../../features/maps/presentation/pages/risk_zone_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/vet_profile_page.dart';
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
        if (!isAuthRoute && loc != '/forgot-password' && loc != '/reset-password') {
          return '/welcome';
        }
        return null;
      }

      // If logged in and visiting auth page, redirect to active role dashboard
      if (isAuthRoute) {
        if (role == UserRole.veterinarian) return '/vet-dashboard';
        return '/farmer-dashboard';
      }

      // Role Guards
      if (role == UserRole.farmer) {
        if (loc.startsWith('/vet-dashboard') || loc.startsWith('/vet-requests') || loc.startsWith('/consultation-history') || loc.startsWith('/diagnosis-entry') || loc.startsWith('/vet-outbreak-map') || loc.startsWith('/vet-profile')) {
          return '/farmer-dashboard';
        }
      } else if (role == UserRole.veterinarian) {
        if (loc.startsWith('/farmer-dashboard') || loc == '/my-animals' || loc == '/add-animal' || loc == '/edit-animal') {
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
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
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
        path: '/vet-verification',
        builder: (context, state) => const VetVerificationPage(),
      ),
      GoRoute(
        path: '/add-animal',
        builder: (context, state) => const AddAnimalPage(),
      ),
      GoRoute(
        path: '/edit-animal',
        builder: (context, state) => const EditAnimalPage(),
      ),
      GoRoute(
        path: '/animal-passport',
        builder: (context, state) => const AnimalPassportPage(),
      ),
      GoRoute(
        path: '/animal-passport-qr-updated',
        builder: (context, state) => const AnimalPassportQrUpdatedPage(),
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
        builder: (context, state) => const DeleteAnimalConfirmationPage(),
      ),
      GoRoute(
        path: '/transfer-animal-ownership',
        builder: (context, state) => const TransferAnimalOwnershipPage(),
      ),
      GoRoute(
        path: '/add-prescription',
        builder: (context, state) => const AddPrescriptionPage(),
      ),
      GoRoute(
        path: '/add-treatment',
        builder: (context, state) => const AddTreatmentPage(),
      ),
      GoRoute(
        path: '/deworming-record',
        builder: (context, state) => const DewormingRecordPage(),
      ),
      GoRoute(
        path: '/diagnosis-entry',
        builder: (context, state) => const DiagnosisEntryPage(),
      ),
      GoRoute(
        path: '/medical-history-details',
        builder: (context, state) => const MedicalHistoryDetailsPage(),
      ),
      GoRoute(
        path: '/vaccination-details',
        builder: (context, state) => const VaccinationDetailsPage(),
      ),
      GoRoute(
        path: '/vaccination-schedule',
        builder: (context, state) => const VaccinationSchedulePage(),
      ),
      GoRoute(
        path: '/analyzing-scan',
        builder: (context, state) => const AnalyzingScanPage(),
      ),
      GoRoute(
        path: '/disease-scanner',
        builder: (context, state) => const DiseaseScannerPage(),
      ),
      GoRoute(
        path: '/scan-accuracy-comparison',
        builder: (context, state) => const ScanAccuracyComparisonPage(),
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
        builder: (context, state) => const NearbyOutbreakDetailsPage(),
      ),
      GoRoute(
        path: '/report-disease',
        builder: (context, state) => const ReportDiseasePage(),
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
        builder: (context, state) => const RiskZonePage(),
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
        builder: (context, state) => const AlertDetailsPage(),
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const AlertsPage(),
      ),
      GoRoute(
        path: '/appointment-booking',
        builder: (context, state) => const AppointmentBookingPage(),
      ),
      GoRoute(
        path: '/appointment-details',
        builder: (context, state) => const AppointmentDetailsPage(),
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
        builder: (context, state) => const NotificationDetailsPage(),
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
        path: '/search-results',
        builder: (context, state) => const SearchResultsPage(),
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
