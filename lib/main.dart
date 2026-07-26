import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/sign_up_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/common/presentation/error_screen.dart';
import 'features/common/presentation/main_navigation_screen.dart';
import 'features/dashboard/presentation/dashboard_provider.dart';
import 'features/feedback/presentation/edit_feedback_screen.dart';
import 'features/feedback/presentation/feedback_details_screen.dart';
import 'features/feedback/presentation/feedback_provider.dart';
import 'features/feedback/presentation/submit_feedback_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/profile/presentation/edit_profile_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/profile/presentation/profile_provider.dart';
import 'features/settings/presentation/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const FeedbackHubApp(),
    ),
  );
}

class FeedbackHubApp extends StatelessWidget {
  const FeedbackHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const MainNavigationScreen(initialIndex: 0),
        ),
        GoRoute(
          path: '/feedback-list',
          builder: (context, state) => const MainNavigationScreen(initialIndex: 1),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const MainNavigationScreen(initialIndex: 2),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const MainNavigationScreen(initialIndex: 3),
        ),
        GoRoute(
          path: '/submit-feedback',
          builder: (context, state) => const SubmitFeedbackScreen(),
        ),
        GoRoute(
          path: '/feedback-details/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return FeedbackDetailsScreen(feedbackId: id);
          },
        ),
        GoRoute(
          path: '/edit-feedback/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return EditFeedbackScreen(feedbackId: id);
          },
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(
        errorMessage: state.error?.toString(),
      ),
    );

    return MaterialApp.router(
      title: 'Feedback Hub',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
