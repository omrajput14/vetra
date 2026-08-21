import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Vetra'**
  String get appName;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी (Hindi)'**
  String get hindi;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी (Marathi)'**
  String get marathi;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @protectYourHerd.
  ///
  /// In en, this message translates to:
  /// **'Protect Your Herd'**
  String get protectYourHerd;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered disease detection and instant vet connections in your pocket.'**
  String get onboardingSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @welcomeToVetra.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vetra'**
  String get welcomeToVetra;

  /// No description provided for @chooseHowToContinue.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to continue'**
  String get chooseHowToContinue;

  /// No description provided for @continueAsFarmer.
  ///
  /// In en, this message translates to:
  /// **'Continue as Farmer'**
  String get continueAsFarmer;

  /// No description provided for @farmerRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Herd management, AI disease scanner, local vet booking & outbreak alerts.'**
  String get farmerRoleDesc;

  /// No description provided for @continueAsVet.
  ///
  /// In en, this message translates to:
  /// **'Continue as Veterinarian'**
  String get continueAsVet;

  /// No description provided for @vetRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Clinical triage, case diagnostics, digital prescriptions & farm consultations.'**
  String get vetRoleDesc;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @animalCount.
  ///
  /// In en, this message translates to:
  /// **'Animal Count'**
  String get animalCount;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Council Reg No.'**
  String get registrationNumber;

  /// No description provided for @qualification.
  ///
  /// In en, this message translates to:
  /// **'Qualification'**
  String get qualification;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @clinicName.
  ///
  /// In en, this message translates to:
  /// **'Clinic / Hospital Name'**
  String get clinicName;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsExperience;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @registerFarmerTitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer Registration'**
  String get registerFarmerTitle;

  /// No description provided for @registerVetTitle.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian Registration'**
  String get registerVetTitle;

  /// No description provided for @preferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get preferredLanguage;

  /// No description provided for @welcomeFarmer.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Farmer'**
  String get welcomeFarmer;

  /// No description provided for @welcomeVet.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Doctor'**
  String get welcomeVet;

  /// No description provided for @myAnimals.
  ///
  /// In en, this message translates to:
  /// **'My Animals'**
  String get myAnimals;

  /// No description provided for @healthRecords.
  ///
  /// In en, this message translates to:
  /// **'Health Records'**
  String get healthRecords;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @aiHealthCheck.
  ///
  /// In en, this message translates to:
  /// **'AI Health Check'**
  String get aiHealthCheck;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addAnimal.
  ///
  /// In en, this message translates to:
  /// **'Add Animal'**
  String get addAnimal;

  /// No description provided for @scanDisease.
  ///
  /// In en, this message translates to:
  /// **'Scan Disease'**
  String get scanDisease;

  /// No description provided for @bookConsultation.
  ///
  /// In en, this message translates to:
  /// **'Book Consultation'**
  String get bookConsultation;

  /// No description provided for @viewRecords.
  ///
  /// In en, this message translates to:
  /// **'View Records'**
  String get viewRecords;

  /// No description provided for @outbreakAlerts.
  ///
  /// In en, this message translates to:
  /// **'Outbreak Alerts'**
  String get outbreakAlerts;

  /// No description provided for @statsAnimals.
  ///
  /// In en, this message translates to:
  /// **'Total Animals'**
  String get statsAnimals;

  /// No description provided for @statsAppointments.
  ///
  /// In en, this message translates to:
  /// **'Active Visits'**
  String get statsAppointments;

  /// No description provided for @statsScans.
  ///
  /// In en, this message translates to:
  /// **'AI Scans'**
  String get statsScans;

  /// No description provided for @animalName.
  ///
  /// In en, this message translates to:
  /// **'Animal Name'**
  String get animalName;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @healthStatus.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get healthStatus;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @vaccinationSchedule.
  ///
  /// In en, this message translates to:
  /// **'Vaccination Schedule'**
  String get vaccinationSchedule;

  /// No description provided for @tagNumber.
  ///
  /// In en, this message translates to:
  /// **'Ear Tag Number'**
  String get tagNumber;

  /// No description provided for @qrPassport.
  ///
  /// In en, this message translates to:
  /// **'QR Passport'**
  String get qrPassport;

  /// No description provided for @noAnimalsYet.
  ///
  /// In en, this message translates to:
  /// **'No animals registered yet'**
  String get noAnimalsYet;

  /// No description provided for @addFirstAnimal.
  ///
  /// In en, this message translates to:
  /// **'Register your first animal'**
  String get addFirstAnimal;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @sick.
  ///
  /// In en, this message translates to:
  /// **'Sick / Needs Review'**
  String get sick;

  /// No description provided for @underTreatment.
  ///
  /// In en, this message translates to:
  /// **'Under Treatment'**
  String get underTreatment;

  /// No description provided for @criticalStatus.
  ///
  /// In en, this message translates to:
  /// **'Critical Attention'**
  String get criticalStatus;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @cattle.
  ///
  /// In en, this message translates to:
  /// **'Cattle'**
  String get cattle;

  /// No description provided for @buffalo.
  ///
  /// In en, this message translates to:
  /// **'Buffalo'**
  String get buffalo;

  /// No description provided for @goat.
  ///
  /// In en, this message translates to:
  /// **'Goat'**
  String get goat;

  /// No description provided for @sheep.
  ///
  /// In en, this message translates to:
  /// **'Sheep'**
  String get sheep;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @bornOn.
  ///
  /// In en, this message translates to:
  /// **'Born on'**
  String get bornOn;

  /// No description provided for @evmrTitle.
  ///
  /// In en, this message translates to:
  /// **'Electronic Veterinary Medical Record (EVMR)'**
  String get evmrTitle;

  /// No description provided for @clinicalDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Clinical Diagnosis'**
  String get clinicalDiagnosis;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @treatment.
  ///
  /// In en, this message translates to:
  /// **'Clinical Treatment'**
  String get treatment;

  /// No description provided for @prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get prescriptions;

  /// No description provided for @bodyTemperature.
  ///
  /// In en, this message translates to:
  /// **'Body Temperature'**
  String get bodyTemperature;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Live Weight'**
  String get weight;

  /// No description provided for @followUpDate.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Date'**
  String get followUpDate;

  /// No description provided for @confirmedByVet.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by Veterinarian'**
  String get confirmedByVet;

  /// No description provided for @immutableRecordNotice.
  ///
  /// In en, this message translates to:
  /// **'This is an immutable official veterinary record.'**
  String get immutableRecordNotice;

  /// No description provided for @noMedicalRecords.
  ///
  /// In en, this message translates to:
  /// **'No medical records on file'**
  String get noMedicalRecords;

  /// No description provided for @bookVetConsultation.
  ///
  /// In en, this message translates to:
  /// **'Book Vet Consultation'**
  String get bookVetConsultation;

  /// No description provided for @selectVeterinarian.
  ///
  /// In en, this message translates to:
  /// **'Select Veterinarian'**
  String get selectVeterinarian;

  /// No description provided for @consultationType.
  ///
  /// In en, this message translates to:
  /// **'Consultation Type'**
  String get consultationType;

  /// No description provided for @scheduledDate.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Date'**
  String get scheduledDate;

  /// No description provided for @scheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get scheduledTime;

  /// No description provided for @urgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency Level'**
  String get urgency;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get notes;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Appointment Confirmed'**
  String get bookingConfirmed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Confirmation'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @upcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get upcomingAppointments;

  /// No description provided for @pastAppointments.
  ///
  /// In en, this message translates to:
  /// **'Past Appointments'**
  String get pastAppointments;

  /// No description provided for @aiDiseaseScanner.
  ///
  /// In en, this message translates to:
  /// **'AI Disease Scanner'**
  String get aiDiseaseScanner;

  /// No description provided for @scanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get scanNow;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload from Gallery'**
  String get uploadPhoto;

  /// No description provided for @analyzingScan.
  ///
  /// In en, this message translates to:
  /// **'Analyzing visual patterns with Vetra Vision AI...'**
  String get analyzingScan;

  /// No description provided for @suspectedCondition.
  ///
  /// In en, this message translates to:
  /// **'Suspected Condition'**
  String get suspectedCondition;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'AI Confidence'**
  String get confidence;

  /// No description provided for @scanDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI-assisted preliminary assessment. Not a confirmed veterinary diagnosis. Consult a licensed veterinarian.'**
  String get scanDisclaimer;

  /// No description provided for @bookDoctorReview.
  ///
  /// In en, this message translates to:
  /// **'Book Doctor Review'**
  String get bookDoctorReview;

  /// No description provided for @aiVeterinaryAdvisor.
  ///
  /// In en, this message translates to:
  /// **'AI Veterinary Advisor'**
  String get aiVeterinaryAdvisor;

  /// No description provided for @assistiveClinicalScreening.
  ///
  /// In en, this message translates to:
  /// **'Assistive Clinical Screening'**
  String get assistiveClinicalScreening;

  /// No description provided for @liveContext.
  ///
  /// In en, this message translates to:
  /// **'Live Context'**
  String get liveContext;

  /// No description provided for @startNewSession.
  ///
  /// In en, this message translates to:
  /// **'Start New Session'**
  String get startNewSession;

  /// No description provided for @urgentClinicalConcern.
  ///
  /// In en, this message translates to:
  /// **'Urgent Clinical Concern'**
  String get urgentClinicalConcern;

  /// No description provided for @urgentConcernNotice.
  ///
  /// In en, this message translates to:
  /// **'Reported symptoms warrant immediate on-site veterinary evaluation.'**
  String get urgentConcernNotice;

  /// No description provided for @bookVet.
  ///
  /// In en, this message translates to:
  /// **'Book Vet'**
  String get bookVet;

  /// No description provided for @describeSymptomsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe symptoms or answer questions...'**
  String get describeSymptomsHint;

  /// No description provided for @preliminaryAssessment.
  ///
  /// In en, this message translates to:
  /// **'Preliminary Assessment'**
  String get preliminaryAssessment;

  /// No description provided for @suspectedConditions.
  ///
  /// In en, this message translates to:
  /// **'Suspected Conditions'**
  String get suspectedConditions;

  /// No description provided for @aiConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI Confidence'**
  String get aiConfidence;

  /// No description provided for @ownerReportedSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Owner-Reported Symptoms & Vitals'**
  String get ownerReportedSymptoms;

  /// No description provided for @aiClinicalObservations.
  ///
  /// In en, this message translates to:
  /// **'AI Clinical Observations'**
  String get aiClinicalObservations;

  /// No description provided for @recommendedSupportiveCare.
  ///
  /// In en, this message translates to:
  /// **'Recommended Supportive Care'**
  String get recommendedSupportiveCare;

  /// No description provided for @safetyDisclaimerText.
  ///
  /// In en, this message translates to:
  /// **'This is an AI-assisted preliminary assessment and is not a confirmed veterinary diagnosis. Consult a licensed veterinarian for clinical diagnosis and treatment.'**
  String get safetyDisclaimerText;

  /// No description provided for @askAdvisor.
  ///
  /// In en, this message translates to:
  /// **'Ask AI Advisor'**
  String get askAdvisor;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacySettings;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @aboutLegal.
  ///
  /// In en, this message translates to:
  /// **'About Vetra & Legal'**
  String get aboutLegal;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @vetDashboard.
  ///
  /// In en, this message translates to:
  /// **'Vet Dashboard'**
  String get vetDashboard;

  /// No description provided for @surveillanceAnimals.
  ///
  /// In en, this message translates to:
  /// **'Surveillance Animals'**
  String get surveillanceAnimals;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @quickClinicalActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Clinical Actions'**
  String get quickClinicalActions;

  /// No description provided for @scanAnimalQr.
  ///
  /// In en, this message translates to:
  /// **'Scan Animal QR'**
  String get scanAnimalQr;

  /// No description provided for @diagnosisEntry.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Entry'**
  String get diagnosisEntry;

  /// No description provided for @incomingClinicalRequests.
  ///
  /// In en, this message translates to:
  /// **'Incoming Clinical Requests'**
  String get incomingClinicalRequests;

  /// No description provided for @tabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get tabPending;

  /// No description provided for @tabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tabUpcoming;

  /// No description provided for @tabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tabCompleted;

  /// No description provided for @noRequestsSection.
  ///
  /// In en, this message translates to:
  /// **'No requests in this section'**
  String get noRequestsSection;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @startConsultation.
  ///
  /// In en, this message translates to:
  /// **'Start Consultation'**
  String get startConsultation;

  /// No description provided for @viewAnimalPassport.
  ///
  /// In en, this message translates to:
  /// **'View Animal Passport'**
  String get viewAnimalPassport;

  /// No description provided for @createMedicalRecord.
  ///
  /// In en, this message translates to:
  /// **'Create Medical Record'**
  String get createMedicalRecord;

  /// No description provided for @clinicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Clinical Notes'**
  String get clinicalNotes;

  /// No description provided for @enterDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Enter Diagnosis'**
  String get enterDiagnosis;

  /// No description provided for @enterTreatment.
  ///
  /// In en, this message translates to:
  /// **'Enter Treatment & Procedures'**
  String get enterTreatment;

  /// No description provided for @prescribeMedications.
  ///
  /// In en, this message translates to:
  /// **'Prescribe Medications (Rx)'**
  String get prescribeMedications;

  /// No description provided for @recordSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medical record saved successfully!'**
  String get recordSavedSuccess;

  /// No description provided for @recentCases.
  ///
  /// In en, this message translates to:
  /// **'Recent Consultation Cases'**
  String get recentCases;

  /// No description provided for @caseDetails.
  ///
  /// In en, this message translates to:
  /// **'Case Details'**
  String get caseDetails;

  /// No description provided for @recovered.
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get recovered;

  /// No description provided for @vetProfile.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian Profile'**
  String get vetProfile;

  /// No description provided for @practitionerInfo.
  ///
  /// In en, this message translates to:
  /// **'Practitioner Information'**
  String get practitionerInfo;

  /// No description provided for @availabilityStatus.
  ///
  /// In en, this message translates to:
  /// **'Availability Status'**
  String get availabilityStatus;

  /// No description provided for @availableForVisits.
  ///
  /// In en, this message translates to:
  /// **'Available for Consultations & Visits'**
  String get availableForVisits;

  /// No description provided for @qualificationsAndDegrees.
  ///
  /// In en, this message translates to:
  /// **'Qualifications & Degrees'**
  String get qualificationsAndDegrees;

  /// No description provided for @clinicalSpecialization.
  ///
  /// In en, this message translates to:
  /// **'Clinical Specialization'**
  String get clinicalSpecialization;

  /// No description provided for @yearsClinicalPractice.
  ///
  /// In en, this message translates to:
  /// **'Years Clinical Practice'**
  String get yearsClinicalPractice;

  /// No description provided for @directContact.
  ///
  /// In en, this message translates to:
  /// **'Direct Practitioner Contact'**
  String get directContact;

  /// No description provided for @editProfileQualifications.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile & Qualifications'**
  String get editProfileQualifications;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update clinical details and contact info'**
  String get editProfileSubtitle;

  /// No description provided for @clinicalSchedule.
  ///
  /// In en, this message translates to:
  /// **'My Clinical Schedule'**
  String get clinicalSchedule;

  /// No description provided for @clinicalScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View upcoming consultations and visits'**
  String get clinicalScheduleSubtitle;

  /// No description provided for @availabilityShiftSettings.
  ///
  /// In en, this message translates to:
  /// **'Availability & Shift Settings'**
  String get availabilityShiftSettings;

  /// No description provided for @availabilityShiftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure emergency response hours'**
  String get availabilityShiftSubtitle;

  /// No description provided for @documentsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Documents & Licenses'**
  String get documentsLicenses;

  /// No description provided for @documentsLicensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage verified registration certificates'**
  String get documentsLicensesSubtitle;

  /// No description provided for @logoutVetAccount.
  ///
  /// In en, this message translates to:
  /// **'Log Out Practitioner Account'**
  String get logoutVetAccount;

  /// No description provided for @logoutVetAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Safely end active session'**
  String get logoutVetAccountSubtitle;

  /// No description provided for @licenseVerified.
  ///
  /// In en, this message translates to:
  /// **'License Verified'**
  String get licenseVerified;

  /// No description provided for @licenseVerifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your veterinary license has been verified with active status.'**
  String get licenseVerifiedDesc;

  /// No description provided for @goToVetDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Vet Dashboard'**
  String get goToVetDashboard;

  /// No description provided for @vetOutbreakMap.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Outbreak Map'**
  String get vetOutbreakMap;

  /// No description provided for @gisMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive Clinical GIS Map'**
  String get gisMapTitle;

  /// No description provided for @gisMapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'GPS Radius Overlay around practice area'**
  String get gisMapSubtitle;

  /// No description provided for @filterDisease.
  ///
  /// In en, this message translates to:
  /// **'Disease'**
  String get filterDisease;

  /// No description provided for @filterRadius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get filterRadius;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterStatus;

  /// No description provided for @allDiseases.
  ///
  /// In en, this message translates to:
  /// **'All Diseases'**
  String get allDiseases;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// No description provided for @vetSignIn.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian Sign In'**
  String get vetSignIn;

  /// No description provided for @vetSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access clinical diagnostics and regional outbreak triage.'**
  String get vetSignInSubtitle;

  /// No description provided for @vetRegNo.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Registration Number'**
  String get vetRegNo;

  /// No description provided for @registerPractice.
  ///
  /// In en, this message translates to:
  /// **'Register Practice'**
  String get registerPractice;

  /// No description provided for @registerPracticeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide professional licensing details for active verification.'**
  String get registerPracticeSubtitle;

  /// No description provided for @newPractitioner.
  ///
  /// In en, this message translates to:
  /// **'New Practitioner?'**
  String get newPractitioner;

  /// No description provided for @enterDiagnosisValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter clinical diagnosis'**
  String get enterDiagnosisValidation;

  /// No description provided for @enterTreatmentValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter clinical treatment'**
  String get enterTreatmentValidation;

  /// No description provided for @enterEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get enterEmailAndPassword;

  /// No description provided for @enterRequiredRegistration.
  ///
  /// In en, this message translates to:
  /// **'Please enter Email, Password, Name, and Registration Number'**
  String get enterRequiredRegistration;

  /// No description provided for @qrScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Veterinary QR Scanner'**
  String get qrScannerTitle;

  /// No description provided for @scanAnimalQrPrompt.
  ///
  /// In en, this message translates to:
  /// **'Point camera at animal ear tag QR code'**
  String get scanAnimalQrPrompt;

  /// No description provided for @temperatureInCelsius.
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get temperatureInCelsius;

  /// No description provided for @weightInKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightInKg;

  /// No description provided for @voiceInputTapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get voiceInputTapToSpeak;

  /// No description provided for @voiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get voiceListening;

  /// No description provided for @voiceProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing speech...'**
  String get voiceProcessing;

  /// No description provided for @voiceError.
  ///
  /// In en, this message translates to:
  /// **'Could not understand speech. Please try again.'**
  String get voiceError;

  /// No description provided for @voicePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice input.'**
  String get voicePermissionRequired;

  /// No description provided for @voiceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input not available on this device.'**
  String get voiceNotAvailable;

  /// No description provided for @aiAdvisorTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Veterinary Advisor'**
  String get aiAdvisorTitle;

  /// No description provided for @describeAnimalProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe your animal problem...'**
  String get describeAnimalProblem;

  /// No description provided for @typeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type message or tap mic...'**
  String get typeMessageHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
