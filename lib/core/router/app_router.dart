import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
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

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/splash',
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
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register-role',
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
    ],
  );
}
