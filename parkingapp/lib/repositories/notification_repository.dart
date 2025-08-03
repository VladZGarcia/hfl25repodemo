import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:parkingapp/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared/shared.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleNotification({
  required String title,
  required String content,
  required DateTime deliveryTime,
  required int id,
  NotificationDetails? notificationDetails,
}) async {
  try {
    await requestNotificationPermission();

    var scheduledDate = tz.TZDateTime.from(deliveryTime, tz.local);

    // Use provided details or create default ones
    final details =
        notificationDetails ??
        NotificationDetails(
          android: AndroidNotificationDetails(
            'parking_reminder_channel',
            'Parking Reminders',
            channelDescription: 'Notifications for parking session end times',
            importance: Importance.max,
            priority: Priority.high,
            enableLights: true,
            enableVibration: true,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound(
              'carpark_notification',
            ),
            channelShowBadge: true,
            visibility: NotificationVisibility.public,
          ),
        );

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      content,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );

    print('Notification scheduled successfully');
  } catch (e, stackTrace) {
    print('Error scheduling notification: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

Future<void> androidNotification() async {
  try {
    await requestNotificationPermission();
    final now = tz.TZDateTime.now(tz.local);

    // Base notification details
    final basicDetails = AndroidNotificationDetails(
      'demo_channel',
      'Notification Demos',
      channelDescription: 'Shows different notification types',
      importance: Importance.high,
      priority: Priority.high,
    );

    // 1. IMMEDIATE BASIC NOTIFICATION
    await notificationsPlugin.show(
      1001,
      "Basic Notification",
      "This is a standard notification with default styling",
      NotificationDetails(android: basicDetails),
    );

    // 2. BIG TEXT STYLE
    final bigTextStyle = BigTextStyleInformation(
      'This is a much longer notification text that will be displayed in an expanded view when the user taps on it. It can contain much more information than a standard notification.',
      contentTitle: 'Expanded Title',
      summaryText: 'Summary text',
    );

    await notificationsPlugin.show(
      1002,
      "Big Text Style",
      "Tap to expand and see more text...",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'demo_channel',
          'Notification Demos',
          channelDescription: 'Shows different notification types',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: bigTextStyle,
        ),
      ),
    );

    // 3. SCHEDULED NOTIFICATION - 30 seconds
    await notificationsPlugin.zonedSchedule(
      1003,
      "Scheduled (30s)",
      "This notification appeared 30 seconds after triggering",
      now.add(const Duration(seconds: 30)),
      NotificationDetails(android: basicDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // 4. SCHEDULED NOTIFICATION - 1 minute
    await notificationsPlugin.zonedSchedule(
      1004,
      "Scheduled (1min)",
      "This notification appeared 1 minute after triggering",
      now.add(const Duration(minutes: 1)),
      NotificationDetails(android: basicDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // 5. NOTIFICATION WITH ACTIONS/BUTTONS
    final actionsNotification = AndroidNotificationDetails(
      'demo_channel',
      'Notification Demos',
      channelDescription: 'Shows different notification types',
      importance: Importance.high,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'extend',
          'Extend Parking',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'cancel',
          'Cancel Parking',
          showsUserInterface: true,
        ),
      ],
    );

    await notificationsPlugin.show(
      1005,
      "Interactive Notification",
      "This notification has action buttons",
      NotificationDetails(android: actionsNotification),
    );

    // 6. PROGRESS BAR NOTIFICATION
    final progressNotification = AndroidNotificationDetails(
      'demo_channel',
      'Notification Demos',
      channelDescription: 'Shows different notification types',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: 65,
      channelShowBadge: false,
    );

    await notificationsPlugin.show(
      1006,
      "Progress Indicator",
      "Shows parking time elapsed (65%)",
      NotificationDetails(android: progressNotification),
    );

    // 7. HIGH PRIORITY NOTIFICATION
    final highPriorityNotification = AndroidNotificationDetails(
      'critical_channel',
      'Critical Alerts',
      channelDescription: 'For time-sensitive alerts',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    await notificationsPlugin.show(
      1007,
      "⚠️ URGENT: Parking Expiring",
      "Your parking session ends in 2 minutes",
      NotificationDetails(android: highPriorityNotification),
    );

    print('All demo notifications created successfully');
  } catch (e, stack) {
    print('Error in notification demo: $e');
    print('Stack trace: $stack');
  }
}

Future<void> scheduleParkedNotifications(Parking parking) async {
  try {
    final baseId = parking.id.hashCode;
    final totalMinutes =
        parking.endTime?.difference(parking.startTime).inMinutes;

    if (parking.endTime == null) {
      print('Cannot schedule countdown for parking without end time');
      return;
    }

    // 1. IMMEDIATE START NOTIFICATION WITH COUNTDOWN INFO
    final startDetails = AndroidNotificationDetails(
      'parking_reminder_channel_v2',
      'Parking Reminders',
      channelDescription: 'For parking notifications',
      sound: const RawResourceAndroidNotificationSound('carpark_notification'),
      importance: Importance.max,
      priority: Priority.high,
    );

    // Format duration for display
    final durationText = _formatDuration(Duration(minutes: totalMinutes!));

    await notificationsPlugin.show(
      baseId,
      "Parking Started",
      "Your vehicle ${parking.vehicle.registrationNumber} is now parked at ${parking.parkingSpace.adress}\n"
          "Time remaining: $durationText (until ${_formatTime(parking.endTime!)})",
      NotificationDetails(android: startDetails),
    );

    // 2. COUNTDOWN NOTIFICATIONS AT STRATEGIC POINTS
    final reminderPoints = [0.5, 0.75, 0.9, 0.95, 1.0];

    for (int i = 0; i < reminderPoints.length; i++) {
      final minutesFromStart = (totalMinutes * reminderPoints[i]).round();
      final reminderTime = parking.startTime.add(
        Duration(minutes: minutesFromStart),
      );
      final minutesRemaining = totalMinutes - minutesFromStart;

      // Skip if already in the past
      if (reminderTime.isBefore(DateTime.now())) continue;

      // PROGRESS BAR FOR COUNTDOWN VISUALIZATION
      final progressPercent = (reminderPoints[i] * 100).round();
      String content;

      if (minutesRemaining > 0) {
        // Format remaining time for better readability
        final remainingText = _formatDuration(
          Duration(minutes: minutesRemaining),
        );
        content =
            "Your parking for ${parking.vehicle.registrationNumber} has $remainingText remaining";
      } else {
        content =
            "Your parking for ${parking.vehicle.registrationNumber} is ending now!";
      }

      // Different notification style based on how close to expiration
      if (reminderPoints[i] >= 0.9) {
        // URGENT NOTIFICATIONS (90%, 95%, 100%)
        final urgentDetails = AndroidNotificationDetails(
          'parking_reminder_channel_v2',
          'Parking Reminders',
          channelDescription: 'For parking notifications',
          sound: const RawResourceAndroidNotificationSound(
            'carpark_notification',
          ),
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent:
              reminderPoints[i] >= 0.95, // Full screen for final notifications
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
        );

        // Create NotificationDetails with the Android details
        final notificationDetails = NotificationDetails(android: urgentDetails);

        // Pass the notificationDetails to the function
        await scheduleNotification(
          title:
              reminderPoints[i] == 1.0
                  ? '⚠️ PARKING EXPIRED'
                  : '⚠️ URGENT: Parking Ending Soon',
          content: content,
          deliveryTime: reminderTime,
          id: baseId + i + 1,
          notificationDetails: notificationDetails, // Add this line
        );
      } else {
        // PROGRESS NOTIFICATIONS (50%, 75%)
        final progressDetails = AndroidNotificationDetails(
          'parking_reminder_channel_v2',
          'Parking Reminders',
          channelDescription: 'For parking notifications',
          sound: const RawResourceAndroidNotificationSound(
            'carpark_notification',
          ),
          importance: Importance.high,
          priority: Priority.high,
          showProgress: true,
          maxProgress: 100,
          progress: progressPercent,
        );

        await notificationsPlugin.zonedSchedule(
          baseId + i + 1,
          "Parking Countdown: $progressPercent% Complete",
          content,
          tz.TZDateTime.from(reminderTime, tz.local),
          NotificationDetails(android: progressDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }

    // 3. FINAL "ALMOST EXPIRED" NOTIFICATION WITH ACTIONS (5 minutes before expiry)
    if (totalMinutes > 5) {
      final fiveMinReminderTime = parking.endTime!.subtract(
        const Duration(minutes: 5),
      );

      // Skip if already in the past
      if (fiveMinReminderTime.isAfter(DateTime.now())) {
        final actionsNotification = AndroidNotificationDetails(
          'parking_reminder_channel_v2',
          'Parking Reminders',
          channelDescription: 'For parking notifications',
          sound: const RawResourceAndroidNotificationSound(
            'carpark_notification',
          ),
          importance: Importance.max,
          priority: Priority.max,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'extend',
              'Extend Time',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'end',
              'End Now',
              showsUserInterface: true,
            ),
          ],
        );

        await notificationsPlugin.zonedSchedule(
          baseId + reminderPoints.length + 1,
          "⏱️ 5 Minutes Remaining",
          "Your parking for ${parking.vehicle.registrationNumber} at ${parking.parkingSpace.adress} will expire soon!",
          tz.TZDateTime.from(fiveMinReminderTime, tz.local),
          NotificationDetails(android: actionsNotification),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }

    print('Scheduled parking countdown notifications with strategic reminders');
  } catch (e) {
    print('Error scheduling countdown notifications: $e');
  }
}

Future<void> scheduleOngoingParkingNotifications(Parking parking) async {
  try {
    // Use fewer notifications with strategic intervals
    // Instead of every minute, use increasing intervals
    final intervals = [15, 30, 60, 120, 240]; // minutes between notifications
    final baseId = parking.id.hashCode;

    // Immediate confirmation notification
    await notificationsPlugin.show(
      baseId,
      "Parking Started",
      "Ongoing parking for ${parking.vehicle.registrationNumber} at ${parking.parkingSpace.adress} has started",
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

    // Schedule only a few strategic reminders
    DateTime nextTime = parking.startTime;
    for (int i = 0; i < intervals.length; i++) {
      nextTime = nextTime.add(Duration(minutes: intervals[i]));

      // Calculate elapsed time for message
      final minutes = intervals.take(i + 1).reduce((a, b) => a + b);
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      final timeMessage =
          hours > 0
              ? "$hours hr${hours > 1 ? 's' : ''} ${remainingMinutes > 0 ? '$remainingMinutes min' : ''}"
              : "$minutes min";

      await scheduleNotification(
        title: 'Ongoing Parking Reminder',
        content:
            'Your parking for ${parking.vehicle.registrationNumber} has been active for $timeMessage',
        deliveryTime: nextTime,
        id: baseId + i + 1,
      );
    }

    print(
      'Scheduled ${intervals.length} strategic reminders instead of many small ones',
    );
  } catch (e) {
    print('Error scheduling notifications: $e');
  }
}

// Add this function to notification_repository.dart
Future<void> showcaseParkingNotifications(Parking ticket) async {
  try {
    await requestNotificationPermission();
    final now = tz.TZDateTime.now(tz.local);
    final registration = ticket.vehicle.registrationNumber;
    final location = ticket.parkingSpace.adress;
    final baseId = ticket.id.hashCode;

    // 1. IMMEDIATE CONFIRMATION (0 seconds)
    await notificationsPlugin.show(
      baseId + 1,
      "Parking Confirmed",
      "Vehicle $registration is now parked at $location",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'parking_reminder_channel_v2',
          'Parking Reminders',
          channelDescription: 'For parking notifications',
          sound: const RawResourceAndroidNotificationSound(
            'carpark_notification',
          ),
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );

    // 2. BIG TEXT STYLE (30 seconds) - Parking details
    final bigTextStyle = BigTextStyleInformation(
      'Your vehicle $registration is parked at $location.\n'
      'Start time: ${_formatTime(ticket.startTime)}\n'
      'End time: ${ticket.endTime != null ? _formatTime(ticket.endTime!) : "Ongoing"}\n'
      'Tap for more details or to manage your parking.',
      contentTitle: 'Your Parking Details',
      summaryText: 'Tap to view',
    );

    await notificationsPlugin.zonedSchedule(
      baseId + 2,
      "Parking Information",
      "Tap to view your complete parking details",
      now.add(const Duration(seconds: 30)),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'parking_reminder_channel_v2',
          'Parking Reminders',
          channelDescription: 'For parking notifications',
          sound: const RawResourceAndroidNotificationSound(
            'carpark_notification',
          ),
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: bigTextStyle,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // 3. INTERACTIVE NOTIFICATION (1 minute) - With action buttons
    final actionsNotification = AndroidNotificationDetails(
      'parking_reminder_channel_v2',
      'Parking Reminders',
      channelDescription: 'For parking notifications',
      sound: const RawResourceAndroidNotificationSound('carpark_notification'),
      importance: Importance.high,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'extend',
          'Extend Time',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'end',
          'End Parking',
          showsUserInterface: true,
        ),
      ],
    );

    await notificationsPlugin.zonedSchedule(
      baseId + 3,
      "Manage Your Parking",
      "Need to modify your parking for $registration?",
      now.add(const Duration(minutes: 1)),
      NotificationDetails(android: actionsNotification),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // 4. PROGRESS NOTIFICATION (2 minutes) - Showing elapsed time
    final progressNotification = AndroidNotificationDetails(
      'parking_reminder_channel_v2',
      'Parking Reminders',
      channelDescription: 'For parking notifications',
      sound: const RawResourceAndroidNotificationSound('carpark_notification'),
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: 10, // Just started
      channelShowBadge: false,
    );

    await notificationsPlugin.zonedSchedule(
      baseId + 4,
      "Parking Progress",
      "Your parking at $location is 10% complete",
      now.add(const Duration(minutes: 2)),
      NotificationDetails(android: progressNotification),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // 5. HIGH PRIORITY NOTIFICATION (3 minutes) - Upcoming expiration demo
    final highPriorityNotification = AndroidNotificationDetails(
      'parking_reminder_channel_v2',
      'Parking Reminders',
      channelDescription: 'For parking notifications',
      sound: const RawResourceAndroidNotificationSound('carpark_notification'),
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    await notificationsPlugin.zonedSchedule(
      baseId + 5,
      "⚠️ PARKING EXPIRING SOON",
      "Your parking for $registration at $location will expire in 10 minutes!",
      now.add(const Duration(minutes: 3)),
      NotificationDetails(android: highPriorityNotification),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // 6. REMINDER (4 minutes) - Receipt notification
    await notificationsPlugin.zonedSchedule(
      baseId + 6,
      "Parking Receipt Available",
      "View and save your parking receipt for $registration at $location",
      now.add(const Duration(minutes: 4)),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'parking_reminder_channel_v2',
          'Parking Reminders',
          channelDescription: 'For parking notifications',
          sound: const RawResourceAndroidNotificationSound(
            'carpark_notification',
          ),
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print('All parking notification types scheduled for the next 5 minutes');
  } catch (e, stack) {
    print('Error in notification showcase: $e');
    print('Stack trace: $stack');
  }
}

// Helper function to format time
String _formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

Future<void> cancelNotification(int id) async {
  await notificationsPlugin.cancel(id);
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

Future<bool> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.request();
    print('Notification permission status: $status');

    // Request exact alarm permission
    try {
      await Permission.scheduleExactAlarm.request();
      print('Exact alarm permission requested');
    } catch (e) {
      print('Error requesting exact alarm permission: $e');
    }

    // Return true if notification permission was granted
    return status.isGranted;
  }

  return true; // Non-Android platforms
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

// Add this helper function to format duration nicely
String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;

  if (hours > 0) {
    return '$hours hr${hours > 1 ? 's' : ''} ${minutes > 0 ? '$minutes min' : ''}';
  } else {
    return '$minutes min';
  }
}
