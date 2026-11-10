import 'package:activity14_fcm/fcm_service.dart';
import 'package:activity14_fcm/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Valid payload selects only bundled assets and updates receipt metadata',
    () {
      final state = MessageState();
      addTearDown(state.dispose);
      state.receive(
        const RemoteMessage(
          messageId: 'valid-1',
          notification: RemoteNotification(title: 'New promotion'),
          data: {'action': 'update_ui', 'asset': 'promo'},
        ),
        'onMessage',
      );
      expect(state.title, 'New promotion');
      expect(state.asset, 'promo');
      expect(state.messageId, 'valid-1');
      expect(state.count, 1);
      expect(state.handler, 'onMessage');
      state.receive(
        const RemoteMessage(data: {'action': 'update_ui', 'asset': 'default'}),
        'onMessageOpenedApp',
      );
      expect(state.asset, 'default');
      expect(state.count, 2);
      expect(state.handler, 'onMessageOpenedApp');
    },
  );

  test(
    'Missing, unsupported, and non-string data preserve the last valid UI',
    () {
      final state = MessageState();
      addTearDown(state.dispose);
      state.receive(
        const RemoteMessage(
          notification: RemoteNotification(title: 'Keep me'),
          data: {'action': 'update_ui', 'asset': 'promo'},
        ),
        'getInitialMessage',
      );
      final invalid = <Map<String, dynamic>>[
        {},
        {'asset': 'default'},
        {'action': 'other', 'asset': 'default'},
        {'action': 'update_ui'},
        {'action': 'update_ui', 'asset': '../private'},
        {'action': 'update_ui', 'asset': 42},
      ];
      for (final data in invalid) {
        state.receive(
          RemoteMessage(
            messageId: 'invalid',
            data: data,
            notification: const RemoteNotification(title: 'Must not replace'),
          ),
          'onMessage',
        );
        expect(state.title, 'Keep me');
        expect(state.asset, 'promo');
        expect(state.diagnostic, contains('Rejected:'));
        expect(state.messageId, 'invalid');
      }
      expect(state.count, 7);
    },
  );

  testWidgets('Missing Firebase configuration clearly reports setup block', (
    tester,
  ) async {
    await tester.pumpWidget(const ActivityApp(configured: false));
    expect(find.textContaining('Firebase setup required'), findsOneWidget);
    expect(
      find.textContaining('No Firebase delivery has been verified.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
