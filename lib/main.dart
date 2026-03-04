import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:turfzone/features/splash/splash_screen.dart';
import 'package:turfzone/services/api_service.dart';

/// Global navigator key — lets us show snackbars from outside widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Local notifications plugin — needed to show heads-up banners on Android 8+
final FlutterLocalNotificationsPlugin _localNotif =
    FlutterLocalNotificationsPlugin();

/// The Android channel that FCM will deliver to.
final AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel',
  'Push Notifications',
  description: 'TurfZone push notifications from admin',
  importance: Importance.max,
  playSound: true,
);

/// Background FCM handler — runs in a separate isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint(
    '📬 Background FCM: [${message.messageId}] ${message.notification?.title}',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialise Firebase
  await Firebase.initializeApp();

  // 2. Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. Create the Android notification channel (Android 8+)
  await _localNotif
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_channel);

  // Set FCM to use our high-importance channel
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // 4. Request notification permission (Android 13+ / iOS)
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
  debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');

  // 5. Get FCM token, log it, and upload it to backend immediately
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint('📲 FCM Token: $token');
  if (token != null) {
    unawaited(_uploadFcmTokenOnStart(token));
  }

  // 6. Foreground message handler — shows system notification + in-app banner
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📨 Foreground FCM: ${message.notification?.title}');

    // Show a real system notification even when app is open
    final n = message.notification;
    final android = message.notification?.android;
    if (n != null && android != null) {
      unawaited(
        _localNotif.show(
          message.hashCode,
          n.title,
          n.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@drawable/ic_notification',
              color: const Color(0xFF1DB954),
              styleInformation: BigTextStyleInformation(
                n.body ?? '',
                contentTitle: n.title,
                htmlFormatContent: false,
                htmlFormatContentTitle: false,
              ),
            ),
          ),
        ),
      );
    }

    // Also show in-app snackbar
    final ctx = navigatorKey.currentContext;
    if (ctx != null && n != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1DB954),
          duration: const Duration(seconds: 5),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n.title ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (n.body != null)
                Text(
                  n.body!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        ),
      );
    }
  });

  // 7. Notification tap handler — app was in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📲 Notification tapped (background): ${message.data}');
    _handleNotificationData(message.data);
  });

  // 8. Check if app was opened from a terminated-state notification
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint(
      '📲 App opened via notification (terminated): ${initialMessage.data}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationData(initialMessage.data);
    });
  }

  runApp(const TurfZoneApp());
}

/// Upload FCM token to backend using stored JWT — called on every app start.
/// Fire-and-forget: if user isn't logged in yet, it silently skips.
Future<void> _uploadFcmTokenOnStart(String fcmToken) async {
  try {
    final storedToken = await ApiService.getAccessToken();
    if (storedToken == null || storedToken.isEmpty) {
      debugPrint('📲 FCM upload skipped — no stored JWT (not logged in yet)');
      return;
    }

    final url = Uri.parse('${ApiService.BASE_URL}/api/users/fcm-token/');
    debugPrint('📲 Uploading FCM token to backend…');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $storedToken',
          },
          body: jsonEncode({'fcm_token': fcmToken}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('✅ FCM token saved to backend (${response.statusCode})');
    } else {
      debugPrint(
        '⚠️ FCM upload response: ${response.statusCode} ${response.body}',
      );
    }
  } catch (e) {
    debugPrint('⚠️ FCM token upload error: $e');
  }
}

/// Navigate based on FCM data payload.
void _handleNotificationData(Map<String, dynamic> data) {
  final route = data['route'] as String? ?? '';
  debugPrint('🔀 FCM route: $route');
}

class TurfZoneApp extends StatelessWidget {
  const TurfZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'TurfZone',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF1DB954),
        scaffoldBackgroundColor: Colors.white,
      ),
      // Global SafeArea — protects bottom buttons from system navigation
      builder: (context, child) {
        return SafeArea(
          top: false, // don't affect AppBar
          bottom: true, // protect bottom CTAs from nav bar
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TurfZone'),
        backgroundColor: const Color(0xFF1DB954),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Your Role',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () {},
              child: const Text('Continue as User/Admin'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () {},
              child: const Text('Super Admin Login'),
            ),
          ],
        ),
      ),
    );
  }
}
