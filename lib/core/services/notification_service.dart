import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _requestPermission();
    await _subscribeAdminTopic();
    _setupListeners();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🔔 Permission: ${settings.authorizationStatus}');
  }

  Future<void> _subscribeAdminTopic() async {
    await _messaging.subscribeToTopic('admin');
    final token = await _messaging.getToken();
    debugPrint('📱 FCM Token: $token');
  }

  void _setupListeners() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📩 Foreground message (TIDAK ADA BANNER)');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('📲 Notification clicked');
    });
  }
}
