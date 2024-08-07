
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends StatefulWidget {
  final Widget child;
  final int numOfdays; // Accept the numOfdays parameter

  const NotificationService({Key? key, required this.child, required this.numOfdays}) : super(key: key);

  @override
  NotificationServiceState createState() => NotificationServiceState();

  static NotificationServiceState? of(BuildContext context) {
    return context.findAncestorStateOfType<NotificationServiceState>();
  }
}

class NotificationServiceState extends State<NotificationService> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/ic_launcher', // Ensure this is correct
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class NotificationProvider extends StatefulWidget {
  final Widget child;
  final int numOfdays;

  NotificationProvider({required this.child, required this.numOfdays});

  @override
  _NotificationProviderState createState() => _NotificationProviderState();

  static _NotificationProviderState? of(BuildContext context) {
    return context.findAncestorStateOfType<_NotificationProviderState>();
  }
}

class _NotificationProviderState extends State<NotificationProvider> {
  final GlobalKey<NotificationServiceState> notificationServiceKey = GlobalKey<NotificationServiceState>();

  @override
  Widget build(BuildContext context) {
    return NotificationService(
      key: notificationServiceKey,
      numOfdays: widget.numOfdays,
      child: widget.child,
    );
  }

  NotificationServiceState? get notificationService => notificationServiceKey.currentState;
}
