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
  String get onboardingTitle1 => 'لا تفوّت أي دواء';

  @override
  String get onboardingSubtitle1 => 'تذكيرات لطيفة تبقي كل جرعة أمامك.';

  @override
  String get onboardingTitle2 => 'تابع رحلة علاجك';

  @override
  String get onboardingSubtitle2 => 'اطّلع على المواعيد والسجل والتقدم.';

  @override
  String get onboardingTitle3 => 'ابقَ على اتصال بمقدمي الرعاية';

  @override
  String get onboardingSubtitle3 => 'شارك فقط ما توافق عليه.';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInToContinue => 'سجّل الدخول للمتابعة.';

  @override
  String get emailOrPhone => 'البريد الإلكتروني أو رقم الهاتف';

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
}
