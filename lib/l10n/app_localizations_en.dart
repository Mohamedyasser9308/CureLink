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
  String get onboardingSubtitle1 => 'Gentle reminders keep each dose visible.';

  @override
  String get onboardingTitle2 => 'Track your medication journey';

  @override
  String get onboardingSubtitle2 => 'See schedules, history, and progress.';

  @override
  String get onboardingTitle3 => 'Stay connected with caregivers';

  @override
  String get onboardingSubtitle3 => 'Share only what you approve.';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToContinue => 'Sign in to continue.';

  @override
  String get emailOrPhone => 'Email or phone';

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
}
