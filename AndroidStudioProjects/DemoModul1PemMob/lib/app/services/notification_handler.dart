import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)
async {
  print('Pesan diterima di background: ${message.notification?.title}');
}
class FirebaseMessagingHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'channel_notification',
    'High Importance Notification',
    description: 'Used For Notification',
    importance: Importance.defaultImportance,
  );

  final _localNotification = FlutterLocalNotificationsPlugin();

  Future<void> initPushNotification() async {
    // Izin notifikasi dari pengguna
    NotificationSettings settings = await
    _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Izin yang diberikan pengguna: ${settings.authorizationStatus}');
    // Mendapatkan token FCM
    _firebaseMessaging.getToken().then((token) {
      print('FCM Token: $token');
    });

// Handler untuk notifikasi ketika aplikasi di foreground
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      // Tampilkan notifikasi lokal
      _localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
          android: AndroidNotificationDetails(_androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher'
          )
          ),
        payload: jsonEncode(message.toMap()),
      );
      print('Pesan diterima saat aplikasi di foreground: ${message.notification?.title}');
      });


    // Saat aplikasi dalam keadaan terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      print("Pesan saat aplikasi terminated: ${message!.notification?.title}");
      });

    // Saat aplikasi dalam keadaan background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  Future initLocalNotification() async {
    const ios = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotification.initialize(settings);
  }

  Future<void> showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(); // Pengaturan notifikasi untuk iOS
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0, // ID unik untuk notifikasi
      'plain title',
      'plain body',
      platformChannelSpecifics,
      payload: 'plain notification',
    );
  }

  Future<void> showProgressNotification(FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin) async {
    var maxProgress = 5; // Jumlah total progres (misal 5 tahap)
    for (var i = 0; i <= maxProgress; i++) {
      await Future.delayed(const Duration(seconds: 1), () async {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
            channelDescription: _androidChannel.description,
            channelShowBadge: false, // Tidak menampilkan badge (angka) di ikon aplikasi
            importance: Importance.max,
            priority: Priority.high, onlyAlertOnce: true,
          showProgress: true,
          maxProgress: maxProgress,
          progress: i,
        );
        var platformChannelSpecifics = NotificationDetails(android:
        androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
          0,
          'progress notification title',
          'progress notification body',
          platformChannelSpecifics,
          payload: 'item x',
        );
      });
    }
  }
}