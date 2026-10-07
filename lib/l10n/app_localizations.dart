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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CureLink'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcome(String name);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Care that stays connected'**
  String get tagline;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @stepOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOfTotal(int current, int total);

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Never miss medication'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminders keep each dose visible'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track your medication journey'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'See schedules, history, and progress'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay connected with caregivers'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Share only what you approve'**
  String get onboardingSubtitle3;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue.'**
  String get signInToContinue;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or phone'**
  String get emailOrPhone;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your CureLink account to stay connected.'**
  String get createAccountSubtitle;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @enterYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhone;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmail;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @reEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reEnterPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @userSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'User session not found. Please login again.'**
  String get userSessionNotFound;

  /// No description provided for @couldNotSaveAgeGroup.
  ///
  /// In en, this message translates to:
  /// **'Could not save age group. Please try again.'**
  String get couldNotSaveAgeGroup;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get emailAlreadyRegistered;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get invalidCredentials;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authenticationFailed;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your information so CureLink can provide a better care experience.'**
  String get completeProfileSubtitle;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a profile photo'**
  String get tapToAddPhoto;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @basicProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'Your basic profile details'**
  String get basicProfileDetails;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must contain at least 2 characters'**
  String get nameMinLength;

  /// No description provided for @cureLinkId.
  ///
  /// In en, this message translates to:
  /// **'CureLink ID'**
  String get cureLinkId;

  /// No description provided for @caregiverConnectionIdHint.
  ///
  /// In en, this message translates to:
  /// **'Use this ID when connecting with caregivers'**
  String get caregiverConnectionIdHint;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get emergencyContact;

  /// No description provided for @emergencyContactHint.
  ///
  /// In en, this message translates to:
  /// **'Someone we can contact in an emergency'**
  String get emergencyContactHint;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get contactName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @pleaseEnterEmergencyContactName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the emergency contact name'**
  String get pleaseEnterEmergencyContactName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @pleaseEnterEmergencyPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter the emergency phone'**
  String get pleaseEnterEmergencyPhone;

  /// No description provided for @validPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validPhoneNumber;

  /// No description provided for @pleaseWaitGeneratingId.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we generate your unique CureLink ID.'**
  String get pleaseWaitGeneratingId;

  /// No description provided for @choosePhotoMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to add your photo'**
  String get choosePhotoMethod;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @selectPhotoFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Select a photo from your device'**
  String get selectPhotoFromDevice;

  /// No description provided for @useCamera.
  ///
  /// In en, this message translates to:
  /// **'Use camera'**
  String get useCamera;

  /// No description provided for @takeNewProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a new profile photo'**
  String get takeNewProfilePhoto;

  /// No description provided for @unableToSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Unable to select the image.'**
  String get unableToSelectImage;

  /// No description provided for @pleaseWaitIdGenerated.
  ///
  /// In en, this message translates to:
  /// **'Please wait until your CureLink ID is generated.'**
  String get pleaseWaitIdGenerated;

  /// No description provided for @profileCompleted.
  ///
  /// In en, this message translates to:
  /// **'Profile completed'**
  String get profileCompleted;

  /// No description provided for @profileCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your CureLink profile has been created successfully.'**
  String get profileCreatedSuccessfully;

  /// No description provided for @yourCureLinkId.
  ///
  /// In en, this message translates to:
  /// **'Your CureLink ID'**
  String get yourCureLinkId;

  /// No description provided for @firebasePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Firebase permission denied while generating CureLink ID.'**
  String get firebasePermissionDenied;

  /// No description provided for @noAuthenticatedUser.
  ///
  /// In en, this message translates to:
  /// **'No authenticated user found. Please login first.'**
  String get noAuthenticatedUser;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkError;

  /// No description provided for @unableToGenerateId.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate a unique CureLink ID.'**
  String get unableToGenerateId;

  /// No description provided for @profilePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to save this profile.'**
  String get profilePermissionDenied;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @idNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get idNotAvailable;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'This email address is not valid.'**
  String get invalidEmail;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get passwordResetEmailSent;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account was found with this email'**
  String get userNotFound;

  /// No description provided for @passwordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send password reset email'**
  String get passwordResetFailed;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 8 characters.'**
  String get weakPassword;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get noInternetConnection;

  /// No description provided for @emailSignupDisabled.
  ///
  /// In en, this message translates to:
  /// **'Email sign-up is not enabled in Firebase yet.'**
  String get emailSignupDisabled;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get tooManyAttempts;

  /// No description provided for @couldNotCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not create the account. Please try again.'**
  String get couldNotCreateAccount;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Account created, but we could not save your profile. Please try again.'**
  String get profileSaveFailed;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @noRouteDefined.
  ///
  /// In en, this message translates to:
  /// **'No route defined for {route}'**
  String noRouteDefined(String route);

  /// No description provided for @enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter details'**
  String get enterDetails;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @fieldError.
  ///
  /// In en, this message translates to:
  /// **'Check this field and try again.'**
  String get fieldError;

  /// No description provided for @fieldStates.
  ///
  /// In en, this message translates to:
  /// **'Field states'**
  String get fieldStates;

  /// No description provided for @stateDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get stateDefault;

  /// No description provided for @stateFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get stateFocus;

  /// No description provided for @stateFilled.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get stateFilled;

  /// No description provided for @stateError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get stateError;

  /// No description provided for @stateDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get stateDisabled;

  /// No description provided for @chooseYourRole.
  ///
  /// In en, this message translates to:
  /// **'Choose your role'**
  String get chooseYourRole;

  /// No description provided for @personaFirst.
  ///
  /// In en, this message translates to:
  /// **'Persona first'**
  String get personaFirst;

  /// No description provided for @ageGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the age group that fits you.'**
  String get ageGroupSubtitle;

  /// No description provided for @roleChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get roleChild;

  /// No description provided for @roleTeenAdult.
  ///
  /// In en, this message translates to:
  /// **'Teen / Adult'**
  String get roleTeenAdult;

  /// No description provided for @roleOlderAdult.
  ///
  /// In en, this message translates to:
  /// **'Older Adult'**
  String get roleOlderAdult;

  /// No description provided for @childRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Child is Patient only; invalid roles are not shown.'**
  String get childRoleHint;

  /// No description provided for @teenAdultRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Choose Patient, Caregiver, or Both. Both starts in Patient Mode.'**
  String get teenAdultRoleHint;

  /// No description provided for @olderAdultRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Older Adult is Patient only; invalid roles are not shown.'**
  String get olderAdultRoleHint;

  /// No description provided for @rolePatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get rolePatient;

  /// No description provided for @roleCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get roleCaregiver;

  /// No description provided for @roleBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get roleBoth;

  /// No description provided for @usePatientHint.
  ///
  /// In en, this message translates to:
  /// **'Use CureLink as a patient.'**
  String get usePatientHint;

  /// No description provided for @useCaregiverHint.
  ///
  /// In en, this message translates to:
  /// **'Use CureLink as a caregiver.'**
  String get useCaregiverHint;

  /// No description provided for @switchModesHint.
  ///
  /// In en, this message translates to:
  /// **'Switch modes when needed.'**
  String get switchModesHint;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete profile'**
  String get completeProfile;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @selectedRole.
  ///
  /// In en, this message translates to:
  /// **'Selected role'**
  String get selectedRole;

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'Age group'**
  String get ageGroup;

  /// No description provided for @userIdPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'User ID - placeholder'**
  String get userIdPlaceholder;

  /// No description provided for @generatedAfterSetup.
  ///
  /// In en, this message translates to:
  /// **'Generated after setup'**
  String get generatedAfterSetup;

  /// No description provided for @patientMode.
  ///
  /// In en, this message translates to:
  /// **'Patient Mode'**
  String get patientMode;

  /// No description provided for @caregiverMode.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Mode'**
  String get caregiverMode;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @medicationPlanToday.
  ///
  /// In en, this message translates to:
  /// **'Here is your medication plan for today.'**
  String get medicationPlanToday;

  /// No description provided for @nextDose.
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

  /// No description provided for @statusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get statusUpcoming;

  /// No description provided for @statusDueNow.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get statusDueNow;

  /// No description provided for @statusTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get statusTaken;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @todaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s progress'**
  String get todaysProgress;

  /// No description provided for @progressCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String progressCount(int done, int total);

  /// No description provided for @emergencySos.
  ///
  /// In en, this message translates to:
  /// **'Emergency / SOS'**
  String get emergencySos;

  /// No description provided for @olderHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your day, clearly planned'**
  String get olderHomeTitle;

  /// No description provided for @olderHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every next step is simple and visible.'**
  String get olderHomeSubtitle;

  /// No description provided for @confirmDose.
  ///
  /// In en, this message translates to:
  /// **'Confirm Dose'**
  String get confirmDose;

  /// No description provided for @medicationReminder.
  ///
  /// In en, this message translates to:
  /// **'Medication reminder'**
  String get medicationReminder;

  /// No description provided for @timeForYourMedication.
  ///
  /// In en, this message translates to:
  /// **'It\'s time for your medication'**
  String get timeForYourMedication;

  /// No description provided for @remindMeLater.
  ///
  /// In en, this message translates to:
  /// **'Remind me later'**
  String get remindMeLater;

  /// No description provided for @doseRecorded.
  ///
  /// In en, this message translates to:
  /// **'Dose recorded'**
  String get doseRecorded;

  /// No description provided for @doseComplete.
  ///
  /// In en, this message translates to:
  /// **'Dose complete'**
  String get doseComplete;

  /// No description provided for @progressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Progress has been updated.'**
  String get progressUpdated;

  /// No description provided for @childHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for today\'s mission?'**
  String get childHomeTitle;

  /// No description provided for @childHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One small step at a time. You\'ve got this!'**
  String get childHomeSubtitle;

  /// No description provided for @starsNextBadge.
  ///
  /// In en, this message translates to:
  /// **'{stars} stars · next badge at {target}'**
  String starsNextBadge(int stars, int target);

  /// No description provided for @missionProgress.
  ///
  /// In en, this message translates to:
  /// **'Mission progress'**
  String get missionProgress;

  /// No description provided for @myMission.
  ///
  /// In en, this message translates to:
  /// **'My mission'**
  String get myMission;

  /// No description provided for @markAsTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark as taken'**
  String get markAsTaken;

  /// No description provided for @starEarned.
  ///
  /// In en, this message translates to:
  /// **'Star earned!'**
  String get starEarned;

  /// No description provided for @braveRoutineBadge.
  ///
  /// In en, this message translates to:
  /// **'Brave Routine badge'**
  String get braveRoutineBadge;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get addMedicine;

  /// No description provided for @editMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit medicine'**
  String get editMedicine;

  /// No description provided for @deleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Delete medicine'**
  String get deleteMedicine;

  /// No description provided for @medicineDetails.
  ///
  /// In en, this message translates to:
  /// **'Medicine details'**
  String get medicineDetails;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication name'**
  String get medicationName;

  /// No description provided for @descriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Description placeholder.'**
  String get descriptionPlaceholder;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @conditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditions;

  /// No description provided for @timing.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get timing;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient name'**
  String get patientName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help and support'**
  String get helpAndSupport;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @caregiverDashboard.
  ///
  /// In en, this message translates to:
  /// **'Caregiver dashboard'**
  String get caregiverDashboard;

  /// No description provided for @careOverview.
  ///
  /// In en, this message translates to:
  /// **'Care overview'**
  String get careOverview;

  /// No description provided for @careOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review connected patients and attention items.'**
  String get careOverviewSubtitle;

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatient;

  /// No description provided for @connectedPatients.
  ///
  /// In en, this message translates to:
  /// **'Connected patients'**
  String get connectedPatients;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needsAttention;

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get onTrack;

  /// No description provided for @latestMedicationMissed.
  ///
  /// In en, this message translates to:
  /// **'Latest: Medication missed'**
  String get latestMedicationMissed;

  /// No description provided for @latestDoseTaken.
  ///
  /// In en, this message translates to:
  /// **'Latest: Dose taken'**
  String get latestDoseTaken;

  /// No description provided for @dosesSummary.
  ///
  /// In en, this message translates to:
  /// **'Taken {taken} · Missed {missed} · Pending {pending}'**
  String dosesSummary(int taken, int missed, int pending);

  /// No description provided for @recentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Recent alerts'**
  String get recentAlerts;

  /// No description provided for @missedDose.
  ///
  /// In en, this message translates to:
  /// **'Missed dose'**
  String get missedDose;

  /// No description provided for @patientDetails.
  ///
  /// In en, this message translates to:
  /// **'Patient details'**
  String get patientDetails;

  /// No description provided for @careManage.
  ///
  /// In en, this message translates to:
  /// **'Care manage'**
  String get careManage;

  /// No description provided for @todaysMedications.
  ///
  /// In en, this message translates to:
  /// **'Today\'s medications'**
  String get todaysMedications;

  /// No description provided for @adherence.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherence;

  /// No description provided for @historyAndAlerts.
  ///
  /// In en, this message translates to:
  /// **'History and alerts'**
  String get historyAndAlerts;

  /// No description provided for @careAlerts.
  ///
  /// In en, this message translates to:
  /// **'Care alerts'**
  String get careAlerts;

  /// No description provided for @noNewAlerts.
  ///
  /// In en, this message translates to:
  /// **'No new alerts'**
  String get noNewAlerts;

  /// No description provided for @attentionItemsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Attention items appear here.'**
  String get attentionItemsAppearHere;

  /// No description provided for @caregiverConnection.
  ///
  /// In en, this message translates to:
  /// **'Caregiver connection'**
  String get caregiverConnection;

  /// No description provided for @connectionState.
  ///
  /// In en, this message translates to:
  /// **'Connection state'**
  String get connectionState;

  /// No description provided for @noLinkedPatients.
  ///
  /// In en, this message translates to:
  /// **'No linked patients'**
  String get noLinkedPatients;

  /// No description provided for @reviewPatientAndPermission.
  ///
  /// In en, this message translates to:
  /// **'Review the patient and requested permission.'**
  String get reviewPatientAndPermission;

  /// No description provided for @patientId.
  ///
  /// In en, this message translates to:
  /// **'Patient ID'**
  String get patientId;

  /// No description provided for @placeholderUserId.
  ///
  /// In en, this message translates to:
  /// **'Placeholder user ID'**
  String get placeholderUserId;

  /// No description provided for @requestAccess.
  ///
  /// In en, this message translates to:
  /// **'Request Access'**
  String get requestAccess;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @readOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get readOnly;

  /// No description provided for @manageMedications.
  ///
  /// In en, this message translates to:
  /// **'Manage medications'**
  String get manageMedications;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @waitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval. No access is available yet.'**
  String get waitingForApproval;

  /// No description provided for @waitingForPatient.
  ///
  /// In en, this message translates to:
  /// **'Waiting for patient'**
  String get waitingForPatient;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @shownAfterApproval.
  ///
  /// In en, this message translates to:
  /// **'Shown only after the approval checkpoint.'**
  String get shownAfterApproval;

  /// No description provided for @connectedAppearsAfterApproval.
  ///
  /// In en, this message translates to:
  /// **'Connected appears only after approval.'**
  String get connectedAppearsAfterApproval;
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
