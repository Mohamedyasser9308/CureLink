import 'package:curelink/core/services/dose_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AlarmPermissionsPage extends StatefulWidget {
  const AlarmPermissionsPage({super.key});

  @override
  State<AlarmPermissionsPage> createState() => _AlarmPermissionsPageState();
}

class _AlarmPermissionsPageState extends State<AlarmPermissionsPage>
    with WidgetsBindingObserver {
  Map<String, dynamic> _permissions = const {};
  bool _loading = true;
  bool _openingSettings = false;

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh(resync: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh(resync: true);
  }

  Future<void> _refresh({bool resync = false}) async {
    try {
      await DoseNotificationService.instance.refreshAndroidPermissionState();
      final statuses = await DoseNotificationService.instance
          .getAndroidAlarmPermissionStatus();
      if (!mounted) return;
      setState(() {
        _permissions = statuses;
        _loading = false;
      });
      if (resync) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await DoseNotificationService.instance.syncPatientSchedule(uid);
          final updated = await DoseNotificationService.instance
              .getAndroidAlarmPermissionStatus();
          if (mounted) setState(() => _permissions = updated);
        }
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isArabic
            ? 'تعذر قراءة صلاحيات المنبه: $error'
            : 'Could not read alarm permissions: $error'),
      ));
    }
  }

  Future<void> _openSetting(String kind) async {
    if (_openingSettings) return;
    setState(() => _openingSettings = true);
    try {
      await DoseNotificationService.instance
          .openAndroidAlarmPermissionSettings(kind);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isArabic
              ? 'افتح إعدادات التطبيق واسمح بهذا الإذن. ($error)'
              : 'Open app settings and allow this permission. ($error)'),
        ));
      }
    } finally {
      if (mounted) setState(() => _openingSettings = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _isArabic;
    final colors = Theme.of(context).colorScheme;
    if (defaultTargetPlatform != TargetPlatform.android) {
      return Scaffold(
        appBar: AppBar(title: Text(isArabic ? 'صلاحيات المنبه' : 'Alarm permissions')),
        body: Center(
          child: Text(isArabic
              ? 'إعدادات هذه الصفحة متاحة لأجهزة Android.'
              : 'These settings are available on Android devices.'),
        ),
      );
    }

    final rows = <({String key, String title, String detail, IconData icon})>[
      (key: 'notifications', title: isArabic ? 'الإشعارات' : 'Notifications',
        detail: isArabic ? 'السماح بإظهار إشعار الجرعة.' : 'Allow medication reminder notifications.',
        icon: Icons.notifications_active_outlined),
      (key: 'nativeAlarmChannel', title: isArabic ? 'إشعار المنبه الأساسي' : 'System alarm notification',
        detail: isArabic ? 'إشعار Android الذي يظهر عندما يرن المنبه.' : 'The Android notification shown when the alarm rings.',
        icon: Icons.notification_important_outlined),
      (key: 'exactAlarms', title: isArabic ? 'المنبهات والتذكيرات' : 'Alarms & reminders',
        detail: isArabic ? 'لضبط موعد الجرعة بدقة حتى مع وضع توفير الطاقة.' : 'For precise dose times, including while the phone is idle.',
        icon: Icons.alarm),
      (key: 'fullScreen', title: isArabic ? 'عرض المنبه على شاشة القفل' : 'Full-screen alarm',
        detail: isArabic ? 'لإظهار شاشة الجرعة عند قفل الهاتف.' : 'Show the dose screen over the lock screen.',
        icon: Icons.lock_open_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'صلاحيات المنبه' : 'Alarm permissions')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
                  onRefresh: () => _refresh(resync: true),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(isArabic
                          ? 'Android يختلف من شركة لأخرى. راجع كل حالة هنا، واضغط سماح لفتح صفحة الإعداد الصحيحة على جهازك.'
                          : 'Android settings vary by manufacturer. Check each status here and tap Allow to open the matching settings page.'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_available_outlined),
                      title: Text(isArabic ? 'التذكيرات المسجلة' : 'Scheduled reminders'),
                      subtitle: Text(_scheduledAlarmSummary(isArabic)),
                      trailing: TextButton(
                        onPressed: _loading ? null : () => _refresh(resync: true),
                        child: Text(isArabic ? 'إعادة الضبط' : 'Rebuild'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final row in rows)
                    Card(
                      child: ListTile(
                        leading: Icon(row.icon, color: colors.primary),
                        title: Text(row.title),
                        subtitle: Text(row.detail),
                        trailing: _permissions[row.key] == true
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : TextButton(
                                onPressed: _openingSettings
                                    ? null
                                    : () => _openSetting(row.key),
                                child: Text(isArabic ? 'سماح' : 'Allow'),
                              ),
                      ),
                    ),
                  if (_permissions['batteryOptimizationIgnored'] != true)
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.battery_saver_outlined, color: colors.primary),
                        title: Text(isArabic
                            ? 'استثناء توفير البطارية (اختياري)'
                            : 'Battery optimization exemption (optional)'),
                        subtitle: Text(isArabic
                            ? 'قد تحتاج بعض الأجهزة لهذه الخطوة حتى لا تؤخر الشركة المصنعة التنبيه.'
                            : 'Some manufacturers may delay alarms unless this app is exempted.'),
                        trailing: TextButton(
                          onPressed: _openingSettings ? null : () => _openSetting('battery'),
                          child: Text(isArabic ? 'فتح' : 'Open'),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : () => _refresh(resync: true),
                    icon: const Icon(Icons.refresh),
                    label: Text(isArabic ? 'إعادة الفحص' : 'Check again'),
                  ),
                ],
              ),
            ),
    );
  }

  String _scheduledAlarmSummary(bool isArabic) {
    final count = _permissions['scheduledAlarmCount'] as int? ?? 0;
    final nextMillis = _permissions['nextAlarmMillis'] as int?;
    final countLabel = isArabic ? 'عدد المنبهات الأصلية: $count' : 'Native alarms scheduled: $count';
    if (nextMillis == null) {
      return '$countLabel\n${isArabic ? 'لا يوجد موعد قادم مسجل على هذا الجهاز.' : 'No upcoming alarm is registered on this device.'}';
    }
    final next = DateTime.fromMillisecondsSinceEpoch(nextMillis).toLocal();
    final time = MaterialLocalizations.of(context).formatFullDate(next);
    final clock = MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(next));
    return '$countLabel\n${isArabic ? 'التالي: $time، $clock' : 'Next: $time at $clock'}';
  }
}
