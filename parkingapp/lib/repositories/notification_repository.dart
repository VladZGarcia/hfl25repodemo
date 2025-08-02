import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:parkingapp/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.request();
    print('Notification permission status: $status');

    // On Android 12 and above, also request exact alarm permission
    if (await Permission.scheduleExactAlarm.shouldShowRequestRationale) {
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      print('Exact alarm permission status: $alarmStatus');
    }

    // Always request exact alarm permission explicitly
    try {
      await Permission.scheduleExactAlarm.request();
      print('Exact alarm permission requested');
    } catch (e) {
      print('Error requesting exact alarm permission: $e');
    }
  }
}

Future<void> requestPermissions() async {
  if (Platform.isIOS) {
    final impl =
        notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    await impl?.requestPermissions(alert: true, badge: true, sound: true);
  }
  if (Platform.isMacOS) {
    final impl =
        notificationsPlugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
    await impl?.requestPermissions(alert: true, badge: true, sound: true);
  }
  if (Platform.isAndroid) {
    final impl =
        notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await impl?.requestNotificationsPermission();
  }
}

Future<void> scheduleNotification({
  required String title,
  required String content,
  required DateTime deliveryTime,
  required int id,
}) async {
  try {
    await requestNotificationPermission();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime.from(deliveryTime, tz.local);

    print('Current time: $now');
    print('Scheduled time: $scheduledDate');
    print('Device timezone: ${DateTime.now().timeZoneName}');
    print('TZ local timezone: ${tz.local.name}');
    print('Notification scheduled for: ${scheduledDate.toString()}');
    final androidDetails = AndroidNotificationDetails(
      'parking_reminder_channel',
      'Parking Reminders',
      channelDescription: 'Notifications for parking session end times',
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
      playSound: true, // Use default sound instead of custom
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      content,
      scheduledDate,
      notificationDetails,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // Make sure this is set
      matchDateTimeComponents: null,
    );

    print('Notification scheduled successfully');
  } catch (e, stackTrace) {
    print('Error scheduling notification: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

Future<void> cancelNotification(int id) async {
  await notificationsPlugin.cancel(id);
}

Future<void> androidNotification() async {
  try {
    await requestNotificationPermission();

    final androidDetails = AndroidNotificationDetails(
      'important_alarms', // Channel ID
      'Important Alarms', // Channel Name
      channelDescription: 'Notifications for parking alerts',
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      showWhen: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      icon: '@mipmap/ic_launcher',
      channelShowBadge: true,
    );

    final details = NotificationDetails(android: androidDetails);

    // Schedule for 15 seconds in the future for testing
    final scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(seconds: 15));

    print('Attempting to schedule notification...');
    print('Current time: ${tz.TZDateTime.now(tz.local)}');
    print('Scheduled time: $scheduledTime');

    await notificationsPlugin.zonedSchedule(
      0,
      "Test Notification",
      "This should appear in 15 seconds",
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // Also try an immediate notification
    await notificationsPlugin.show(
      1,
      "Immediate Test 2",
      "This should appear immediately",
      details,
    );

    print('Both notifications scheduled successfully');
  } catch (e, stack) {
    print('Error scheduling notification: $e');
    print('Stack trace: $stack');
  }
}

Future<void> scheduleParkedNotifications({
  required String vehicleRegistration,
  required String parkingSpace,
  required DateTime startTime,
  required DateTime endTime,
  required String parkingId,
}) async {
  try {
    // Convert parkingId to a consistent integer hash for notification ID
    final baseId = parkingId.hashCode;

    // 1. Schedule notification for 30 seconds before end time (keep as is)
    final endReminder = endTime.subtract(const Duration(seconds: 30));

    // Only schedule if it's in the future
    if (endReminder.isAfter(DateTime.now())) {
      await scheduleNotification(
        title: 'Parking Ending Soon',
        content:
            'Your parking for $vehicleRegistration at $parkingSpace will end in 15 seconds.',
        deliveryTime: endReminder,
        id: baseId, // Use base ID for end notification
      );
      print('End reminder scheduled for $endReminder');
    }

    // 2. Schedule minute reminders instead of hourly reminders
    final Duration parkingDuration = endTime.difference(startTime);
    final int totalMinutes = parkingDuration.inMinutes;

    // Schedule a reminder every minute (adjust as needed)
    const int reminderInterval = 1; // 1 minute between notifications

    // Calculate how many reminders to send (max 10 for testing)
    final int maxReminders = 10;
    final int reminderCount = (totalMinutes / reminderInterval).floor();
    final int remindersToSchedule =
        reminderCount > maxReminders ? maxReminders : reminderCount;

    for (int i = 1; i <= remindersToSchedule; i++) {
      // Calculate time for this minute reminder
      final reminderTime = startTime.add(
        Duration(minutes: i * reminderInterval),
      );

      // Skip if too close to end time or in the past
      if (reminderTime.isAfter(endReminder) ||
          reminderTime.isBefore(DateTime.now())) {
        continue;
      }

      // Calculate minutes remaining
      final minutesRemaining = totalMinutes - (i * reminderInterval);

      await scheduleNotification(
        title: 'Parking Update',
        content:
            minutesRemaining > 0
                ? 'Your parking for $vehicleRegistration has $minutesRemaining minutes remaining.'
                : 'Your parking for $vehicleRegistration is ending this minute.',
        deliveryTime: reminderTime,
        id: baseId + i, // Use base ID + index offset for minute notifications
      );
      print(
        'Minute reminder $i scheduled for $reminderTime (${minutesRemaining} minutes remaining)',
      );
    }

    // Add at the end of scheduleParkedNotifications method
    await notificationsPlugin.show(
      99999,
      "Debug: Notifications Scheduled",
      "Scheduled ${remindersToSchedule} minute reminders. Next one at ${DateTime.now().add(Duration(minutes: 1)).toString().substring(11, 16)}",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'debug_channel',
          'Debug Channel',
          channelDescription: 'For debugging notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );

    // For immediate testing with 5, 10, and 15 second intervals
    final now = DateTime.now();
    for (int i = 1; i <= 3; i++) {
      final shortTestTime = now.add(Duration(seconds: i * 5));
      await scheduleNotification(
        title: 'Quick Test $i',
        content: 'This should appear in ${i * 5} seconds',
        deliveryTime: shortTestTime,
        id: 88880 + i,
      );
      print('Quick test $i scheduled for $shortTestTime');
    }

    // EMULATOR SPECIFIC TESTS
    final timeNow = DateTime.now();
    for (int i = 1; i <= 3; i++) {
      final veryShortTime = timeNow.add(
        Duration(seconds: i * 3),
      ); // 3, 6, 9 seconds
      
      await notificationsPlugin.zonedSchedule(
        77770 + i,
        "Emulator Test $i",
        "This should appear in ${i * 3} seconds",
        tz.TZDateTime.from(veryShortTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'emulator_test_channel',
            'Emulator Tests',
            channelDescription: 'For testing notifications on emulator',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
      print('Emulator test $i scheduled for $veryShortTime');
    }
  } catch (e, stack) {
    print('Error scheduling parking notifications: $e');
    print('Stack trace: $stack');
  }
}

Future<void> testEmulatorNotifications() async {
  try {
    // 1. First show immediate notification
    await notificationsPlugin.show(
      5000,
      "Immediate Test emulator",
      "This should appear immediately",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'emulator_test_channel',
          'Emulator Tests',
          channelDescription: 'For testing on emulator',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    print("Immediate notification for emulator sent");

    // 2. Schedule notifications based on EMULATOR time, not system time
    final emulatorNow = DateTime.now(); // This gets emulator's current time
    print("Emulator current time: $emulatorNow");

    for (int i = 1; i <= 3; i++) {
      // Use very short intervals (5, 10, 15 seconds)
      final scheduledTime = emulatorNow.add(Duration(seconds: i * 5));

      await notificationsPlugin.zonedSchedule(
        5000 + i,
        "Emulator Test ${i * 5}s",
        "This should appear in ${i * 5} seconds from emulator time",
        tz.TZDateTime.from(scheduledTime, tz.local), // Convert to TZ time
        NotificationDetails(
          android: AndroidNotificationDetails(
            'emulator_test_channel',
            'Emulator Tests',
            channelDescription: 'For testing on emulator',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
      print(
        "Scheduled notification for ${i * 5} seconds from emulator now: $scheduledTime",
      );
    }
  } catch (e, stack) {
    print("Error in test notification: $e");
    print(stack);
  }
}

Future<void> emulatorSequentialNotifications() async {
  try {
    // First immediate notification
    await notificationsPlugin.show(
      6000,
      "Emulator Test: Start",
      "Sequential notifications starting...",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'emulator_test_channel',
          'Emulator Tests',
          channelDescription: 'For testing on emulator',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );

    print("Starting sequential notifications");

    // Instead of scheduling, use delayed functions
    Future.delayed(const Duration(seconds: 5), () async {
      await notificationsPlugin.show(
        6001,
        "Emulator Test: 5 Seconds",
        "This appears 5 seconds after start",
        NotificationDetails(
          android: AndroidNotificationDetails(
            'emulator_test_channel',
            'Emulator Tests',
            channelDescription: 'For testing on emulator',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
      print("Showed 5-second notification");
    });

    Future.delayed(const Duration(seconds: 10), () async {
      await notificationsPlugin.show(
        6002,
        "Emulator Test: 10 Seconds",
        "This appears 10 seconds after start",
        NotificationDetails(
          android: AndroidNotificationDetails(
            'emulator_test_channel',
            'Emulator Tests',
            channelDescription: 'For testing on emulator',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
      print("Showed 10-second notification");
    });

    Future.delayed(const Duration(seconds: 15), () async {
      await notificationsPlugin.show(
        6003,
        "Emulator Test: 15 Seconds",
        "This appears 15 seconds after start",
        NotificationDetails(
          android: AndroidNotificationDetails(
            'emulator_test_channel',
            'Emulator Tests',
            channelDescription: 'For testing on emulator',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
      print("Showed 15-second notification");
    });

    return;
  } catch (e) {
    print("Error in emulator sequential notifications: $e");
  }
}

// Add this new function specifically for real device testing
Future<void> realDeviceNotificationDemo({
  required String vehicleRegistration,
  required String parkingSpace,
  required String parkingId,
}) async {
  try {
    // Initial confirmation notification
    await notificationsPlugin.show(
      9000,
      "Parking Started",
      "Your parking for $vehicleRegistration at $parkingSpace has been registered",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'parking_reminder_channel',
          'Parking Reminders',
          channelDescription: 'For parking notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );

    // Use Future.delayed for reliable notifications during demo
    Future.delayed(const Duration(seconds: 30), () async {
      await notificationsPlugin.show(
        9001,
        "Parking Update",
        "Your parking for $vehicleRegistration has 10 minutes remaining",
        NotificationDetails(
          android: AndroidNotificationDetails(
            'parking_reminder_channel',
            'Parking Reminders',
            channelDescription: 'For parking notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });

    Future.delayed(const Duration(seconds: 60), () async {
      await notificationsPlugin.show(
        9002,
        "Parking Ending Soon",
        "Your parking for $vehicleRegistration at $parkingSpace will end in 5 minutes",
        NotificationDetails(
          android: AndroidNotificationDetails(
            'parking_reminder_channel',
            'Parking Reminders',
            channelDescription: 'For parking notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });
  } catch (e) {
    print("Error in real device notifications: $e");
  }
}

Future<void> cancelParkedNotifications(String parkingId) async {
  try {
    // Convert parkingId to a consistent integer hash for notification ID
    final baseId = parkingId.hashCode;

    // Cancel main end notification
    await cancelNotification(baseId);

    // Cancel all hourly/minute reminders (assuming max 60)
    for (int i = 1; i <= 60; i++) {
      await cancelNotification(baseId + i);
    }

    // Cancel any other special notifications
    await cancelNotification(9000); // "Parking Started"
    await cancelNotification(9001); // "Parking Update"
    await cancelNotification(9002); // "Parking Ending Soon"

    print('Canceled all notifications for parking $parkingId');
  } catch (e) {
    print('Error canceling notifications: $e');
  }
}
