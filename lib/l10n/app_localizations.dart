import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en'),
  ];

  /// Localized App title text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'CureLink'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcome(String name);

  /// Localized Login text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// Localized Tagline text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Care that stays connected'**
  String get tagline;

  /// Localized Skip text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Localized Next text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Localized Get started text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// Localized Continue button text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Localized Done text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @stepOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOfTotal(int current, int total);

  /// Localized Onboarding title 1 text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Never miss medication'**
  String get onboardingTitle1;

  /// Localized Onboarding subtitle 1 text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminders keep each dose visible'**
  String get onboardingSubtitle1;

  /// Localized Onboarding title 2 text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Track your medication journey'**
  String get onboardingTitle2;

  /// Localized Onboarding subtitle 2 text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'See schedules, history, and progress'**
  String get onboardingSubtitle2;

  /// Localized Onboarding title 3 text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Stay connected with caregivers'**
  String get onboardingTitle3;

  /// Localized Onboarding subtitle 3 text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Share only what you approve'**
  String get onboardingSubtitle3;

  /// Localized Welcome back text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Localized Sign in to continue text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue.'**
  String get signInToContinue;

  /// Localized Email or phone text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Email or phone'**
  String get emailOrPhone;

  /// Localized Create account subtitle text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Create your CureLink account to stay connected.'**
  String get createAccountSubtitle;

  /// Localized Enter your name text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// Localized Enter your phone text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhone;

  /// Localized Enter your email text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmail;

  /// Localized Create password text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// Localized Re enter password text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reEnterPassword;

  /// Localized Already have account text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Localized Something went wrong text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// Localized User session not found text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'User session not found. Please login again.'**
  String get userSessionNotFound;

  /// Localized Could not save age group text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Could not save age group. Please try again.'**
  String get couldNotSaveAgeGroup;

  /// Localized Email already registered text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get emailAlreadyRegistered;

  /// Localized Passwords do not match text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// Localized Login email hint text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get loginEmailHint;

  /// Localized Login password hint text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// Localized Enter password text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Localized Dont have account text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Localized Sign up text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// Localized Invalid credentials text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get invalidCredentials;

  /// Localized Authentication failed text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authenticationFailed;

  /// Localized Complete profile subtitle text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Add your information so CureLink can provide a better care experience.'**
  String get completeProfileSubtitle;

  /// Localized Tap to add photo text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a profile photo'**
  String get tapToAddPhoto;

  /// Localized Personal information text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// Localized Basic profile details text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Your basic profile details'**
  String get basicProfileDetails;

  /// Localized Please enter name text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// Localized Name min length text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Name must contain at least 2 characters'**
  String get nameMinLength;

  /// Localized Cure link id text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'CureLink ID'**
  String get cureLinkId;

  /// Localized Caregiver connection id hint text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Use this ID when connecting with caregivers'**
  String get caregiverConnectionIdHint;

  /// Localized Emergency contact text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get emergencyContact;

  /// Localized Emergency contact hint text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Someone we can contact in an emergency'**
  String get emergencyContactHint;

  /// Localized Contact name text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get contactName;

  /// Localized Enter full name text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// Localized Please enter emergency contact name text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Please enter the emergency contact name'**
  String get pleaseEnterEmergencyContactName;

  /// Localized Phone number text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// Localized Enter phone number text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// Localized Please enter emergency phone text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Please enter the emergency phone'**
  String get pleaseEnterEmergencyPhone;

  /// Localized Valid phone number text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validPhoneNumber;

  /// Localized Please wait generating id text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we generate your unique CureLink ID.'**
  String get pleaseWaitGeneratingId;

  /// Localized Choose photo method text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to add your photo'**
  String get choosePhotoMethod;

  /// Localized Choose from gallery text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// Localized Select photo from device text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Select a photo from your device'**
  String get selectPhotoFromDevice;

  /// Localized Use camera text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Use camera'**
  String get useCamera;

  /// Localized Take new profile photo text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Take a new profile photo'**
  String get takeNewProfilePhoto;

  /// Localized Unable to select image text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Unable to select the image.'**
  String get unableToSelectImage;

  /// Localized Please wait id generated text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Please wait until your CureLink ID is generated.'**
  String get pleaseWaitIdGenerated;

  /// Localized Profile completed text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Profile completed'**
  String get profileCompleted;

  /// Localized Profile created successfully text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Your CureLink profile has been created successfully.'**
  String get profileCreatedSuccessfully;

  /// Localized Your cure link id text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Your CureLink ID'**
  String get yourCureLinkId;

  /// Localized Firebase permission denied text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Firebase permission denied while generating CureLink ID.'**
  String get firebasePermissionDenied;

  /// Localized No authenticated user text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'No authenticated user found. Please login first.'**
  String get noAuthenticatedUser;

  /// Localized Network error text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkError;

  /// Localized Unable to generate id text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate a unique CureLink ID.'**
  String get unableToGenerateId;

  /// Localized Profile permission denied text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to save this profile.'**
  String get profilePermissionDenied;

  /// Localized Session expired text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpired;

  /// Localized Id not available text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get idNotAvailable;

  /// Localized Invalid email text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'This email address is not valid.'**
  String get invalidEmail;

  /// Localized Forgot password subtitle text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password'**
  String get forgotPasswordSubtitle;

  /// Localized Send reset link text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Localized Back to login text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// Localized Password reset email sent text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get passwordResetEmailSent;

  /// Localized User not found text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'No account was found with this email'**
  String get userNotFound;

  /// Localized Password reset failed text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Could not send password reset email'**
  String get passwordResetFailed;

  /// Localized Weak password text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 8 characters.'**
  String get weakPassword;

  /// Localized No internet connection text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get noInternetConnection;

  /// Localized Email signup disabled text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Email sign-up is not enabled in Firebase yet.'**
  String get emailSignupDisabled;

  /// Localized Too many attempts text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get tooManyAttempts;

  /// Localized Could not create account text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Could not create the account. Please try again.'**
  String get couldNotCreateAccount;

  /// Localized Profile save failed text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Account created, but we could not save your profile. Please try again.'**
  String get profileSaveFailed;

  /// Localized Page not found text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @noRouteDefined.
  ///
  /// In en, this message translates to:
  /// **'No route defined for {route}'**
  String noRouteDefined(String route);

  /// Localized Enter details text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Enter details'**
  String get enterDetails;

  /// Localized Password text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Localized Confirm password text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Localized Forgot password text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Localized Create account text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Localized Name text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Localized Phone text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Localized Email text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Localized Field error text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Check this field and try again.'**
  String get fieldError;

  /// Localized Field states text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Field states'**
  String get fieldStates;

  /// Localized State default text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get stateDefault;

  /// Localized State focus text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get stateFocus;

  /// Localized State filled text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get stateFilled;

  /// Localized State error text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get stateError;

  /// Localized State disabled text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get stateDisabled;

  /// Localized Choose your role text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Choose your role'**
  String get chooseYourRole;

  /// Localized Persona first text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Persona first'**
  String get personaFirst;

  /// Localized Age group subtitle text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Choose the age group that fits you.'**
  String get ageGroupSubtitle;

  /// Localized Role child text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get roleChild;

  /// Localized Role teen adult text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Teen / Adult'**
  String get roleTeenAdult;

  /// Localized Role older adult text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Older Adult'**
  String get roleOlderAdult;

  /// Localized Child role hint text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Child is Patient only; invalid roles are not shown.'**
  String get childRoleHint;

  /// Localized Teen adult role hint text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Choose Patient, Caregiver, or Both. Both starts in Patient Mode.'**
  String get teenAdultRoleHint;

  /// Localized Older adult role hint text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Older Adult is Patient only; invalid roles are not shown.'**
  String get olderAdultRoleHint;

  /// Localized Role patient text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get rolePatient;

  /// Localized Role caregiver text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get roleCaregiver;

  /// Localized Role both text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get roleBoth;

  /// Localized Use patient hint text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Use CureLink as a patient.'**
  String get usePatientHint;

  /// Localized Use caregiver hint text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Use CureLink as a caregiver.'**
  String get useCaregiverHint;

  /// Localized Switch modes hint text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Switch modes when needed.'**
  String get switchModesHint;

  /// Localized Complete profile text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Complete profile'**
  String get completeProfile;

  /// Localized Profile photo text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// Localized Selected role text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Selected role'**
  String get selectedRole;

  /// Localized Age group text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Age group'**
  String get ageGroup;

  /// Localized User id placeholder text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'User ID - placeholder'**
  String get userIdPlaceholder;

  /// Localized Generated after setup text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Generated after setup'**
  String get generatedAfterSetup;

  /// Localized Patient mode text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Patient Mode'**
  String get patientMode;

  /// Localized Caregiver mode text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Mode'**
  String get caregiverMode;

  /// Localized Save profile text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// Localized Nav home text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Localized Nav schedule text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// Localized Nav calendar text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// Localized Nav notifications text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// Localized Nav profile text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Localized Today text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Localized Tomorrow text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Localized All text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Localized Morning text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// Localized Evening text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// Localized Good morning text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// Localized Medication plan today text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Here is your medication plan for today.'**
  String get medicationPlanToday;

  /// Localized Next dose text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Next dose'**
  String get nextDose;

  /// No description provided for @inDuration.
  ///
  /// In en, this message translates to:
  /// **'In {time}'**
  String inDuration(String time);

  /// No description provided for @scheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled time · {time}'**
  String scheduledTime(String time);

  /// Localized Status upcoming text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get statusUpcoming;

  /// Localized Status due now text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get statusDueNow;

  /// Localized Status taken text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get statusTaken;

  /// Localized Status missed text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// Localized Status pending text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Localized Todays progress text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Today\'s progress'**
  String get todaysProgress;

  /// No description provided for @progressCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String progressCount(int done, int total);

  /// Localized Emergency sos text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Emergency / SOS'**
  String get emergencySos;

  /// Localized Older home title text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Your day, clearly planned'**
  String get olderHomeTitle;

  /// Localized Older home subtitle text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Every next step is simple and visible.'**
  String get olderHomeSubtitle;

  /// Localized Confirm dose text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Confirm Dose'**
  String get confirmDose;

  /// Localized Medication reminder text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Medication reminder'**
  String get medicationReminder;

  /// Localized Time for your medication text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'It\'s time for your medication'**
  String get timeForYourMedication;

  /// Localized Remind me later text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Remind me later'**
  String get remindMeLater;

  /// Localized Dose recorded text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Dose recorded'**
  String get doseRecorded;

  /// Localized Dose complete text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Dose complete'**
  String get doseComplete;

  /// Localized Progress updated text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Progress has been updated.'**
  String get progressUpdated;

  /// Localized Child home title text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Ready for today\'s mission?'**
  String get childHomeTitle;

  /// Localized Child home subtitle text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'One small step at a time. You\'ve got this!'**
  String get childHomeSubtitle;

  /// No description provided for @starsNextBadge.
  ///
  /// In en, this message translates to:
  /// **'{stars} stars · next badge at {target}'**
  String starsNextBadge(int stars, int target);

  /// Localized Mission progress text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Mission progress'**
  String get missionProgress;

  /// Localized My mission text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'My mission'**
  String get myMission;

  /// Localized Mark as taken text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Mark as taken'**
  String get markAsTaken;

  /// Localized Star earned text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Star earned!'**
  String get starEarned;

  /// Localized Brave routine badge text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Brave Routine badge'**
  String get braveRoutineBadge;

  /// Localized Add medicine text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get addMedicine;

  /// Localized Edit medicine text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Edit medicine'**
  String get editMedicine;

  /// Localized Delete medicine text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Delete medicine'**
  String get deleteMedicine;

  /// Localized Medicine details text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Medicine details'**
  String get medicineDetails;

  /// Localized Medication name text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Medication name'**
  String get medicationName;

  /// Localized Description placeholder text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Description placeholder.'**
  String get descriptionPlaceholder;

  /// Localized Dose text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// Localized Quantity text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Localized Time text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Localized Frequency text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// Localized Duration text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Localized Conditions text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditions;

  /// Localized Timing text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get timing;

  /// Localized Instructions text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// Localized Notes text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Localized Profile text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Localized Patient name text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Patient name'**
  String get patientName;

  /// Localized Settings text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Localized Theme text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Localized Permissions text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// Localized Help and support text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Help and support'**
  String get helpAndSupport;

  /// Localized Log out text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// Localized Caregiver dashboard text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Caregiver dashboard'**
  String get caregiverDashboard;

  /// Localized Care overview text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Care overview'**
  String get careOverview;

  /// Localized Care overview subtitle text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Review connected patients and attention items.'**
  String get careOverviewSubtitle;

  /// Localized Add patient text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatient;

  /// Localized Connected patients text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Connected patients'**
  String get connectedPatients;

  /// Localized Needs attention text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needsAttention;

  /// Localized On track text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get onTrack;

  /// Localized Latest medication missed text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Latest: Medication missed'**
  String get latestMedicationMissed;

  /// Localized Latest dose taken text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Latest: Dose taken'**
  String get latestDoseTaken;

  /// No description provided for @dosesSummary.
  ///
  /// In en, this message translates to:
  /// **'Taken {taken} · Missed {missed} · Pending {pending}'**
  String dosesSummary(int taken, int missed, int pending);

  /// Localized Recent alerts text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Recent alerts'**
  String get recentAlerts;

  /// Localized Missed dose text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Missed dose'**
  String get missedDose;

  /// Localized Patient details text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Patient details'**
  String get patientDetails;

  /// Localized Care manage text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Care manage'**
  String get careManage;

  /// Localized Todays medications text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Today\'s medications'**
  String get todaysMedications;

  /// Localized Adherence text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherence;

  /// Localized History and alerts text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'History and alerts'**
  String get historyAndAlerts;

  /// Localized Care alerts text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Care alerts'**
  String get careAlerts;

  /// Localized No new alerts text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'No new alerts'**
  String get noNewAlerts;

  /// Localized Attention items appear here text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Attention items appear here.'**
  String get attentionItemsAppearHere;

  /// Localized Caregiver connection text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Caregiver connection'**
  String get caregiverConnection;

  /// Localized Connection state text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Connection state'**
  String get connectionState;

  /// Localized No linked patients text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'No linked patients'**
  String get noLinkedPatients;

  /// Localized Review patient and permission text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Review the patient and requested permission.'**
  String get reviewPatientAndPermission;

  /// Localized Patient id text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Patient ID'**
  String get patientId;

  /// Localized Placeholder user id text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Placeholder user ID'**
  String get placeholderUserId;

  /// Localized Request access text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Request Access'**
  String get requestAccess;

  /// Localized Patient text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// Localized Read only text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get readOnly;

  /// Localized Manage medications text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Manage medications'**
  String get manageMedications;

  /// Localized Pending text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Localized Waiting for approval text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval. No access is available yet.'**
  String get waitingForApproval;

  /// Localized Waiting for patient text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Waiting for patient'**
  String get waitingForPatient;

  /// Localized Approved text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// Localized Shown after approval text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Shown only after the approval checkpoint.'**
  String get shownAfterApproval;

  /// Localized Connected appears after approval text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Connected appears only after approval.'**
  String get connectedAppearsAfterApproval;

  /// Localized Good afternoon text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// Localized Good evening text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @greetingWithName.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingWithName(String greeting, String name);

  /// Localized Empty medications title text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'No medicines for today'**
  String get emptyMedicationsTitle;

  /// Localized Empty medications message text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Add a medicine to see your plan here.'**
  String get emptyMedicationsMessage;

  /// Localized All doses done text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'All done for today'**
  String get allDosesDone;

  /// Localized All doses done message text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'You have no more doses scheduled today.'**
  String get allDosesDoneMessage;

  /// Localized Retry text displayed in the interface.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
