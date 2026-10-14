// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'كيور لينك';

  @override
  String welcome(String name) {
    return 'مرحباً، $name!';
  }

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get tagline => 'رعاية تبقى متصلة';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get continueButton => 'متابعة';

  @override
  String get done => 'تم';

  @override
  String stepOfTotal(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get onboardingTitle1 => 'لا تفوّت أي جرعة';

  @override
  String get onboardingSubtitle1 =>
      'تذكيرات لطيفة تساعدك على تناول كل جرعة في موعدها';

  @override
  String get onboardingTitle2 => 'تابع رحلة أدويتك';

  @override
  String get onboardingSubtitle2 => 'اطّلع على المواعيد والسجل والتقدم';

  @override
  String get onboardingTitle3 => 'ابقَ على تواصل مع مقدمي الرعاية';

  @override
  String get onboardingSubtitle3 => 'شارك فقط ما توافق عليه';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInToContinue => 'سجّل الدخول للمتابعة.';

  @override
  String get emailOrPhone => 'البريد الإلكتروني أو رقم الهاتف';

  @override
  String get createAccountSubtitle =>
      'أنشئ حسابك في كيور لينك للبقاء على اتصال.';

  @override
  String get enterYourName => 'أدخل اسمك';

  @override
  String get enterYourPhone => 'أدخل رقم هاتفك';

  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get createPassword => 'أنشئ كلمة مرور';

  @override
  String get reEnterPassword => 'أعد إدخال كلمة المرور';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get somethingWentWrong => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get userSessionNotFound =>
      'لم يتم العثور على جلسة المستخدم. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get couldNotSaveAgeGroup =>
      'تعذر حفظ الفئة العمرية. يرجى المحاولة مرة أخرى.';

  @override
  String get emailAlreadyRegistered => 'هذا البريد الإلكتروني مسجل بالفعل.';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get loginEmailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get loginPasswordHint => 'أدخل كلمة المرور';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get invalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authenticationFailed =>
      'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.';

  @override
  String get completeProfileSubtitle =>
      'أضف معلوماتك حتى يتمكن كيور لينك من تقديم تجربة رعاية أفضل.';

  @override
  String get tapToAddPhoto => 'اضغط لإضافة صورة شخصية';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get basicProfileDetails => 'بيانات ملفك الشخصي الأساسية';

  @override
  String get pleaseEnterName => 'يرجى إدخال اسمك';

  @override
  String get nameMinLength => 'يجب أن يحتوي الاسم على حرفين على الأقل';

  @override
  String get cureLinkId => 'معرّف كيور لينك';

  @override
  String get caregiverConnectionIdHint =>
      'استخدم هذا المعرّف عند الارتباط بمقدمي الرعاية';

  @override
  String get emergencyContact => 'جهة اتصال للطوارئ';

  @override
  String get emergencyContactHint => 'شخص يمكننا التواصل معه في حالات الطوارئ';

  @override
  String get contactName => 'اسم جهة الاتصال';

  @override
  String get enterFullName => 'أدخل الاسم الكامل';

  @override
  String get pleaseEnterEmergencyContactName =>
      'يرجى إدخال اسم جهة اتصال الطوارئ';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get enterPhoneNumber => 'أدخل رقم الهاتف';

  @override
  String get pleaseEnterEmergencyPhone => 'يرجى إدخال رقم هاتف الطوارئ';

  @override
  String get validPhoneNumber => 'أدخل رقم هاتف صالح';

  @override
  String get pleaseWaitGeneratingId =>
      'يرجى الانتظار حتى ننشئ معرّف كيور لينك الخاص بك.';

  @override
  String get choosePhotoMethod => 'اختر الطريقة التي تريد بها إضافة صورتك';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get selectPhotoFromDevice => 'اختر صورة من جهازك';

  @override
  String get useCamera => 'استخدام الكاميرا';

  @override
  String get takeNewProfilePhoto => 'التقاط صورة شخصية جديدة';

  @override
  String get unableToSelectImage => 'تعذر اختيار الصورة.';

  @override
  String get pleaseWaitIdGenerated =>
      'يرجى الانتظار حتى يتم إنشاء معرّف كيور لينك الخاص بك.';

  @override
  String get profileCompleted => 'اكتمل الملف الشخصي';

  @override
  String get profileCreatedSuccessfully =>
      'تم إنشاء ملفك الشخصي في كيور لينك بنجاح.';

  @override
  String get yourCureLinkId => 'معرّف كيور لينك الخاص بك';

  @override
  String get firebasePermissionDenied =>
      'تم رفض صلاحية Firebase أثناء إنشاء معرّف كيور لينك.';

  @override
  String get noAuthenticatedUser =>
      'لم يتم العثور على مستخدم مسجل الدخول. يرجى تسجيل الدخول أولاً.';

  @override
  String get networkError =>
      'حدث خطأ في الشبكة. يرجى التحقق من اتصال الإنترنت.';

  @override
  String get unableToGenerateId => 'تعذر إنشاء معرّف كيور لينك فريد.';

  @override
  String get profilePermissionDenied =>
      'ليس لديك صلاحية لحفظ هذا الملف الشخصي.';

  @override
  String get sessionExpired =>
      'انتهت جلسة المستخدم. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get idNotAvailable => 'غير متاح';

  @override
  String get invalidEmail => 'عنوان البريد الإلكتروني غير صالح.';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get passwordResetEmailSent =>
      'تم إرسال بريد إعادة تعيين كلمة المرور. تحقق من بريدك الإلكتروني.';

  @override
  String get userNotFound => 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';

  @override
  String get passwordResetFailed => 'تعذر إرسال بريد إعادة تعيين كلمة المرور';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جدًا. استخدم 8 أحرف على الأقل.';

  @override
  String get noInternetConnection =>
      'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مرة أخرى.';

  @override
  String get emailSignupDisabled =>
      'التسجيل باستخدام البريد الإلكتروني غير مفعّل في Firebase بعد.';

  @override
  String get tooManyAttempts =>
      'محاولات كثيرة جدًا. انتظر قليلاً ثم حاول مرة أخرى.';

  @override
  String get couldNotCreateAccount =>
      'تعذر إنشاء الحساب. يرجى المحاولة مرة أخرى.';

  @override
  String get profileSaveFailed =>
      'تم إنشاء الحساب، لكن تعذر حفظ ملفك الشخصي. يرجى المحاولة مرة أخرى.';

  @override
  String get pageNotFound => 'الصفحة غير موجودة';

  @override
  String noRouteDefined(String route) {
    return 'لا يوجد مسار معرف لـ $route';
  }

  @override
  String get enterDetails => 'أدخل البيانات';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get fieldError => 'تحقق من هذا الحقل وحاول مرة أخرى.';

  @override
  String get fieldStates => 'حالات الحقول';

  @override
  String get stateDefault => 'افتراضي';

  @override
  String get stateFocus => 'نشط';

  @override
  String get stateFilled => 'ممتلئ';

  @override
  String get stateError => 'خطأ';

  @override
  String get stateDisabled => 'معطّل';

  @override
  String get chooseYourRole => 'اختر دورك';

  @override
  String get personaFirst => 'الشخصية أولاً';

  @override
  String get ageGroupSubtitle => 'اختر الفئة العمرية المناسبة لك.';

  @override
  String get roleChild => 'طفل';

  @override
  String get roleTeenAdult => 'مراهق / بالغ';

  @override
  String get roleOlderAdult => 'كبير السن';

  @override
  String get childRoleHint => 'الطفل مريض فقط؛ لا تظهر الأدوار غير الصالحة.';

  @override
  String get teenAdultRoleHint =>
      'اختر مريض أو مقدم رعاية أو كليهما. الوضع الافتراضي عند اختيار كليهما هو وضع المريض.';

  @override
  String get olderAdultRoleHint =>
      'كبير السن مريض فقط؛ لا تظهر الأدوار غير الصالحة.';

  @override
  String get rolePatient => 'مريض';

  @override
  String get roleCaregiver => 'مقدم رعاية';

  @override
  String get roleBoth => 'كلاهما';

  @override
  String get usePatientHint => 'استخدم كيور لينك كمريض.';

  @override
  String get useCaregiverHint => 'استخدم كيور لينك كمقدم رعاية.';

  @override
  String get switchModesHint => 'بدّل بين الوضعين عند الحاجة.';

  @override
  String get completeProfile => 'أكمل ملفك الشخصي';

  @override
  String get profilePhoto => 'الصورة الشخصية';

  @override
  String get selectedRole => 'الدور المختار';

  @override
  String get ageGroup => 'الفئة العمرية';

  @override
  String get userIdPlaceholder => 'معرّف المستخدم - مؤقت';

  @override
  String get generatedAfterSetup => 'يُنشأ بعد الإعداد';

  @override
  String get patientMode => 'وضع المريض';

  @override
  String get caregiverMode => 'وضع مقدم الرعاية';

  @override
  String get saveProfile => 'حفظ الملف الشخصي';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSchedule => 'الجدول';

  @override
  String get navCalendar => 'التقويم';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غداً';

  @override
  String get all => 'الكل';

  @override
  String get morning => 'الصباح';

  @override
  String get evening => 'المساء';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get medicationPlanToday => 'هذه خطة أدويتك لليوم.';

  @override
  String get nextDose => 'الجرعة التالية';

  @override
  String inDuration(String time) {
    return 'بعد $time';
  }

  @override
  String scheduledTime(String time) {
    return 'الموعد المحدد · $time';
  }

  @override
  String get statusUpcoming => 'قادمة';

  @override
  String get statusDueNow => 'حان وقتها';

  @override
  String get statusTaken => 'تم تناولها';

  @override
  String get statusMissed => 'فائتة';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get todaysProgress => 'تقدم اليوم';

  @override
  String progressCount(int done, int total) {
    return '$done من $total';
  }

  @override
  String get emergencySos => 'طوارئ / SOS';

  @override
  String get olderHomeTitle => 'يومك مخطط بوضوح';

  @override
  String get olderHomeSubtitle => 'كل خطوة تالية بسيطة وواضحة.';

  @override
  String get confirmDose => 'تأكيد الجرعة';

  @override
  String get medicationReminder => 'تذكير بالدواء';

  @override
  String get timeForYourMedication => 'حان وقت دوائك';

  @override
  String get remindMeLater => 'ذكّرني لاحقاً';

  @override
  String get doseRecorded => 'تم تسجيل الجرعة';

  @override
  String get doseComplete => 'اكتملت الجرعة';

  @override
  String get progressUpdated => 'تم تحديث التقدم.';

  @override
  String get childHomeTitle => 'هل أنت جاهز لمهمة اليوم؟';

  @override
  String get childHomeSubtitle => 'خطوة صغيرة في كل مرة. أنت قادر على ذلك!';

  @override
  String starsNextBadge(int stars, int target) {
    return '$stars نجوم · الشارة التالية عند $target';
  }

  @override
  String get missionProgress => 'تقدم المهمة';

  @override
  String get myMission => 'مهمتي';

  @override
  String get markAsTaken => 'تحديد كمأخوذ';

  @override
  String get starEarned => 'ربحت نجمة!';

  @override
  String get braveRoutineBadge => 'شارة الروتين الشجاع';

  @override
  String get addMedicine => 'إضافة دواء';

  @override
  String get editMedicine => 'تعديل الدواء';

  @override
  String get deleteMedicine => 'حذف الدواء';

  @override
  String get medicineDetails => 'تفاصيل الدواء';

  @override
  String get medicationName => 'اسم الدواء';

  @override
  String get descriptionPlaceholder => 'نص الوصف.';

  @override
  String get dose => 'الجرعة';

  @override
  String get quantity => 'الكمية';

  @override
  String get time => 'الوقت';

  @override
  String get frequency => 'التكرار';

  @override
  String get duration => 'المدة';

  @override
  String get conditions => 'الحالات';

  @override
  String get timing => 'التوقيت';

  @override
  String get instructions => 'التعليمات';

  @override
  String get notes => 'ملاحظات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get patientName => 'اسم المريض';

  @override
  String get settings => 'الإعدادات';

  @override
  String get theme => 'المظهر';

  @override
  String get permissions => 'الأذونات';

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get caregiverDashboard => 'لوحة مقدم الرعاية';

  @override
  String get careOverview => 'نظرة عامة على الرعاية';

  @override
  String get careOverviewSubtitle =>
      'راجع المرضى المرتبطين والعناصر التي تحتاج انتباهاً.';

  @override
  String get addPatient => 'إضافة مريض';

  @override
  String get connectedPatients => 'المرضى المرتبطون';

  @override
  String get needsAttention => 'يحتاج انتباهاً';

  @override
  String get onTrack => 'على المسار الصحيح';

  @override
  String get latestMedicationMissed => 'الأحدث: دواء فائت';

  @override
  String get latestDoseTaken => 'الأحدث: تم تناول الجرعة';

  @override
  String dosesSummary(int taken, int missed, int pending) {
    return 'تم تناولها $taken · فائتة $missed · قيد الانتظار $pending';
  }

  @override
  String get recentAlerts => 'أحدث التنبيهات';

  @override
  String get missedDose => 'جرعة فائتة';

  @override
  String get patientDetails => 'تفاصيل المريض';

  @override
  String get careManage => 'إدارة الرعاية';

  @override
  String get todaysMedications => 'أدوية اليوم';

  @override
  String get adherence => 'الالتزام';

  @override
  String get historyAndAlerts => 'السجل والتنبيهات';

  @override
  String get careAlerts => 'تنبيهات الرعاية';

  @override
  String get noNewAlerts => 'لا توجد تنبيهات جديدة';

  @override
  String get attentionItemsAppearHere =>
      'تظهر العناصر التي تحتاج انتباهاً هنا.';

  @override
  String get caregiverConnection => 'الارتباط بمقدم الرعاية';

  @override
  String get connectionState => 'حالة الارتباط';

  @override
  String get noLinkedPatients => 'لا يوجد مرضى مرتبطون';

  @override
  String get reviewPatientAndPermission => 'راجع المريض والإذن المطلوب.';

  @override
  String get patientId => 'معرّف المريض';

  @override
  String get placeholderUserId => 'معرّف المستخدم المؤقت';

  @override
  String get requestAccess => 'طلب الوصول';

  @override
  String get patient => 'المريض';

  @override
  String get readOnly => 'للقراءة فقط';

  @override
  String get manageMedications => 'إدارة الأدوية';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get waitingForApproval =>
      'في انتظار الموافقة. لا يتوفر أي وصول حالياً.';

  @override
  String get waitingForPatient => 'في انتظار المريض';

  @override
  String get approved => 'تمت الموافقة';

  @override
  String get shownAfterApproval => 'يظهر فقط بعد نقطة الموافقة.';

  @override
  String get connectedAppearsAfterApproval =>
      'تظهر حالة الارتباط فقط بعد الموافقة.';

  @override
  String get goodAfternoon => 'نهارك سعيد';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting، $name';
  }

  @override
  String get emptyMedicationsTitle => 'لا توجد أدوية لليوم';

  @override
  String get emptyMedicationsMessage => 'أضف دواءً لتظهر خطتك هنا.';

  @override
  String get allDosesDone => 'أنهيت جرعات اليوم';

  @override
  String get allDosesDoneMessage => 'لا توجد جرعات أخرى مجدولة اليوم.';

  @override
  String get retry => 'حاول مرة أخرى';
}
