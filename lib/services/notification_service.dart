import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';
import '../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result ?? false;
  }

  // Schedule notifications for a task
  Future<void> scheduleTaskNotifications(Task task) async {
    await cancelTaskNotifications(task.id);

    if (task.notifyAtStart && task.startTime != null) {
      await _scheduleNotification(
        id: _getTaskStartId(task.id),
        title: '${task.title} - do a thing',
        body: 'Time to lock in twin! Get off your ass!',
        scheduledDate: task.startTime!,
      );
    }

    if (task.notifyAtEnd && task.endTime != null) {
      await _scheduleNotification(
        id: _getTaskEndId(task.id),
        title: '${task.title} - done a thing',
        body: 'Good looks twin! Unless you\'re not done...',
        scheduledDate: task.endTime!,
      );
    }
  }

  // Schedule notifications for a habit (only for today)
  Future<void> scheduleHabitNotifications(Habit habit, DateTime date) async {
    await cancelHabitNotifications(habit.id, date);

    // Only schedule if habit is scheduled for this day
    final dayOfWeek = date.weekday % 7;
    if (!habit.selectedDays.contains(dayOfWeek)) return;

    if (habit.notifyAtStart && habit.startTime != null) {
      final notificationTime = DateTime(
        date.year,
        date.month,
        date.day,
        habit.startTime!.hour,
        habit.startTime!.minute,
      );

      await _scheduleNotification(
        id: _getHabitStartId(habit.id, date),
        title: '${habit.title} - AGAIN!',
        body:
            'Time to pick up a new habit that isn\'t stuffing your face tubs!',
        scheduledDate: notificationTime,
      );
    }

    if (habit.notifyAtEnd && habit.endTime != null) {
      final notificationTime = DateTime(
        date.year,
        date.month,
        date.day,
        habit.endTime!.hour,
        habit.endTime!.minute,
      );

      await _scheduleNotification(
        id: _getHabitEndId(habit.id, date),
        title: '${habit.title} - chillin',
        body: 'Keep it up to de-chudify!',
        scheduledDate: notificationTime,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Don't schedule if time has already passed
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelTaskNotifications(String taskId) async {
    await _notifications.cancel(_getTaskStartId(taskId));
    await _notifications.cancel(_getTaskEndId(taskId));
  }

  Future<void> cancelHabitNotifications(String habitId, DateTime date) async {
    await _notifications.cancel(_getHabitStartId(habitId, date));
    await _notifications.cancel(_getHabitEndId(habitId, date));
  }

  // Generate unique notification IDs
  int _getTaskStartId(String taskId) {
    return taskId.hashCode & 0x7FFFFFFF; // Ensure positive int
  }

  int _getTaskEndId(String taskId) {
    return (taskId.hashCode + 1) & 0x7FFFFFFF;
  }

  int _getHabitStartId(String habitId, DateTime date) {
    return ('$habitId-${date.year}-${date.month}-${date.day}'.hashCode) &
        0x7FFFFFFF;
  }

  int _getHabitEndId(String habitId, DateTime date) {
    return ('$habitId-${date.year}-${date.month}-${date.day}-end'.hashCode) &
        0x7FFFFFFF;
  }

  // Reschedule all habit notifications for today
  Future<void> rescheduleAllHabitsForToday(List<Habit> habits) async {
    final today = DateTime.now();
    for (var habit in habits) {
      await scheduleHabitNotifications(habit, today);
    }
  }
}
