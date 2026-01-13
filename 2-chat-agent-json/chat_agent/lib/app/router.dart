import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/chat/presentation/chat_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/state/settings_controller.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier(0);
  ref.listen(settingsControllerProvider, (previous, next) {
    notifier.value++;
  });
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/chat',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    redirect: (context, state) {
      final settings = ref.read(settingsControllerProvider);
      if (settings.isLoading) {
        return null;
      }
      final hasKey = settings.hasKey;
      final isOnSettings = state.matchedLocation == '/settings';
      if (!hasKey && !isOnSettings) {
        return '/settings';
      }
      return null;
    },
  );
});
