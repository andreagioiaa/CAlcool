import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);

    await _flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    bool? granted;
    try {
      final androidImplementation = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final notificationsGranted = await androidImplementation.requestNotificationsPermission();
        final exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission();
        granted = (notificationsGranted ?? false) || (exactAlarmGranted ?? false);
      } else {
        final iosImplementation = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (iosImplementation != null) {
          granted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      }
    } catch (e) {
      granted = false;
    }
    return granted ?? false;
  }

  Future<void> scheduleSobrietyNotification(DateTime time) async {
    if (!_isInitialized) await init();
    
    await cancelSobrietyNotification(); // Cancel existing

    if (time.isBefore(DateTime.now())) return;

    final scheduledTime = tz.TZDateTime.from(time, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0, // Fixed ID for sobriety notification
        title: 'CAlcool: ora sei "sobrio"! 🍻',
        body: 'Puoi guidare! (limite sceso sotto 0.5 - accertarsi con strumenti verificati per sicurezza personale)',
        scheduledDate: scheduledTime,
        notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
                'sobriety_channel_id', 
                'Sobrietà',
                channelDescription: 'Notifiche quando il BAC scende sotto lo 0.5',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  Future<void> cancelSobrietyNotification() async {
    if (!_isInitialized) await init();
    await _flutterLocalNotificationsPlugin.cancel(id: 0);
  }

  Future<void> showOngoingBacNotification(double bac, DateTime? timeTo05, DateTime? timeTo00) async {
    if (!_isInitialized) await init();
    
    if (bac <= 0.0) {
      await cancelOngoingBacNotification();
      return;
    }

    String title = 'CAlcool: Livello Alcolico';
    String body = '';
    
    if (bac > 0.5) {
      final timeStr = timeTo05 != null ? '${timeTo05.hour.toString().padLeft(2, '0')}:${timeTo05.minute.toString().padLeft(2, '0')}' : '--:--';
      body = 'BAC: ${bac.toStringAsFixed(3)} g/l | Rientro sotto 0.5 stimato alle $timeStr';
    } else {
      final timeStr = timeTo00 != null ? '${timeTo00.hour.toString().padLeft(2, '0')}:${timeTo00.minute.toString().padLeft(2, '0')}' : '--:--';
      body = 'BAC: ${bac.toStringAsFixed(3)} g/l | Smaltimento totale alle $timeStr';
    }

    await _flutterLocalNotificationsPlugin.show(
      id: 1, // Ongoing notification ID
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'ongoing_bac_channel_id',
          'Tasso Alcolico Attuale',
          channelDescription: 'Mostra il tasso alcolico attuale e il tempo stimato di rientro',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        )
      )
    );
  }

  Future<void> cancelOngoingBacNotification() async {
    if (!_isInitialized) await init();
    await _flutterLocalNotificationsPlugin.cancel(id: 1);
  }
}
