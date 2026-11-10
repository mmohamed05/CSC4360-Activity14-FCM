import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// State is updated atomically: rejected data never changes title or image.
class MessageState extends ChangeNotifier {
  static const assets = {
    'default': 'assets/default.png',
    'promo': 'assets/promo.png',
  };
  String title = 'Campus updates';
  String asset = 'default';
  String handler = 'None';
  String messageId = 'None';
  String diagnostic = 'Waiting for a Firebase message.';
  String delivery = 'No delivery yet';
  int count = 0;

  void receive(RemoteMessage message, String source) {
    handler = source;
    messageId = message.messageId ?? '(not supplied)';
    count++;
    delivery =
        'Received: ${DateTime.now().toIso8601String()}\n'
        'Sent: ${message.sentTime?.toIso8601String() ?? "unknown"}\n'
        'Notification: ${message.notification != null ? "present" : "absent"}; '
        'TTL: ${message.ttl ?? "unknown"}';
    final action = message.data['action'];
    final requestedAsset = message.data['asset'];
    if (action != 'update_ui') {
      diagnostic = 'Rejected: action must be update_ui. Previous UI preserved.';
    } else if (requestedAsset is! String ||
        !assets.containsKey(requestedAsset)) {
      diagnostic =
          'Rejected: asset must be default or promo. Previous UI preserved.';
    } else {
      asset = requestedAsset;
      title = message.notification?.title ?? 'Campus update received';
      diagnostic = 'Accepted: update_ui / $asset';
    }
    notifyListeners();
  }
}

/// Owns all subscriptions and guards asynchronous work after disposal.
class FCMService extends MessageState {
  FCMService({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _started = false;
  bool _disposed = false;
  String permission = 'Not requested';
  String tokenStatus = 'Not retrieved';
  String? _token;
  String? get tokenForPrivateCopy => _token;

  Future<void> initialize() async {
    if (_started || _disposed) return;
    _started = true;
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen((message) {
        if (!_disposed) receive(message, 'onMessage');
      }),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (!_disposed) receive(message, 'onMessageOpenedApp');
      }),
    );
    _subscriptions.add(
      _messaging.onTokenRefresh.listen(
        (token) {
          if (_disposed) return;
          _token = token;
          tokenStatus = 'Available (hidden)';
          notifyListeners();
        },
        onError: (Object _) {
          if (_disposed) return;
          tokenStatus = 'Refresh failed; restart to retry';
          notifyListeners();
        },
      ),
    );
    try {
      final initial = await _messaging.getInitialMessage();
      if (_disposed) return;
      if (initial != null) receive(initial, 'getInitialMessage');
    } catch (_) {
      if (!_disposed) diagnostic = 'Could not read initial notification.';
    }
    await requestPermissionAndToken();
  }

  Future<void> requestPermissionAndToken() async {
    try {
      final settings = await _messaging.requestPermission();
      if (_disposed) return;
      permission = settings.authorizationStatus.name;
      notifyListeners();
      final token = await _messaging.getToken();
      if (_disposed) return;
      _token = token;
      tokenStatus = token == null ? 'Unavailable; retry' : 'Available (hidden)';
    } catch (_) {
      if (_disposed) return;
      tokenStatus =
          'Permission/token request failed; check network and Firebase';
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> refreshPermission() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      if (_disposed) return;
      permission = settings.authorizationStatus.name;
      notifyListeners();
    } catch (_) {
      // Keep the last known value; requesting again exposes a retry path.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    super.dispose();
  }
}
