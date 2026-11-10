import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fcm_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Android runs this in a separate isolate. No widget state belongs here.
  debugPrint('onBackgroundMessage: ${message.messageId ?? "no ID"}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool configured = false;
  try {
    // Android options come from the matched google-services.json resources.
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    configured = true;
  } catch (_) {
    // Never print configuration contents or credentials in diagnostics.
  }
  runApp(ActivityApp(configured: configured));
}

class ActivityApp extends StatelessWidget {
  const ActivityApp({super.key, required this.configured});
  final bool configured;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Activity 14 • FCM',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    home: configured
        ? const MessagePage()
        : Scaffold(
            appBar: AppBar(title: const Text('Activity 14 • FCM')),
            body: const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Firebase setup required\n\n'
                'Register edu.gsu.csc4360.activity14_fcm in your Firebase project, '
                'run FlutterFire configure, and rebuild.\n\n'
                'No Firebase delivery has been verified.',
              ),
            ),
          ),
  );
}

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});
  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with WidgetsBindingObserver {
  late final FCMService service;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    service = FCMService();
    unawaited(service.initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(service.refreshPermission());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Activity 14 • FCM')),
    body: ListenableBuilder(
      listenable: service,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(service.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Image.asset(
            MessageState.assets[service.asset]!,
            height: 160,
            fit: BoxFit.contain,
          ),
          Text('Asset: ${service.asset}'),
          const Divider(),
          Text(
            'Last handler: ${service.handler}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Receipts this launch: ${service.count}'),
          Text('Message ID: ${service.messageId}'),
          const SizedBox(height: 8),
          Text(service.diagnostic),
          const Divider(),
          Text('Permission: ${service.permission}'),
          Text('FCM token: ${service.tokenStatus}'),
          Text(service.delivery, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: service.requestPermissionAndToken,
                child: const Text('Permission / retry'),
              ),
              OutlinedButton(
                onPressed: service.tokenForPrivateCopy == null
                    ? null
                    : () async {
                        await Clipboard.setData(
                          ClipboardData(text: service.tokenForPrivateCopy!),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Token copied privately. Paste only into Firebase Console.',
                            ),
                          ),
                        );
                      },
                child: const Text('Copy token privately'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
