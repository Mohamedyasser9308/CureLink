// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CureLink';

  @override
  String welcome(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get login => 'Log in';

  @override
  String get tagline => 'Care that stays connected';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get continueButton => 'Continue';

  @override
  String get done => 'Done';

  @override
  String stepOfTotal(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingTitle1 => 'Never miss medication';

  @override
  String get onboardingSubtitle1 => 'Gentle reminders keep each dose visible';

  @override
  String get onboardingTitle2 => 'Track your medication journey';

  @override
  String get onboardingSubtitle2 => 'See schedules, history, and progress';

  @override
  String get onboardingTitle3 => 'Stay connected with caregivers';

  @override
  String get onboardingSubtitle3 => 'Share only what you approve';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToContinue => 'Sign in to continue.';

  @override
  String get emailOrPhone => 'Email or phone';

  @override
  String get createAccountSubtitle =>
      'Create your CureLink account to stay connected.';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get enterYourPhone => 'Enter your phone number';

  @override
  String get enterYourEmail => 'Enter your email address';

  @override
  String get createPassword => 'Create a password';

  @override
  String get reEnterPassword => 'Re-enter your password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get userSessionNotFound =>
      'User session not found. Please login again.';

  @override
  String get couldNotSaveAgeGroup =>
      'Could not save age group. Please try again.';

  @override
  String get emailAlreadyRegistered => 'This email is already registered.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get loginEmailHint => 'Enter your email address';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign up';

  @override
  String get invalidCredentials => 'Email or password is incorrect.';

  @override
  String get authenticationFailed => 'Authentication failed. Please try again.';

  @override
  String get completeProfileSubtitle =>
      'Add your information so CureLink can provide a better care experience.';

  @override
  String get tapToAddPhoto => 'Tap to add a profile photo';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get basicProfileDetails => 'Your basic profile details';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get nameMinLength => 'Name must contain at least 2 characters';

  @override
  String get cureLinkId => 'CureLink ID';

  @override
  String get caregiverConnectionIdHint =>
      'Use this ID when connecting with caregivers';

  @override
  String get emergencyContact => 'Emergency contact';

  @override
  String get emergencyContactHint => 'Someone we can contact in an emergency';

  @override
  String get contactName => 'Contact name';

  @override
  String get enterFullName => 'Enter full name';

  @override
  String get pleaseEnterEmergencyContactName =>
      'Please enter the emergency contact name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get pleaseEnterEmergencyPhone => 'Please enter the emergency phone';

  @override
  String get validPhoneNumber => 'Enter a valid phone number';

  @override
  String get pleaseWaitGeneratingId =>
      'Please wait while we generate your unique CureLink ID.';

  @override
  String get choosePhotoMethod => 'Choose how you want to add your photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get selectPhotoFromDevice => 'Select a photo from your device';

  @override
  String get useCamera => 'Use camera';

  @override
  String get takeNewProfilePhoto => 'Take a new profile photo';

  @override
  String get unableToSelectImage => 'Unable to select the image.';

  @override
  String get pleaseWaitIdGenerated =>
      'Please wait until your CureLink ID is generated.';

  @override
  String get profileCompleted => 'Profile completed';

  @override
  String get profileCreatedSuccessfully =>
      'Your CureLink profile has been created successfully.';

  @override
  String get yourCureLinkId => 'Your CureLink ID';

  @override
  String get firebasePermissionDenied =>
      'Firebase permission denied while generating CureLink ID.';

  @override
  String get noAuthenticatedUser =>
      'No authenticated user found. Please login first.';

  @override
  String get networkError =>
      'Network error. Please check your internet connection.';

  @override
  String get unableToGenerateId => 'Unable to generate a unique CureLink ID.';

  @override
  String get profilePermissionDenied =>
      'You do not have permission to save this profile.';

  @override
  String get sessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get idNotAvailable => 'Not available';

  @override
  String get invalidEmail => 'This email address is not valid.';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset your password';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent. Check your inbox.';

  @override
  String get userNotFound => 'No account was found with this email';

  @override
  String get passwordResetFailed => 'Could not send password reset email';

  @override
  String get weakPassword => 'Password is too weak. Use at least 8 characters.';

  @override
  String get noInternetConnection =>
      'No internet connection. Check your network and try again.';

  @override
  String get emailSignupDisabled =>
      'Email sign-up is not enabled in Firebase yet.';

  @override
  String get tooManyAttempts =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get couldNotCreateAccount =>
      'Could not create the account. Please try again.';

  @override
  String get profileSaveFailed =>
      'Account created, but we could not save your profile. Please try again.';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String noRouteDefined(String route) {
    return 'No route defined for $route';
  }

  @override
  String get enterDetails => 'Enter details';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get createAccount => 'Create account';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get fieldError => 'Check this field and try again.';

  @override
  String get fieldStates => 'Field states';

  @override
  String get stateDefault => 'Default';

  @override
  String get stateFocus => 'Focus';

  @override
  String get stateFilled => 'Filled';

  @override
  String get stateError => 'Error';

  @override
  String get stateDisabled => 'Disabled';

  @override
  String get chooseYourRole => 'Choose your role';

  @override
  String get personaFirst => 'Persona first';

  @override
  String get ageGroupSubtitle => 'Choose the age group that fits you.';

  @override
  String get roleChild => 'Child';

  @override
  String get roleTeenAdult => 'Teen / Adult';

  @override
  String get roleOlderAdult => 'Older Adult';

  @override
  String get childRoleHint =>
      'Child is Patient only; invalid roles are not shown.';

  @override
  String get teenAdultRoleHint =>
      'Choose Patient, Caregiver, or Both. Both starts in Patient Mode.';

  @override
  String get olderAdultRoleHint =>
      'Older Adult is Patient only; invalid roles are not shown.';

  @override
  String get rolePatient => 'Patient';

  @override
  String get roleCaregiver => 'Caregiver';

  @override
  String get roleBoth => 'Both';

  @override
  String get usePatientHint => 'Use CureLink as a patient.';

  @override
  String get useCaregiverHint => 'Use CureLink as a caregiver.';

  @override
  String get switchModesHint => 'Switch modes when needed.';

  @override
  String get completeProfile => 'Complete profile';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get selectedRole => 'Selected role';

  @override
  String get ageGroup => 'Age group';

  @override
  String get userIdPlaceholder => 'User ID - placeholder';

  @override
  String get generatedAfterSetup => 'Generated after setup';

  @override
  String get patientMode => 'Patient Mode';

  @override
  String get caregiverMode => 'Caregiver Mode';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get navHome => 'Home';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get all => 'All';

  @override
  String get morning => 'Morning';

  @override
  String get evening => 'Evening';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get medicationPlanToday => 'Here is your medication plan for today.';

  @override
  String get nextDose => 'Next dose';

  @override
  String inDuration(String time) {
    return 'In $time';
  }

  @override
  String scheduledTime(String time) {
    return 'Scheduled time · $time';
  }

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get statusDueNow => 'Due now';

  @override
  String get statusTaken => 'Taken';

  @override
  String get statusMissed => 'Missed';

  @override
  String get statusPending => 'Pending';

  @override
  String get todaysProgress => 'Today\'s progress';

  @override
  String progressCount(int done, int total) {
    return '$done of $total';
  }

  @override
  String get emergencySos => 'Emergency / SOS';

  @override
  String get olderHomeTitle => 'Your day, clearly planned';

  @override
  String get olderHomeSubtitle => 'Every next step is simple and visible.';

  @override
  String get confirmDose => 'Confirm Dose';

  @override
  String get medicationReminder => 'Medication reminder';

  @override
  String get timeForYourMedication => 'It\'s time for your medication';

  @override
  String get remindMeLater => 'Remind me later';

  @override
  String get doseRecorded => 'Dose recorded';

  @override
  String get doseComplete => 'Dose complete';

  @override
  String get progressUpdated => 'Progress has been updated.';

  @override
  String get childHomeTitle => 'Ready for today\'s mission?';

  @override
  String get childHomeSubtitle => 'One small step at a time. You\'ve got this!';

  @override
  String starsNextBadge(int stars, int target) {
    return '$stars stars · next badge at $target';
  }

  @override
  String get missionProgress => 'Mission progress';

  @override
  String get myMission => 'My mission';

  @override
  String get markAsTaken => 'Mark as taken';

  @override
  String get starEarned => 'Star earned!';

  @override
  String get braveRoutineBadge => 'Brave Routine badge';

  @override
  String get addMedicine => 'Add medicine';

  @override
  String get editMedicine => 'Edit medicine';

  @override
  String get deleteMedicine => 'Delete medicine';

  @override
  String get medicineDetails => 'Medicine details';

  @override
  String get medicationName => 'Medication name';

  @override
  String get descriptionPlaceholder => 'Description placeholder.';

  @override
  String get dose => 'Dose';

  @override
  String get quantity => 'Quantity';

  @override
  String get time => 'Time';

  @override
  String get frequency => 'Frequency';

  @override
  String get duration => 'Duration';

  @override
  String get conditions => 'Conditions';

  @override
  String get timing => 'Timing';

  @override
  String get instructions => 'Instructions';

  @override
  String get notes => 'Notes';

  @override
  String get profile => 'Profile';

  @override
  String get patientName => 'Patient name';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get permissions => 'Permissions';

  @override
  String get helpAndSupport => 'Help and support';

  @override
  String get logOut => 'Log out';

  @override
  String get caregiverDashboard => 'Caregiver dashboard';

  @override
  String get careOverview => 'Care overview';

  @override
  String get careOverviewSubtitle =>
      'Review connected patients and attention items.';

  @override
  String get addPatient => 'Add Patient';

  @override
  String get connectedPatients => 'Connected patients';

  @override
  String get needsAttention => 'Needs attention';

  @override
  String get onTrack => 'On track';

  @override
  String get latestMedicationMissed => 'Latest: Medication missed';

  @override
  String get latestDoseTaken => 'Latest: Dose taken';

  @override
  String dosesSummary(int taken, int missed, int pending) {
    return 'Taken $taken · Missed $missed · Pending $pending';
  }

  @override
  String get recentAlerts => 'Recent alerts';

  @override
  String get missedDose => 'Missed dose';

  @override
  String get patientDetails => 'Patient details';

  @override
  String get careManage => 'Care manage';

  @override
  String get todaysMedications => 'Today\'s medications';

  @override
  String get adherence => 'Adherence';

  @override
  String get historyAndAlerts => 'History and alerts';

  @override
  String get careAlerts => 'Care alerts';

  @override
  String get noNewAlerts => 'No new alerts';

  @override
  String get attentionItemsAppearHere => 'Attention items appear here.';

  @override
  String get caregiverConnection => 'Caregiver connection';

  @override
  String get connectionState => 'Connection state';

  @override
  String get noLinkedPatients => 'No linked patients';

  @override
  String get reviewPatientAndPermission =>
      'Review the patient and requested permission.';

  @override
  String get patientId => 'Patient ID';

  @override
  String get placeholderUserId => 'Placeholder user ID';

  @override
  String get requestAccess => 'Request Access';

  @override
  String get patient => 'Patient';

  @override
  String get readOnly => 'Read-only';

  @override
  String get manageMedications => 'Manage medications';

  @override
  String get pending => 'Pending';

  @override
  String get waitingForApproval =>
      'Waiting for approval. No access is available yet.';

  @override
  String get waitingForPatient => 'Waiting for patient';

  @override
  String get approved => 'Approved';

  @override
  String get shownAfterApproval => 'Shown only after the approval checkpoint.';

  @override
  String get connectedAppearsAfterApproval =>
      'Connected appears only after approval.';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get emptyMedicationsTitle => 'No medicines for today';

  @override
  String get emptyMedicationsMessage => 'Add a medicine to see your plan here.';

  @override
  String get allDosesDone => 'All done for today';

  @override
  String get allDosesDoneMessage => 'You have no more doses scheduled today.';

  @override
  String get retry => 'Try again';
}
